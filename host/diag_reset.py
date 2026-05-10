#!/usr/bin/env python3
"""
Diagnostic: try several recovery sequences for a CW305 stuck with bad USB I/O.

The previous run showed:
  - ID register reads 0x00 instead of 0xC4
  - direct_write_count never increments
  - raw_pins reads 0x00 (control lines stuck low)
  - status register reads 0x2e (impossible for the wrapper logic)
  - host-toggle trigger DOES fire scope (so pulse path works)

This means the FPGA's USB FIFO interface is desynced from the SAM3U side.
We try, in order:
  1. plain disconnect + reconnect
  2. disconnect + sleep + reconnect (longer settling)
  3. close low-level naeusb handle
  4. re-program after each step
After every step we read REG_ID; if 0xC4, recovery succeeded.
"""

import sys
import time
from pathlib import Path

from sca_config import REG_ID


def step(label):
    print()
    print(f"--- {label} ---")


def read_id(target):
    raw = target.fpga_read(REG_ID, 1)
    return int(raw[0]) & 0xFF


def main():
    bitfile = sys.argv[1] if len(sys.argv) > 1 else \
        str(Path(__file__).resolve().parent.parent /
            "bitstream" / "cw305_unified_butterfly2_top_v4.bit")

    import chipwhisperer as cw

    devs = cw.list_devices() or []
    husky_sn = next((
        (d.get("sn") or "").lower() for d in devs
        if "husky" in (d.get("name") or "").lower()
        and (d.get("sn") or "").lower() != "50203220594a48303330373133323037"
    ), None)
    target_sn = next((
        (d.get("sn") or "").lower() for d in devs
        if "CW305" in (d.get("name") or "").upper()
    ), None)
    print(f"Husky sn={husky_sn}")
    print(f"CW305 sn={target_sn}")

    # ----- Attempt 1: simple connect + read ID -----
    step("Attempt 1: connect, program, read ID")
    scope = cw.scope(sn=husky_sn)
    target = cw.target(scope, cw.targets.CW305,
                       bsfile=bitfile,
                       sn=target_sn)
    rid = read_id(target)
    print(f"  REG_ID = 0x{rid:02x}  (expect 0xC4)")
    if rid == 0xC4:
        print("  RECOVERED on attempt 1")
        scope.dis(); target.dis()
        return 0

    # ----- Attempt 2: dis(), sleep, reconnect (no reprogram) -----
    step("Attempt 2: dis() + 1s sleep + reconnect (skip reprogram)")
    target.dis(); scope.dis()
    time.sleep(1.0)
    scope = cw.scope(sn=husky_sn)
    target = cw.target(scope, cw.targets.CW305, sn=target_sn)
    rid = read_id(target)
    print(f"  REG_ID = 0x{rid:02x}")
    if rid == 0xC4:
        print("  RECOVERED on attempt 2 (settling helped)")
        scope.dis(); target.dis()
        return 0

    # ----- Attempt 3: dis(), sleep, reconnect WITH reprogram -----
    step("Attempt 3: dis() + 1s sleep + reconnect WITH reprogram")
    target.dis(); scope.dis()
    time.sleep(1.0)
    scope = cw.scope(sn=husky_sn)
    target = cw.target(scope, cw.targets.CW305,
                       bsfile=bitfile, sn=target_sn)
    rid = read_id(target)
    print(f"  REG_ID = 0x{rid:02x}")
    if rid == 0xC4:
        print("  RECOVERED on attempt 3 (reprogram with settling)")
        scope.dis(); target.dis()
        return 0

    # ----- Attempt 4: try low-level USB-handle close -----
    step("Attempt 4: low-level naeusb close + 2s sleep + reconnect")
    try:
        target._naeusb.close()
    except Exception as e:
        print(f"  naeusb.close error (non-fatal): {e}")
    try:
        scope.dis()
    except Exception:
        pass
    time.sleep(2.0)
    scope = cw.scope(sn=husky_sn)
    target = cw.target(scope, cw.targets.CW305,
                       bsfile=bitfile, sn=target_sn)
    rid = read_id(target)
    print(f"  REG_ID = 0x{rid:02x}")
    if rid == 0xC4:
        print("  RECOVERED on attempt 4 (low-level USB reset)")
        scope.dis(); target.dis()
        return 0

    # ----- Attempt 5: read multiple times, maybe stale buffer -----
    step("Attempt 5: hammer read 20 times to clear any USB stall")
    for i in range(20):
        rid = read_id(target)
        if rid == 0xC4:
            print(f"  RECOVERED after {i+1} extra reads")
            scope.dis(); target.dis()
            return 0
        time.sleep(0.05)
    print(f"  last REG_ID = 0x{rid:02x}")

    # ----- final state report -----
    step("Final dump of all wrapper registers (interesting subset)")
    for reg, name in [
        (0x00, "REG_A_byte0"),
        (0x04, "REG_STATUS"),
        (0x70, "direct_wr_count"),
        (0x74, "raw_pins"),
        (0x75, "fe_wr_count"),
        (0x7E, "REG_ID"),
    ]:
        try:
            v = int(target.fpga_read(reg, 1)[0]) & 0xFF
            print(f"  {name:18s} 0x{reg:02x} -> 0x{v:02x}")
        except Exception as e:
            print(f"  {name:18s} read error: {e}")

    print()
    print("All recovery attempts failed.")
    print()
    print("Likely the CW305 USB FIFO interface is desynced from the SAM3U side")
    print("and only a physical USB cable replug or board power cycle will recover.")
    print("This is NOT a project-state change; it's a one-time bring-up issue.")

    scope.dis(); target.dis()
    return 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(130)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        import traceback; traceback.print_exc()
        sys.exit(1)
