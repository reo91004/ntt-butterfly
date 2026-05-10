#!/usr/bin/env python3
"""
Diagnose 'no trigger seen' / clock issues for the unified_butterfly2 SCA setup.

The script walks through the connect chain step by step, prints the result of each
probe, and never permanently changes hardware state. It exists to localize a failure
to one of:

  Stage A — scope connection / clock lock
  Stage B — FPGA bitstream identity (ID register, write/read echo)
  Stage C — direct_write_count incrementing on USB writes
  Stage D — busy/done state machine transitions on a butterfly start
  Stage E — scope.capture() rising-edge detection on tio4

Run with the sca venv active.

  python3 host/diag_trigger.py [--bitfile path] [--no-program]

If --bitfile is omitted, the symlink at bitstream/cw305_unified_butterfly2_top_v4.bit
is used.
"""

import argparse
import sys
import time
from pathlib import Path

from sca_config import (
    REG_A, REG_B, REG_K, REG_CTRL, REG_STATUS, REG_OUT1, REG_OUT2,
    REG_WRCOUNT, REG_LAST_ADDR, REG_LAST_BYTE, REG_LAST_DATA, REG_FE_WRCOUNT,
    REG_ID, DONE_MASK, BUSY_MASK,
    EXCLUDE_SCOPE_SERIAL,
)


def banner(label):
    print()
    print("=" * 72)
    print(f"  {label}")
    print("=" * 72)


def find_husky_serial():
    import chipwhisperer as cw
    devs = cw.list_devices() or []
    candidates = []
    for d in devs:
        name = (d.get("name") or "").lower()
        sn = (d.get("sn") or d.get("serial") or "").lower()
        if "husky" in name and sn != EXCLUDE_SCOPE_SERIAL.lower():
            candidates.append((sn, name))
    if not candidates:
        return None
    return candidates[0][0]


def find_lite_serial():
    import chipwhisperer as cw
    devs = cw.list_devices() or []
    for d in devs:
        name = (d.get("name") or "").lower()
        sn = (d.get("sn") or d.get("serial") or "").lower()
        if "lite" in name and sn != EXCLUDE_SCOPE_SERIAL.lower():
            return sn
    return None


def find_target_serial():
    import chipwhisperer as cw
    devs = cw.list_devices() or []
    for d in devs:
        name = (d.get("name") or "").upper()
        sn = (d.get("sn") or d.get("serial") or "").lower()
        if "CW305" in name:
            return sn
    return None


def setup_scope_safe(scope, scope_kind, target_freq=96_000_000.0, adc_mul=2):
    """CW305 usb_clk is ~96 MHz when healthy. adc_mul=2 -> 192 MHz ADC, safe."""
    scope.gain.db          = 25.0
    scope.adc.samples      = 2000
    scope.adc.offset       = 0
    scope.adc.basic_mode   = "rising_edge"
    scope.adc.timeout      = 1
    scope.trigger.triggers = "tio4"
    scope.io.tio1          = "serial_rx"
    scope.io.tio2          = "serial_tx"
    scope.io.hs2           = "disabled"
    if scope_kind in ("husky-plus", "husky"):
        scope.clock.clkgen_src  = "extclk"
        scope.clock.clkgen_freq = float(target_freq)
        scope.clock.adc_mul     = int(adc_mul)
    else:
        scope.clock.adc_src = "extclk_x4"
    time.sleep(0.3)


def measure_external_clock(scope):
    if not hasattr(scope.clock, "freq_ctr_src"):
        return None
    try:
        scope.clock.freq_ctr_src = "extclk"
    except Exception as e:
        return f"freq_ctr_src error: {e}"
    time.sleep(0.3)
    try:
        return float(scope.clock.freq_ctr)
    except Exception as e:
        return f"freq_ctr error: {e}"


def read_pll_state(scope, scope_kind):
    info = {}
    if scope_kind in ("husky-plus", "husky"):
        for attr in ("adc_locked", "clkgen_locked"):
            if hasattr(scope.clock, attr):
                try:
                    info[attr] = bool(getattr(scope.clock, attr))
                except Exception as e:
                    info[attr] = f"err: {e}"
        for attr in ("clkgen_freq", "adc_freq", "adc_mul"):
            if hasattr(scope.clock, attr):
                try:
                    info[attr] = float(getattr(scope.clock, attr))
                except Exception as e:
                    info[attr] = f"err: {e}"
    else:
        for attr in ("adc_src",):
            if hasattr(scope.clock, attr):
                info[attr] = str(getattr(scope.clock, attr))
    return info


