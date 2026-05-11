#!/usr/bin/env python3
"""
Bulk-capture power traces from the CW305 unified_butterfly2 target for TVLA.

Supports both ChipWhisperer-Husky / Husky-Plus and ChipWhisperer-Lite / Pro
by branching the clock-config API. Scope type is auto-detected from
cw.list_devices() but can be overridden with --scope-type.

Trigger handling has two modes (see --trigger-mode):
  internal     (default, recommended)
       Assumes the wrapper drives tio_trigger from trigger_reg
       (pUSE_INTERNAL_TRIGGER=1 in the CW305 wrapper).
       Capture is then perfectly aligned: rising edge = butterfly start.
  host-toggle  (legacy / fallback)
       For an old wrapper, or a rebuild with pUSE_INTERNAL_TRIGGER=0.
       Uses target.usb_trigger_toggle() before the start register write.
       Alignment suffers the USB-transaction gap (~125 us on Husky,
       ~1 ms on Lite); use a wider --samples and post-process align.

Per trace:
  1. choose group (A=fixed-b, B=random-b)
  2. write inputs (a, b, k, ctrl) over USB
     - with --b-load-policy random-then-scrub, b is first written with the
       fixed/random TVLA value, then REG_B is overwritten with a fixed scrub
       value immediately before arming the scope
  3. arm scope, write start, wait for done
  4. read trace from scope, read out1/out2 from target
  5. accumulate

Stored under  results/<timestamp>_<label>/  :
    traces.npy        (N, samples) float32
    inputs.npz        a, b, b_first_write, b_effective_start, k, mode, mode2,
                      b_preload_write, b_core_start, b_mask_share0,
                      b_mask_share1, group, out1, out2 (all per-trace)
    metadata.json     experiment + scope settings + device serials
"""

import argparse
import datetime as dt
import hashlib
import json
import math
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
    DEFAULT_ADC_MUL_BY_SCOPE, HUSKY_MAX_ADC_HZ, LITE_PRO_MAX_ADC_HZ,
    CLOCK_WARN_RATIO,
)


# ----------------------------------------------------------------------------
# Device discovery + scope-type detection
# ----------------------------------------------------------------------------

def _device_name(d):
    return d.get("name") or d.get("type") or ""

def _device_sn(d):
    return (d.get("sn") or d.get("serial") or "").lower()

def _is_cw305_target(d):
    return "CW305" in _device_name(d).upper()

def _clean_optional_sn(sn):
    if sn is None:
        return ""
    sn = str(sn).strip().lower()
    return "" if sn in ("", "none", "no", "false", "-") else sn

def _normalized_name(name):
    return str(name or "").lower().replace("_", "-").replace(" ", "-")

def scope_type_from_name(name):
    """Return one of {'husky-plus', 'husky', 'lite', 'pro', 'nano', 'unknown'}."""
    norm = _normalized_name(name)
    if "husky-plus" in norm:
        return "husky-plus"
    if "husky" in norm:
        return "husky"
    if "lite" in norm:
        return "lite"
    if "pro" in norm:
        return "pro"
    if "nano" in norm:
        return "nano"

    # Fallback to exact NewAE prefixes for older cw.list_devices() outputs.
    for kind in ("husky-plus", "husky", "lite", "pro", "nano"):
        for prefix in SCOPE_NAMES[kind]:
            if str(name or "").startswith(prefix):
                return kind
    return "unknown"

def _is_scope(d):
    return (not _is_cw305_target(d)) and scope_type_from_name(_device_name(d)) != "unknown"

def list_chipwhisperer_devices():
    import chipwhisperer as cw
    if hasattr(cw, "list_devices"):
        try:
            return cw.list_devices() or []
        except Exception as e:
            print(f"[devs] cw.list_devices() failed: {e}")
    return []

def print_devices(devices, exclude_sn):
    exclude_sn = _clean_optional_sn(exclude_sn)
    print(f"[devs] {len(devices)} ChipWhisperer device(s) detected:")
    for d in devices:
        sn   = _device_sn(d)
        name = _device_name(d) or "?"
        kind = "scope " if _is_scope(d) else ("target" if _is_cw305_target(d) else "???   ")
        marker = "  (EXCLUDED)" if exclude_sn and sn == exclude_sn else ""
        print(f"        [{kind}] {name:30s} sn={sn}{marker}")

