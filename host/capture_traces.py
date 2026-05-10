#!/usr/bin/env python3
"""
Bulk-capture power traces from the CW305 unified_butterfly2 target for TVLA.

Supports both ChipWhisperer-Husky / Husky-Plus and ChipWhisperer-Lite / Pro
by branching the clock-config API. Scope type is auto-detected from
cw.list_devices() but can be overridden with --scope-type.

Trigger handling has two modes (see --trigger-mode):
  internal     (default, recommended)
       Assumes the wrapper drives tio_trigger from busy_reg
       (rtl/cw305_unified_butterfly2_top_v4_directwrite.v line 259).
       Capture is then perfectly aligned: rising edge = butterfly start.
  host-toggle  (legacy / fallback)
       For an old wrapper that has  assign tio_trigger = usb_trigger.
       Uses target.usb_trigger_toggle() before the start register write.
       Alignment suffers the USB-transaction gap (~125 us on Husky,
       ~1 ms on Lite); use a wider --samples and post-process align.

Per trace:
  1. choose group (A=fixed-b, B=random-b)
  2. write inputs (a, b, k, ctrl) over USB
  3. arm scope, write start, wait for done
  4. read trace from scope, read out1/out2 from target
  5. accumulate

Stored under  results/<timestamp>_<label>/  :
    traces.npy        (N, samples) float32
    inputs.npz        a, b, k, mode, mode2, group, out1, out2  (all per-trace)
    metadata.json     experiment + scope settings + device serials
"""

import argparse
import datetime as dt
import hashlib
import json
import sys
import time
from pathlib import Path

import numpy as np

from sca_config import (
    REG_A, REG_B, REG_K, REG_CTRL, REG_STATUS, REG_OUT1, REG_OUT2,
    REG_ID, DONE_MASK, BUSY_MASK,
    KYBER_Q, DILITHIUM_Q,
    EXCLUDE_SCOPE_SERIAL, RESULTS_ROOT,
    SCOPE_NAMES, DEFAULT_TARGET_FREQ_HZ, DEFAULT_ADC_MUL,
)


# ----------------------------------------------------------------------------
# Device discovery + scope-type detection
# ----------------------------------------------------------------------------

def _device_name(d):
    return d.get("name") or d.get("type") or ""

def _device_sn(d):
    return (d.get("sn") or d.get("serial") or "").lower()

def _is_scope(d):
    return _device_name(d).startswith("ChipWhisperer-")

def _is_cw305_target(d):
    return "CW305" in _device_name(d).upper()

def list_chipwhisperer_devices():
    import chipwhisperer as cw
    if hasattr(cw, "list_devices"):
        try:
            return cw.list_devices() or []
        except Exception as e:
            print(f"[devs] cw.list_devices() failed: {e}")
    return []

def print_devices(devices, exclude_sn):
    print(f"[devs] {len(devices)} ChipWhisperer device(s) detected:")
    for d in devices:
        sn   = _device_sn(d)
        name = _device_name(d) or "?"
        kind = "scope " if _is_scope(d) else ("target" if _is_cw305_target(d) else "???   ")
        marker = "  (EXCLUDED)" if sn == exclude_sn.lower() else ""
        print(f"        [{kind}] {name:30s} sn={sn}{marker}")

def find_scope_serial(devices, exclude_sn, override=None):
    if override:
        print(f"[scope] using user-specified serial: {override}")
        return override
    candidates = [
        _device_sn(d) for d in devices
        if _is_scope(d) and _device_sn(d) != exclude_sn.lower()
    ]
    if len(candidates) == 1:
        print(f"[scope] auto-selected sn={candidates[0]}")
        return candidates[0]
    if len(candidates) == 0:
        raise RuntimeError(
            f"No eligible ChipWhisperer scope (excluded {exclude_sn}). "
            f"Pass --scope-sn."
        )
    raise RuntimeError(
        f"Multiple eligible scopes: {candidates}. Pass --scope-sn to disambiguate."
    )