def fpga_read_byte(target, addr):
    raw = target.fpga_read(addr, 1)
    return int(raw[0]) & 0xFF


def fpga_write_bytes(target, addr, data):
    target.fpga_write(addr, list(data))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--bitfile",
                   default=str(Path(__file__).resolve().parent.parent /
                               "bitstream" / "cw305_unified_butterfly2_top_v4.bit"))
    p.add_argument("--no-program", action="store_true")
    p.add_argument("--scope-sn", default=None)
    p.add_argument("--target-freq", type=float, default=96_000_000.0,
                   help="Expected target usb_clk frequency. Healthy CW305 = 96 MHz.")
    p.add_argument("--adc-mul", type=int, default=2,
                   help="Husky ADC multiplier; 96e6 * 2 = 192 MHz ADC, safe.")
    args = p.parse_args()

    import chipwhisperer as cw

    bitpath = Path(args.bitfile).expanduser().resolve()
    if not args.no_program and not bitpath.exists():
        print(f"ERROR: bitfile not found: {bitpath}", file=sys.stderr)
        return 2

    # ----- Stage A: scope connect + clock lock -----
    banner("Stage A — scope connect + clock lock")
    scope_sn = args.scope_sn or find_husky_serial() or find_lite_serial()
    if not scope_sn:
        print("ERROR: no eligible scope found", file=sys.stderr)
        return 2

    devs = cw.list_devices() or []
    scope_name = next(
        (d.get("name") or "" for d in devs
         if (d.get("sn") or d.get("serial") or "").lower() == scope_sn.lower()),
        ""
    )
    print(f"  scope: {scope_name}  sn={scope_sn}")

    scope_kind = "lite"
    if "Husky-Plus" in scope_name:
        scope_kind = "husky-plus"
    elif "Husky" in scope_name:
        scope_kind = "husky"
    elif "Pro" in scope_name:
        scope_kind = "pro"
    print(f"  scope_kind = {scope_kind}")

    scope = cw.scope(sn=scope_sn)
    setup_scope_safe(scope, scope_kind, args.target_freq, args.adc_mul)
    pll = read_pll_state(scope, scope_kind)
    print(f"  PLL state: {pll}")

    # ----- target connect (with optional reprogram) -----
    banner("Stage B — target connect")
    target_sn = find_target_serial()
    print(f"  CW305 sn={target_sn}")
    tk = {"sn": target_sn} if target_sn else {}
    if args.no_program:
        target = cw.target(scope, cw.targets.CW305, **tk)
        print("  (skipped programming)")
    else:
        print(f"  programming: {bitpath}")
        target = cw.target(scope, cw.targets.CW305, bsfile=str(bitpath), **tk)

    fpga_id = fpga_read_byte(target, REG_ID)
    print(f"  REG_ID  (0x7E) = 0x{fpga_id:02x}   (expect 0xC4)")

    # ----- external clock measurement (after target programmed) -----
    banner("Stage A.2 — measure external clock (target now driving usb_clk)")
    ext = measure_external_clock(scope)
    print(f"  scope.clock.freq_ctr = {ext}")
    pll = read_pll_state(scope, scope_kind)
    print(f"  PLL state after measurement: {pll}")

    # ----- Stage B continued: register read/write echo -----
    banner("Stage C — register R/W + direct_write_count")
    pattern = [0xEF, 0xBE, 0xAD, 0xDE]
    fpga_write_bytes(target, REG_A, pattern)
    a_back = list(target.fpga_read(REG_A, 4))
    print(f"  REG_A wrote {pattern} -> read back {a_back}  ({'OK' if a_back == pattern else 'MISMATCH'})")

    wr_before = fpga_read_byte(target, REG_WRCOUNT)
    fe_before = fpga_read_byte(target, REG_FE_WRCOUNT)
    print(f"  before extra writes: direct_wr_count=0x{wr_before:02x}  fe_wr_count=0x{fe_before:02x}")

    for i in range(4):
        fpga_write_bytes(target, REG_B, [i, 0, 0, 0])

    wr_after = fpga_read_byte(target, REG_WRCOUNT)
    fe_after = fpga_read_byte(target, REG_FE_WRCOUNT)
    last_addr = fpga_read_byte(target, REG_LAST_ADDR)
    last_byte = fpga_read_byte(target, REG_LAST_BYTE)
    last_data = fpga_read_byte(target, REG_LAST_DATA)
    print(f"  after  4 REG_B writes: direct_wr_count=0x{wr_after:02x}  fe_wr_count=0x{fe_after:02x}")
    print(f"  last write seen by FPGA: addr=0x{last_addr:02x} byte=0x{last_byte:02x} data=0x{last_data:02x}")
    if wr_after == wr_before:
        print("  WARNING: direct_write_count did not increment — USB writes are not "
              "reaching the FPGA wrapper.")
    else:
        print(f"  direct_wr_count delta = {(wr_after - wr_before) & 0xFF}  (expected ≥4)")

    # ----- Stage D: status state machine -----
    banner("Stage D — busy/done state on a butterfly run")
    fpga_write_bytes(target, REG_A,    [0xBE, 0xBA, 0xFE, 0xCA])  # a = 0xCAFEBABE
    fpga_write_bytes(target, REG_B,    [0x40, 0x00, 0x00, 0x00])  # b = 64
    fpga_write_bytes(target, REG_K,    [0x10, 0x00])              # k = 16
    fpga_write_bytes(target, REG_CTRL, [0x01])                    # mode=1, mode2=0

    # clear any stale done
    fpga_write_bytes(target, REG_STATUS, [0x02])
    s_idle = fpga_read_byte(target, REG_STATUS)
    print(f"  status before start: 0x{s_idle:02x}  busy={1 if s_idle & BUSY_MASK else 0}  done={1 if s_idle & DONE_MASK else 0}")

    fpga_write_bytes(target, REG_STATUS, [0x01])  # start
    seen_busy = False
    seen_done = False
    seq = []
    for i in range(50):
        s = fpga_read_byte(target, REG_STATUS)
        seq.append(s)
        if s & BUSY_MASK:
            seen_busy = True
        if s & DONE_MASK:
            seen_done = True
            break
        time.sleep(0.0002)
    print(f"  status sequence (first 10): {[f'0x{x:02x}' for x in seq[:10]]}")
    print(f"  busy seen: {seen_busy}    done seen: {seen_done}")
    if not seen_busy:
        print("  WARNING: busy_reg never went high — start register write was not "
              "processed by the wrapper. Possible old/cached bitstream on the FPGA.")
    elif not seen_done:
        print("  WARNING: done bit never set — the butterfly is hanging.")
    else:
        print("  OK: state machine transitioned start → busy → done")

    # ----- Stage E: scope captures the trigger -----
    banner("Stage E — scope arm + start, can the trigger fire?")
    fpga_write_bytes(target, REG_STATUS, [0x02])  # clear done
    time.sleep(0.005)

    fpga_write_bytes(target, REG_A,    [0xBE, 0xBA, 0xFE, 0xCA])
    fpga_write_bytes(target, REG_B,    [0x42, 0x00, 0x00, 0x00])
    fpga_write_bytes(target, REG_K,    [0x10, 0x00])
    fpga_write_bytes(target, REG_CTRL, [0x01])

    scope.arm()
    fpga_write_bytes(target, REG_STATUS, [0x01])

    # Wait for FPGA done
    t0 = time.time()
    while time.time() - t0 < 0.5:
        if fpga_read_byte(target, REG_STATUS) & DONE_MASK:
            break
        time.sleep(0.0002)

    ret = scope.capture()
    print(f"  scope.capture() -> {ret}   ({'TIMEOUT (no trigger)' if ret else 'OK (trigger seen)'})")

    if not ret:
        try:
            wave = scope.get_last_trace()
            print(f"  trace shape={wave.shape}  min={wave.min():.4f}  max={wave.max():.4f}")
        except Exception as e:
            print(f"  get_last_trace error: {e}")

    # ----- Stage E.2: try host-toggle as a control experiment -----
    if hasattr(target, "usb_trigger_toggle"):
        banner("Stage E.2 — control experiment: host-toggle trigger")
        fpga_write_bytes(target, REG_STATUS, [0x02])
        time.sleep(0.005)
        # Use a wider sample window for this mode (USB latency margin).
        scope.adc.samples = 50000
        scope.arm()
        target.usb_trigger_toggle()
        fpga_write_bytes(target, REG_STATUS, [0x01])
        t0 = time.time()
        while time.time() - t0 < 0.5:
            if fpga_read_byte(target, REG_STATUS) & DONE_MASK:
                break
            time.sleep(0.0002)
        ret2 = scope.capture()
        print(f"  scope.capture() (host-toggle) -> {ret2}   "
              f"({'TIMEOUT' if ret2 else 'OK (trigger seen)'})")

    # ----- cleanup -----
    banner("Disconnecting")
    try:
        scope.dis()
    except Exception:
        pass
    try:
        target.dis()
    except Exception:
        pass
    print("  done.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\n[interrupted]", file=sys.stderr)
        sys.exit(130)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        import traceback; traceback.print_exc()
        sys.exit(1)