def find_scope_serial(devices, exclude_sn, override=None):
    if override:
        print(f"[scope] using user-specified serial: {override}")
        return override
    exclude_sn = _clean_optional_sn(exclude_sn)
    candidates = [
        _device_sn(d) for d in devices
        if _is_scope(d) and _device_sn(d) != exclude_sn
    ]
    if len(candidates) == 1:
        print(f"[scope] auto-selected sn={candidates[0]}")
        return candidates[0]
    if len(candidates) == 0:
        excluded_msg = f" (excluded {exclude_sn})" if exclude_sn else ""
        raise RuntimeError(
            f"No eligible ChipWhisperer scope{excluded_msg}. Pass --scope-sn."
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
    return scope_type_from_name(name)


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


def write_experiment_control(
    target, mode, mode2, use_b_preload, force_core_b_zero,
    trigger_delay_cycles, route_b_write_to_preload=False,
):
    ctrl = (
        (mode & 1) |
        ((mode2 & 1) << 1) |
        ((1 if use_b_preload else 0) << 2) |
        ((1 if force_core_b_zero else 0) << 3) |
        ((1 if route_b_write_to_preload else 0) << 4) |
        ((int(trigger_delay_cycles) & 0x07) << 5)
    )
    write_u8(target, REG_CTRL, ctrl)
    return ctrl


def b_write_plan(b_values, b_load_policy, b_scrub_mod_q):
    """Return (first REG_B write, value present at start) arrays.

    inputs.npz keeps `b` as the logical TVLA grouping value. These two arrays
    record what was actually sent to the target, which is essential for F11.
    """
    b_values = np.asarray(b_values, dtype=np.uint32)
    scrub = np.uint32(b_scrub_mod_q)

    if b_load_policy == "normal":
        return b_values.copy(), b_values.copy()
    if b_load_policy == "constant":
        arr = np.full(b_values.shape, scrub, dtype=np.uint32)
        return arr.copy(), arr.copy()
    if b_load_policy == "random-then-scrub":
        first = b_values.copy()
        effective = np.full(b_values.shape, scrub, dtype=np.uint32)
        return first, effective

    raise ValueError(f"unknown b_load_policy={b_load_policy!r}")


def b_preload_plan(b_values, b_preload_policy, rng, q):
    b_values = np.asarray(b_values, dtype=np.uint32)
    zero = np.zeros(b_values.shape, dtype=np.uint32)
    if b_preload_policy == "none":
        return zero.copy(), zero.copy(), zero.copy()
    if b_preload_policy == "logical":
        return b_values.copy(), zero.copy(), zero.copy()
    if b_preload_policy in ("masked-share0", "masked-share1"):
        share0 = rng.integers(0, q, size=b_values.shape, dtype=np.uint32)
        share1 = (
            (b_values.astype(np.int64) - share0.astype(np.int64)) % int(q)
        ).astype(np.uint32)
        if b_preload_policy == "masked-share0":
            return share0.copy(), share0, share1
        return share1.copy(), share0, share1
    raise ValueError(f"unknown b_preload_policy={b_preload_policy!r}")


def b_core_start_plan(b_effective_start, b_preload_write, use_b_preload, force_core_b_zero):
    if force_core_b_zero:
        return np.zeros(np.asarray(b_effective_start).shape, dtype=np.uint32)
    if use_b_preload:
        return np.asarray(b_preload_write, dtype=np.uint32).copy()
    return np.asarray(b_effective_start, dtype=np.uint32).copy()


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

def resolve_adc_mul(scope_type, requested_adc_mul, target_freq):
    """Choose a board-safe ADC multiplier.

    requested_adc_mul of 0 or None means "auto": Husky/Husky-Plus use x2,
    CW-Lite/Pro use x1 because the 96 MHz CW305 clock is already near their
    ADC limit.
    """
    requested_auto = requested_adc_mul in (None, 0)
    adc_mul = (
        DEFAULT_ADC_MUL_BY_SCOPE.get(scope_type, DEFAULT_ADC_MUL)
        if requested_auto else int(requested_adc_mul)
    )

    if scope_type in ("lite", "pro"):
        if adc_mul not in (1, 4):
            print(f"[scope] WARNING: {scope_type} supports extclk_x1/x4 here; "
                  f"adc_mul={adc_mul} is unsafe for portable runs, using x1.")
            adc_mul = 1
        estimated_adc_hz = float(target_freq) * adc_mul
        if estimated_adc_hz > LITE_PRO_MAX_ADC_HZ:
            print(f"[scope] WARNING: {scope_type} estimated ADC clock "
                  f"{estimated_adc_hz/1e6:.1f} MHz exceeds the portable "
                  f"{LITE_PRO_MAX_ADC_HZ/1e6:.0f} MHz limit; using extclk_x1. "
                  f"Only use x4 when the target clock is deliberately slowed.")
            adc_mul = 1
    elif scope_type in ("husky", "husky-plus"):
        estimated_adc_hz = float(target_freq) * adc_mul
        if estimated_adc_hz > HUSKY_MAX_ADC_HZ:
            print(f"[scope] WARNING: estimated Husky ADC clock "
                  f"{estimated_adc_hz/1e6:.1f} MHz exceeds "
                  f"{HUSKY_MAX_ADC_HZ/1e6:.0f} MHz; lower --adc-mul.")

    source = "auto" if requested_auto else "user"
    print(f"[scope] adc_mul={adc_mul} ({source}, scope_type={scope_type})")
    return int(adc_mul), source

def measure_external_clock(scope):
    """Best-effort frequency counter read for the CW305 clock on the CW connector."""
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

def add_clock_report(scope_settings, measured_target_freq, expected_target_freq):
    adc_mul = float(scope_settings.get("adc_mul", 1))
    target_freq_for_est = float(expected_target_freq)

    if isinstance(measured_target_freq, (int, float)) and measured_target_freq > 0:
        measured = float(measured_target_freq)
        scope_settings["measured_target_freq_hz"] = measured
        target_freq_for_est = measured
        err = abs(measured - float(expected_target_freq)) / max(float(expected_target_freq), 1.0)
        scope_settings["target_freq_error_ratio"] = err
        msg = (f"[clock] measured target clock = {measured/1e6:.3f} MHz "
               f"(expected {float(expected_target_freq)/1e6:.3f} MHz)")
        if err > CLOCK_WARN_RATIO:
            msg += "  WARNING: large clock mismatch; check cabling/bitstream or pass --target-freq."
        print(msg)
    elif measured_target_freq is not None:
        scope_settings["measured_target_freq_hz"] = str(measured_target_freq)
        print(f"[clock] target clock measurement unavailable: {measured_target_freq}")
    else:
        scope_settings["measured_target_freq_hz"] = None
        print("[clock] scope has no freq counter; using --target-freq for metadata")

    scope_settings["target_freq_hz"] = float(expected_target_freq)
    scope_settings["adc_freq_est_hz"] = target_freq_for_est * adc_mul
    scope_settings["samples_per_target_cycle"] = adc_mul
    return scope_settings

def apply_sample_cycles(scope, scope_settings, sample_cycles):
    if sample_cycles is None:
        scope_settings["samples"] = int(scope.adc.samples)
        scope_settings["sample_cycles_est"] = (
            float(scope.adc.samples) /
            max(float(scope_settings.get("samples_per_target_cycle", 1.0)), 1e-9)
        )
        return int(scope.adc.samples)

    samples_per_cycle = float(scope_settings.get("samples_per_target_cycle", 1.0))
    samples = max(1, int(math.ceil(float(sample_cycles) * samples_per_cycle)))
    scope.adc.samples = samples
    actual = int(scope.adc.samples)
    scope_settings["samples"] = actual
    scope_settings["sample_cycles_requested"] = float(sample_cycles)
    scope_settings["sample_cycles_est"] = actual / max(samples_per_cycle, 1e-9)
    print(f"[scope] sample window: {sample_cycles:g} target cycles -> "
          f"{actual} ADC samples ({samples_per_cycle:g} sample/cycle)")
    return actual

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
            "adc_freq_est_hz": float(target_freq) * int(adc_mul),
            "samples_per_target_cycle": int(adc_mul),
            "pll_locked":  bool(ok),
        })
    elif scope_type in ("lite", "pro"):
        # CW-Lite / CW-Pro single-string API. Only x1 and x4 are universally supported.
        scope.clock.adc_src = f"extclk_x{adc_mul}"
        settings.update({
            "adc_src": str(scope.clock.adc_src),
            "adc_mul": int(adc_mul),
            "adc_freq_est_hz": float(target_freq) * int(adc_mul),
            "samples_per_target_cycle": int(adc_mul),
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
    vary="b",
    k_max=256,
    b_load_policy="normal",
    b_scrub_mod_q=None,
    b_preload_policy="none",
    use_b_preload=False,
    force_core_b_zero=False,
    trigger_delay_cycles=0,
    pre_arm_delay_ms=0.0,
    poll_interval=0.0005, poll_timeout=0.5,
):
    rng = np.random.default_rng(seed)
    if b_scrub_mod_q is None:
        b_scrub_mod_q = int(b_fixed % q)
    b_scrub_mod_q = int(b_scrub_mod_q % q)

    if vary == "b":
        # TVLA-style: b varies (fixed/random groups), k stays fixed.
        groups   = rng.integers(0, 2, size=n_traces, dtype=np.uint8)  # 0=fixed,1=random
        rand_b   = rng.integers(0, q, size=n_traces, dtype=np.uint32)
        b_values = np.where(groups == 0, np.uint32(b_fixed % q), rand_b).astype(np.uint32)
        k_values = np.full(n_traces, k, dtype=np.uint16)
    elif vary == "k":
        # CPA-style: k varies uniformly (public attacker input);
        #   b stays fixed at b_fixed (the "secret" the attacker tries to recover);
        #   group is all 0 (no TVLA grouping).
        groups   = np.zeros(n_traces, dtype=np.uint8)
        b_values = np.full(n_traces, np.uint32(b_fixed % q), dtype=np.uint32)
        k_values = rng.integers(0, k_max, size=n_traces, dtype=np.uint16)
    else:
        raise ValueError(f"vary must be 'b' or 'k', not {vary!r}")

    b_first_write, b_effective_start = b_write_plan(
        b_values, b_load_policy, b_scrub_mod_q
    )
    b_preload_write, b_mask_share0, b_mask_share1 = b_preload_plan(
        b_values, b_preload_policy, rng, q
    )
    b_core_start = b_core_start_plan(
        b_effective_start, b_preload_write, use_b_preload, force_core_b_zero
    )

    traces   = np.empty((n_traces, samples), dtype=np.float32)
    out1_arr = np.empty(n_traces, dtype=np.uint32)
    out2_arr = np.empty(n_traces, dtype=np.uint32)

    if trigger_mode == "host-toggle":
        if not hasattr(target, "usb_trigger_toggle"):
            raise RuntimeError(
                "trigger-mode=host-toggle requires target.usb_trigger_toggle(). "
                "Update chipwhisperer or use --trigger-mode internal."
            )

    exp_ctrl = write_experiment_control(
        target, mode, mode2,
        use_b_preload, force_core_b_zero, trigger_delay_cycles,
        route_b_write_to_preload=False,
    )

    if vary == "b":
        secret_summary = (f"vary=b  group A=fixed b={hex(b_fixed % q)}, "
                          f"group B=random b in [0,{q})  (a={hex(a)}, k fixed at {k})")
    else:
        secret_summary = (f"vary=k  k uniform in [0,{k_max})  "
                          f"(a={hex(a)}, b fixed at {hex(b_fixed % q)} = the SECRET)")
    if b_load_policy == "normal":
        load_summary = "REG_B at start follows the logical b value"
    elif b_load_policy == "constant":
        load_summary = f"REG_B write forced to fixed scrub={hex(b_scrub_mod_q)}"
    else:
        load_summary = (f"REG_B first follows logical b, then is scrubbed to "
                        f"{hex(b_scrub_mod_q)} before scope.arm()")
    print(f"[capture] starting {n_traces} traces, {samples} samples each "
          f"(trigger={trigger_mode}, {secret_summary})")
    print(f"[capture] b_load_policy={b_load_policy}: {load_summary}")
    print(f"[capture] preload_policy={b_preload_policy}, "
          f"use_b_preload={use_b_preload}, force_core_b_zero={force_core_b_zero}, "
          f"trigger_delay_cycles={trigger_delay_cycles}, exp_ctrl=0x{exp_ctrl:02x}")
    t0 = time.time()
    fail_count = 0

    for i in range(n_traces):
        b_first = int(b_first_write[i])
        b_effective = int(b_effective_start[i])
        b_preload = int(b_preload_write[i])
        k_val = int(k_values[i])

        if b_preload_policy != "none":
            write_experiment_control(
                target, mode, mode2,
                use_b_preload, force_core_b_zero, trigger_delay_cycles,
                route_b_write_to_preload=True,
            )
            write_u32(target, REG_B, b_preload)
            write_experiment_control(
                target, mode, mode2,
                use_b_preload, force_core_b_zero, trigger_delay_cycles,
                route_b_write_to_preload=False,
            )

        write_inputs(target, a, b_first, k_val, mode, mode2)

        # F11 diagnostic path: preserve the fixed-vs-random group labels and
        # the initial REG_B write, but make the last REG_B write before arm
        # fixed. If the TVLA peak disappears, the previous peak was dominated
        # by the input/write path state rather than the arithmetic core.
        if b_load_policy in ("constant", "random-then-scrub"):
            write_u32(target, REG_B, b_effective)

        write_experiment_control(
            target, mode, mode2,
            use_b_preload, force_core_b_zero, trigger_delay_cycles,
            route_b_write_to_preload=False,
        )

        if pre_arm_delay_ms > 0:
            time.sleep(pre_arm_delay_ms / 1000.0)

        scope.arm()

        if trigger_mode == "host-toggle":
            target.usb_trigger_toggle()

        # In 'internal' mode, this register write schedules the trigger event:
        # the wrapper raises trigger_reg -> tio_trigger after the configured
        # trigger delay.
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
    return (
        traces, b_values, groups, out1_arr, out2_arr, k_values,
        b_first_write, b_effective_start, b_preload_write, b_core_start,
        b_mask_share0, b_mask_share1,
    )


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
    p.add_argument("--exclude-scope-sn", default=EXCLUDE_SCOPE_SERIAL,
                   help="Scope serial to skip during auto-detect; use 'none' to disable")
    p.add_argument("--scope-type", default="auto",
                   choices=["auto", "husky-plus", "husky", "lite", "pro"],
                   help="Scope kind. 'auto' detects from cw.list_devices() name field")
    p.add_argument("--trigger-mode", default="internal",
                   choices=["internal", "host-toggle"],
                   help="'internal' = wrapper drives tio_trigger from trigger_reg "
                        "(re-synthesis required, recommended). "
                        "'host-toggle' = legacy bitstream where tio_trigger=usb_trigger.")
    p.add_argument("--num-traces", type=int, default=2000)
    p.add_argument("--samples", type=int, default=400,
                   help="ADC samples per trace. With --trigger-mode internal, the "
                        "7-cycle core result appears near the start; use "
                        "--sample-cycles for portable cycle-based windows. With "
                        "host-toggle you need much wider (e.g. 50000) to absorb "
                        "USB-latency gap.")
    p.add_argument("--sample-cycles", type=float, default=None,
                   help="Set capture length in target-clock cycles instead of raw ADC "
                        "samples. The script converts using the scope-specific ADC "
                        "multiplier (Husky auto=x2, Lite/Pro auto=x1).")
    p.add_argument("--gain-db",     type=float, default=25.0)
    p.add_argument("--target-freq", type=float, default=DEFAULT_TARGET_FREQ_HZ,
                   help="External clock frequency (CW305 usb_clk, Hz). "
                        "Used by Husky to lock its PLL.")
    p.add_argument("--adc-mul", type=int, default=0,
                   help="ADC oversample multiplier on top of target clock. "
                        "0=auto: Husky/Husky-Plus x2, CW-Lite/Pro x1.")
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
    p.add_argument("--seed", type=lambda x: int(x, 0), default=0xC0FFEE,
                   help="RNG seed for group/randomness")
    p.add_argument("--vary", choices=["b", "k"], default="b",
                   help="'b' (default, TVLA): fixed-vs-random b, k fixed.  "
                        "'k' (CPA): k varies, b fixed (b_fixed is the secret).")
    p.add_argument("--k-max", type=int, default=256,
                   help="When --vary k, sample k uniformly from [0, k-max).")
    p.add_argument("--b-load-policy",
                   choices=["normal", "constant", "random-then-scrub"],
                   default="normal",
                   help="How REG_B is loaded before each trace. 'normal' writes "
                        "the logical TVLA b value. 'constant' preserves group "
                        "labels but always writes --b-scrub-value. "
                        "'random-then-scrub' writes the logical b first, then "
                        "overwrites REG_B with --b-scrub-value before arm/start "
                        "(F11 reproduction).")
    p.add_argument("--b-scrub-value", type=lambda x: int(x, 0), default=None,
                   help="Fixed REG_B value for --b-load-policy constant or "
                        "random-then-scrub. Default is --b-fixed reduced mod q.")
    p.add_argument("--pre-arm-delay-ms", type=float, default=0.0,
                   help="Diagnostic delay after the final input/scrub write and "
                        "before scope.arm(). Use 0 for F11; fixed delays are not "
                        "a security countermeasure.")
    p.add_argument("--b-preload-policy",
                   choices=["none", "logical", "masked-share0", "masked-share1"],
                   default="none",
                   help="'logical' writes the logical TVLA b value to REG_B_PRELOAD "
                        "before the REG_B scrub path. Used for Exp G preload/scrub "
                        "core-input experiments. 'masked-share0' and "
                        "'masked-share1' split b = b0 + b1 mod q and preload one "
                        "randomized share for first-order masking diagnostics.")
    p.add_argument("--use-b-preload", action="store_true",
                   help="Start the core from REG_B_PRELOAD instead of REG_B. "
                        "Requires a bitstream with the preload wrapper registers.")
    p.add_argument("--force-core-b-zero", action="store_true",
                   help="Debug negative control: on start, force b_core=0 even if "
                        "--use-b-preload is set.")
    p.add_argument("--trigger-delay-cycles", type=int, default=0,
                   help="Delay the internal trigger this many target cycles after "
                        "the start write/input load. Used to align samples to "
                        "later core stages for isolation checks.")
    args = p.parse_args()

    bitpath = Path(args.bitfile).expanduser().resolve()
    if not bitpath.exists():
        print(f"ERROR: bitfile not found: {bitpath}", file=sys.stderr)
        return 2
    if not (0 <= args.trigger_delay_cycles <= 7):
        print("ERROR: --trigger-delay-cycles must be in [0, 7]", file=sys.stderr)
        return 2
    if args.use_b_preload and args.b_preload_policy == "none":
        print("[inputs] WARNING: --use-b-preload is set but --b-preload-policy=none; "
              "b_preload will be 0 for every trace.")
    if args.b_preload_policy.startswith("masked-") and not args.use_b_preload:
        print("[inputs] WARNING: masked preload policy selected without "
              "--use-b-preload; shares will be written but core will not use them.")

    q = KYBER_Q if args.mode2 == 0 else DILITHIUM_Q
    a_raw = args.a & 0xFFFFFFFF
    a_mod = args.a % q
    b_scrub_raw = args.b_fixed if args.b_scrub_value is None else args.b_scrub_value
    b_scrub_mod_q = int(b_scrub_raw % q)
    if a_raw != a_mod:
        print(f"[inputs] reducing a modulo q for RTL canonical input: "
              f"0x{a_raw:08x} -> {a_mod} (q={q})")
    if args.b_load_policy != "normal" and (b_scrub_raw & 0xFFFFFFFF) != b_scrub_mod_q:
        print(f"[inputs] reducing b scrub value modulo q: "
              f"0x{b_scrub_raw & 0xFFFFFFFF:08x} -> {b_scrub_mod_q} (q={q})")

    import chipwhisperer as cw

    exclude_scope_sn = _clean_optional_sn(args.exclude_scope_sn)

    devices = list_chipwhisperer_devices()
    print_devices(devices, exclude_scope_sn)
    scope_sn  = find_scope_serial(devices, exclude_scope_sn, override=args.scope_sn)
    target_sn = find_target_serial(devices, override=args.target_sn)

    scope_type = args.scope_type
    if scope_type == "auto":
        scope_type = detect_scope_type(devices, scope_sn)
        print(f"[scope] auto-detected scope_type={scope_type}")
        if scope_type == "unknown":
            raise RuntimeError(
                "Could not auto-detect scope type. Pass --scope-type explicitly."
            )

    adc_mul, adc_mul_source = resolve_adc_mul(scope_type, args.adc_mul, args.target_freq)

    print("[scope] connecting...")
    scope = cw.scope(sn=scope_sn) if scope_sn else cw.scope()

    print("[target] connecting...")
    target_kwargs = {"sn": target_sn} if target_sn else {}
    if args.no_program:
        target = cw.target(scope, cw.targets.CW305, **target_kwargs)
    else:
        print(f"[target] programming bitfile: {bitpath}")
        target = cw.target(
            scope, cw.targets.CW305,
            bsfile=str(bitpath), force=True, **target_kwargs,
        )

    fpga_id = read_u8(target, REG_ID)
    print(f"[target] ID register = 0x{fpga_id:02x} (expect 0xc4)")
    if fpga_id != 0xC4:
        print("[target] WARNING: ID mismatch — wrapper may not be the v4 directwrite build")

    scope_settings = setup_scope(
        scope, scope_type=scope_type,
        samples=args.samples, gain_db=args.gain_db,
        target_freq=args.target_freq, adc_mul=adc_mul,
    )
    scope_settings["adc_mul_source"] = adc_mul_source
    measured_target_freq = measure_external_clock(scope)
    add_clock_report(scope_settings, measured_target_freq, args.target_freq)
    capture_samples = apply_sample_cycles(scope, scope_settings, args.sample_cycles)
    print(f"[scope] settings: {json.dumps(scope_settings, indent=None)}")

    out_dir = make_results_dir(args.label)
    print(f"[out] results dir: {out_dir}")

    try:
        (
            traces, b_arr, groups, out1_arr, out2_arr, k_arr,
            b_first_arr, b_effective_arr, b_preload_arr, b_core_start_arr,
            b_mask_share0_arr, b_mask_share1_arr,
        ) = capture_loop(
            scope, target,
            n_traces=args.num_traces, samples=capture_samples,
            a=a_mod, k=args.k, mode=args.mode, mode2=args.mode2,
            b_fixed=args.b_fixed, q=q,
            seed=args.seed,
            trigger_mode=args.trigger_mode,
            vary=args.vary, k_max=args.k_max,
            b_load_policy=args.b_load_policy,
            b_scrub_mod_q=b_scrub_mod_q,
            b_preload_policy=args.b_preload_policy,
            use_b_preload=args.use_b_preload,
            force_core_b_zero=args.force_core_b_zero,
            trigger_delay_cycles=args.trigger_delay_cycles,
            pre_arm_delay_ms=args.pre_arm_delay_ms,
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
        a=np.full(args.num_traces, a_mod, dtype=np.uint32),
        a_raw=np.full(args.num_traces, a_raw, dtype=np.uint32),
        b=b_arr,
        b_first_write=b_first_arr,
        b_effective_start=b_effective_arr,
        b_preload_write=b_preload_arr,
        b_core_start=b_core_start_arr,
        b_mask_share0=b_mask_share0_arr,
        b_mask_share1=b_mask_share1_arr,
        k=k_arr,
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
        "samples":         capture_samples,
        "scope_serial":    scope_sn,
        "target_serial":   target_sn,
        "excluded_serial": exclude_scope_sn,
        "scope_settings":  scope_settings,
        "trigger_mode":    args.trigger_mode,
        "fixed_inputs":    {
            "a":     f"0x{a_mod:08x}",
            "a_raw": f"0x{a_raw:08x}",
            "a_mod_q": int(a_mod),
            "k":     args.k,
            "mode":  args.mode,
            "mode2": args.mode2,
            "q":     q,
        },
        "secret_strategy": {
            "variable":       args.vary,
            "b_fixed_value":  f"0x{args.b_fixed & 0xFFFFFFFF:08x}",
            "b_fixed_mod_q":  int(args.b_fixed % q),
            "random_b_range": [0, q] if args.vary == "b" else None,
            "random_k_range": [0, args.k_max] if args.vary == "k" else None,
        },
        "capture_protocol": {
            "b_load_policy":       args.b_load_policy,
            "b_scrub_value":       f"0x{b_scrub_raw & 0xFFFFFFFF:08x}",
            "b_scrub_mod_q":       b_scrub_mod_q,
            "b_preload_policy":    args.b_preload_policy,
            "use_b_preload":       bool(args.use_b_preload),
            "force_core_b_zero":   bool(args.force_core_b_zero),
            "trigger_delay_cycles": int(args.trigger_delay_cycles),
            "pre_arm_delay_ms":    float(args.pre_arm_delay_ms),
            "b_field_note":        "inputs['b'] is the logical TVLA grouping value; "
                                   "inputs['b_effective_start'] is the value present "
                                   "in REG_B when start is asserted; "
                                   "inputs['b_core_start'] is the value selected "
                                   "for b_core by the wrapper; "
                                   "for masked-share policies, "
                                   "b = b_mask_share0 + b_mask_share1 mod q.",
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