def find_target_serial(devices, override=None):
    if override:
        print(f"[target] using user-specified serial: {override}")
        return override
    candidates = [_device_sn(d) for d in devices if _is_cw305_target(d)]
    if len(candidates) == 1:
        print(f"[target] auto-selected CW305 sn={candidates[0]}")
        return candidates[0]
    if len(candidates) == 0:
        print("[target] no CW305 in device list; will rely on cw.target() autodetect")
        return None
    raise RuntimeError(
        f"Multiple CW305 boards found: {candidates}. Pass --target-sn to disambiguate."
    )

def detect_scope_type(devices, scope_sn):
    """Return one of {'husky-plus', 'husky', 'lite', 'pro', 'nano', 'unknown'}."""
    name = ""
    for d in devices:
        if _device_sn(d) == (scope_sn or "").lower():
            name = _device_name(d)
            break
    # Order matters: 'husky-plus' must be checked before 'husky'.
    for kind in ("husky-plus", "husky", "lite", "pro", "nano"):
        for prefix in SCOPE_NAMES[kind]:
            if name.startswith(prefix):
                return kind
    return "unknown"


# ----------------------------------------------------------------------------
# Target register helpers
# ----------------------------------------------------------------------------

def u32_to_le(x):
    x &= 0xFFFFFFFF
    return [(x >> 0) & 0xFF, (x >> 8) & 0xFF, (x >> 16) & 0xFF, (x >> 24) & 0xFF]

def le_to_u32(data):
    data = list(data)
    return data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24)

def read_u8(target, reg):
    raw = target.fpga_read(reg, 1)
    val = raw[0] if hasattr(raw, "__getitem__") else raw
    return int(val) & 0xFF

def write_u8(target, reg, value):
    target.fpga_write(reg, [value & 0xFF])

def read_u32(target, reg):
    return le_to_u32(target.fpga_read(reg, 4))

def write_u32(target, reg, value):
    target.fpga_write(reg, u32_to_le(value))

def write_inputs(target, a, b, k, mode, mode2):
    write_u32(target, REG_A, a)
    write_u32(target, REG_B, b)
    target.fpga_write(REG_K, [k & 0xFF, (k >> 8) & 0x03])
    write_u8(target, REG_CTRL, (mode & 1) | ((mode2 & 1) << 1))


# ----------------------------------------------------------------------------
# Scope setup — branched by scope_type
# ----------------------------------------------------------------------------

def _wait_for_pll_lock(scope, timeout=2.0):
    """Best-effort wait for Husky's PLL/ADC to lock onto the external clock."""
    t0 = time.time()
    last_status = None
    while time.time() - t0 < timeout:
        locked = None
        for attr in ("adc_locked", "clkgen_locked"):
            if hasattr(scope.clock, attr):
                locked = getattr(scope.clock, attr)
                last_status = (attr, locked)
                if locked:
                    return True, last_status
                break
        # Some versions expose pll.is_locked
        try:
            v = scope.clock.pll.is_locked
            last_status = ("pll.is_locked", v)
            if v:
                return True, last_status
        except Exception:
            pass
        time.sleep(0.05)
    return False, last_status

def setup_scope(scope, scope_type, samples, gain_db, target_freq, adc_mul):
    # Common settings (work on both Husky and Lite/Pro).
    scope.gain.db          = gain_db
    scope.adc.samples      = samples
    scope.adc.offset       = 0
    scope.adc.basic_mode   = "rising_edge"
    scope.adc.timeout      = 5
    scope.trigger.triggers = "tio4"        # CW305 tio_trigger arrives on scope tio4
    scope.io.tio1          = "serial_rx"
    scope.io.tio2          = "serial_tx"
    scope.io.hs2           = "disabled"    # CW305 supplies its own clock; scope only listens

    settings = {
        "scope_type": scope_type,
        "gain_db":    float(scope.gain.db),
        "samples":    int(scope.adc.samples),
        "offset":     int(scope.adc.offset),
        "basic_mode": str(scope.adc.basic_mode),
        "trigger":    str(scope.trigger.triggers),
    }

    if scope_type in ("husky", "husky-plus"):
        # Husky API: PLL input comes from external clock pin, ADC = PLL * adc_mul.
        scope.clock.clkgen_src  = "extclk"
        scope.clock.clkgen_freq = float(target_freq)
        scope.clock.adc_mul     = int(adc_mul)
        ok, status = _wait_for_pll_lock(scope, timeout=2.0)
        if not ok:
            print(f"[scope] WARNING: Husky PLL lock not confirmed (status={status}). "
                  f"Verify target is providing clock on tio_clkin.")
        else:
            print(f"[scope] Husky PLL lock OK ({status})")
        try:
            adc_freq = float(scope.clock.adc_freq)
        except Exception:
            adc_freq = None
        settings.update({
            "clkgen_src":  "extclk",
            "clkgen_freq": float(target_freq),
            "adc_mul":     int(adc_mul),
            "adc_freq":    adc_freq,
            "pll_locked":  bool(ok),
        })
    elif scope_type in ("lite", "pro"):
        # CW-Lite / CW-Pro single-string API. Only x1 and x4 are universally supported.
        if adc_mul not in (1, 4):
            print(f"[scope] WARNING: adc_mul={adc_mul} on {scope_type} — clamping to 4")
            adc_mul = 4
        scope.clock.adc_src = f"extclk_x{adc_mul}"
        settings.update({
            "adc_src": str(scope.clock.adc_src),
            "adc_mul": int(adc_mul),
        })
    else:
        raise RuntimeError(
            f"Unknown scope_type: {scope_type}. "
            f"Pass --scope-type {{husky-plus,husky,lite,pro}}"
        )

    return settings


# ----------------------------------------------------------------------------
# Capture loop
# ----------------------------------------------------------------------------

def capture_loop(
    scope, target,
    n_traces, samples,
    a, k, mode, mode2,
    b_fixed, q,
    seed,
    trigger_mode,
    poll_interval=0.0005, poll_timeout=0.5,
):
    rng = np.random.default_rng(seed)
    groups = rng.integers(0, 2, size=n_traces, dtype=np.uint8)  # 0=fixed, 1=random
    rand_b = rng.integers(0, q, size=n_traces, dtype=np.uint32)
    b_values = np.where(groups == 0, np.uint32(b_fixed % q), rand_b).astype(np.uint32)

    traces   = np.empty((n_traces, samples), dtype=np.float32)
    out1_arr = np.empty(n_traces, dtype=np.uint32)
    out2_arr = np.empty(n_traces, dtype=np.uint32)

    if trigger_mode == "host-toggle":
        if not hasattr(target, "usb_trigger_toggle"):
            raise RuntimeError(
                "trigger-mode=host-toggle requires target.usb_trigger_toggle(). "
                "Update chipwhisperer or use --trigger-mode internal."
            )

    print(f"[capture] starting {n_traces} traces, {samples} samples each "
          f"(trigger={trigger_mode}, group A=fixed b={hex(b_fixed % q)}, "
          f"group B=random b in [0,{q}))")
    t0 = time.time()
    fail_count = 0

    for i in range(n_traces):
        b_val = int(b_values[i])
        write_inputs(target, a, b_val, k, mode, mode2)

        scope.arm()

        if trigger_mode == "host-toggle":
            target.usb_trigger_toggle()

        # In 'internal' mode, this register write is the trigger event itself:
        # the wrapper raises busy_reg -> tio_trigger on the same FPGA cycle.
        write_u8(target, REG_STATUS, 0x01)

        t_wait = time.time()
        while True:
            if read_u8(target, REG_STATUS) & DONE_MASK:
                break
            if time.time() - t_wait > poll_timeout:
                raise TimeoutError(
                    f"trace {i}: done=1 timeout after {poll_timeout}s"
                )
            time.sleep(poll_interval)

        ret = scope.capture()
        if ret:
            fail_count += 1
            print(f"[capture] trace {i}: scope.capture() returned True (timeout). "
                  f"fail_count={fail_count}")

        wave = scope.get_last_trace()
        if wave.shape[0] != samples:
            raise RuntimeError(
                f"trace {i}: scope returned {wave.shape[0]} samples, expected {samples}"
            )
        traces[i, :] = wave.astype(np.float32)
        out1_arr[i]  = read_u32(target, REG_OUT1) & 0xFFFFFFFF
        out2_arr[i]  = read_u32(target, REG_OUT2) & 0xFFFFFFFF

        # Clear done bit so the next iteration's poll starts cleanly.
        write_u8(target, REG_STATUS, 0x02)

        if (i + 1) % max(1, n_traces // 20) == 0 or i == n_traces - 1:
            elapsed = time.time() - t0
            rate = (i + 1) / max(elapsed, 1e-9)
            print(f"[capture] {i+1:>6d}/{n_traces}  "
                  f"elapsed={elapsed:.1f}s  rate={rate:.1f} tr/s  "
                  f"fails={fail_count}")

    print(f"[capture] done. total_fail={fail_count}")
    return traces, b_values, groups, out1_arr, out2_arr


# ----------------------------------------------------------------------------
# Persistence
# ----------------------------------------------------------------------------

def make_results_dir(label):
    stamp = dt.datetime.now().strftime("%Y%m%d_%H%M%S")
    safe_label = "".join(c if c.isalnum() or c in "-_" else "_" for c in label)
    out_dir = RESULTS_ROOT / f"{stamp}_{safe_label}"
    out_dir.mkdir(parents=True, exist_ok=False)
    return out_dir


def md5_of(path):
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

def main():
    p = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    p.add_argument("--bitfile", required=True, help="Path to .bit file (CW305 bitstream)")
    p.add_argument("--no-program", action="store_true", help="Skip FPGA programming")
    p.add_argument("--scope-sn",  default=None, help="Override scope serial (else auto)")
    p.add_argument("--target-sn", default=None, help="Override CW305 target serial (else auto)")
    p.add_argument("--scope-type", default="auto",
                   choices=["auto", "husky-plus", "husky", "lite", "pro"],
                   help="Scope kind. 'auto' detects from cw.list_devices() name field")
    p.add_argument("--trigger-mode", default="internal",
                   choices=["internal", "host-toggle"],
                   help="'internal' = wrapper drives tio_trigger from busy_reg "
                        "(re-synthesis required, recommended). "
                        "'host-toggle' = legacy bitstream where tio_trigger=usb_trigger.")
    p.add_argument("--num-traces", type=int, default=2000)
    p.add_argument("--samples", type=int, default=400,
                   help="ADC samples per trace. With --trigger-mode internal, ~288 "
                        "covers the 72-cycle butterfly at adc_mul=4. With host-toggle "
                        "you need much wider (e.g. 50000) to absorb USB-latency gap.")
    p.add_argument("--gain-db",     type=float, default=25.0)
    p.add_argument("--target-freq", type=float, default=DEFAULT_TARGET_FREQ_HZ,
                   help="External clock frequency (CW305 usb_clk, Hz). "
                        "Used by Husky to lock its PLL.")
    p.add_argument("--adc-mul", type=int, default=DEFAULT_ADC_MUL,
                   help="ADC oversample multiplier on top of target clock.")
    p.add_argument("--label", default="kyber_ct_b_random",
                   help="Short label, used in results folder name")
    # Fixed inputs across all traces:
    p.add_argument("--a",     type=lambda x: int(x, 0), default=0xCAFEBABE)
    p.add_argument("--k",     type=lambda x: int(x, 0), default=16)
    p.add_argument("--mode",  type=int, choices=[0, 1], default=1, help="1=CT, 0=GS")
    p.add_argument("--mode2", type=int, choices=[0, 1], default=0, help="0=Kyber, 1=Dil")
    # Variable input (b) settings:
    p.add_argument("--b-fixed", type=lambda x: int(x, 0), default=0x12345678,
                   help="Fixed value used by group A (will be reduced mod q)")
    p.add_argument("--seed", type=int, default=0xC0FFEE,
                   help="RNG seed for group/randomness")
    args = p.parse_args()

    bitpath = Path(args.bitfile).expanduser().resolve()
    if not bitpath.exists():
        print(f"ERROR: bitfile not found: {bitpath}", file=sys.stderr)
        return 2

    q = KYBER_Q if args.mode2 == 0 else DILITHIUM_Q

    import chipwhisperer as cw

    devices = list_chipwhisperer_devices()
    print_devices(devices, EXCLUDE_SCOPE_SERIAL)
    scope_sn  = find_scope_serial(devices, EXCLUDE_SCOPE_SERIAL, override=args.scope_sn)
    target_sn = find_target_serial(devices, override=args.target_sn)

    scope_type = args.scope_type
    if scope_type == "auto":
        scope_type = detect_scope_type(devices, scope_sn)
        print(f"[scope] auto-detected scope_type={scope_type}")
        if scope_type == "unknown":
            raise RuntimeError(
                "Could not auto-detect scope type. Pass --scope-type explicitly."
            )

    print("[scope] connecting...")
    scope = cw.scope(sn=scope_sn) if scope_sn else cw.scope()
    scope_settings = setup_scope(
        scope, scope_type=scope_type,
        samples=args.samples, gain_db=args.gain_db,
        target_freq=args.target_freq, adc_mul=args.adc_mul,
    )
    print(f"[scope] settings: {json.dumps(scope_settings, indent=None)}")

    print("[target] connecting...")
    target_kwargs = {"sn": target_sn} if target_sn else {}
    if args.no_program:
        target = cw.target(scope, cw.targets.CW305, **target_kwargs)
    else:
        print(f"[target] programming bitfile: {bitpath}")
        target = cw.target(scope, cw.targets.CW305, bsfile=str(bitpath), **target_kwargs)

    fpga_id = read_u8(target, REG_ID)
    print(f"[target] ID register = 0x{fpga_id:02x} (expect 0xc4)")
    if fpga_id != 0xC4:
        print("[target] WARNING: ID mismatch — wrapper may not be the v4 directwrite build")

    out_dir = make_results_dir(args.label)
    print(f"[out] results dir: {out_dir}")

    try:
        traces, b_arr, groups, out1_arr, out2_arr = capture_loop(
            scope, target,
            n_traces=args.num_traces, samples=args.samples,
            a=args.a, k=args.k, mode=args.mode, mode2=args.mode2,
            b_fixed=args.b_fixed, q=q,
            seed=args.seed,
            trigger_mode=args.trigger_mode,
        )
    finally:
        try:
            scope.dis()
        except Exception:
            pass
        try:
            target.dis()
        except Exception:
            pass

    np.save(out_dir / "traces.npy", traces)
    np.savez(
        out_dir / "inputs.npz",
        a=np.full(args.num_traces, args.a, dtype=np.uint32),
        b=b_arr,
        k=np.full(args.num_traces, args.k, dtype=np.uint16),
        mode=np.full(args.num_traces, args.mode, dtype=np.uint8),
        mode2=np.full(args.num_traces, args.mode2, dtype=np.uint8),
        group=groups,
        out1=out1_arr,
        out2=out2_arr,
    )

    metadata = {
        "timestamp_utc":   dt.datetime.utcnow().isoformat() + "Z",
        "label":           args.label,
        "num_traces":      args.num_traces,
        "samples":         args.samples,
        "scope_serial":    scope_sn,
        "target_serial":   target_sn,
        "excluded_serial": EXCLUDE_SCOPE_SERIAL,
        "scope_settings":  scope_settings,
        "trigger_mode":    args.trigger_mode,
        "fixed_inputs":    {
            "a":     f"0x{args.a:08x}",
            "k":     args.k,
            "mode":  args.mode,
            "mode2": args.mode2,
            "q":     q,
        },
        "secret_strategy": {
            "variable":     "b",
            "fixed_value":  f"0x{args.b_fixed & 0xFFFFFFFF:08x}",
            "fixed_mod_q":  int(args.b_fixed % q),
            "random_range": [0, q],
        },
        "seed":         args.seed,
        "bitfile":      str(bitpath),
        "bitfile_md5":  md5_of(bitpath),
        "group_counts": {
            "A_fixed":  int(np.sum(groups == 0)),
            "B_random": int(np.sum(groups == 1)),
        },
    }
    with open(out_dir / "metadata.json", "w") as f:
        json.dump(metadata, f, indent=2)

    print(f"[out] traces.npy     shape={traces.shape}  dtype={traces.dtype}  "
          f"size={traces.nbytes/1e6:.1f} MB")
    print(f"[out] group counts   A(fixed)={metadata['group_counts']['A_fixed']}  "
          f"B(random)={metadata['group_counts']['B_random']}")
    print(f"[out] metadata.json  written")
    print(f"\n  next:  python3 host/tvla.py {out_dir}\n")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\n[interrupted]", file=sys.stderr)
        sys.exit(130)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)
