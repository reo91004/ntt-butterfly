#!/usr/bin/env python3
"""
CW305 unified_butterfly2 test script for v4 direct-write wrapper.

Register map:
  0x00 : A_SHARE0[31:0] legacy alias
  0x01 : B_SHARE0[31:0] 4 bytes little-endian
  0x02 : K[9:0]      2 bytes little-endian
  0x03 : CTRL        1 byte, bit0=mode, bit1=mode2
  0x04 : CMD/STATUS  write bit0=start, bit1=clear_done; read bit0=done, bit1=busy
  0x05 : OUT1_SHARE0[31:0] 4 bytes little-endian
  0x06 : OUT2_SHARE0[31:0] 4 bytes little-endian
  0x08 : A_SHARE1[31:0] 4 bytes little-endian
  0x09 : B_SHARE1[31:0] 4 bytes little-endian
  0x0A : OUT1_SHARE1[31:0] 4 bytes little-endian
  0x0B : OUT2_SHARE1[31:0] 4 bytes little-endian
  0x0D : A_SHARE0[31:0] 4 bytes little-endian (host-safe alias)
  0x70..0x73 : write debug
  0x7E : ID = 0xC4
"""

import argparse
import random
import sys
import time
from pathlib import Path

import chipwhisperer as cw

REG_A = 0x0D
REG_B = 0x01
REG_K = 0x02
REG_CTRL = 0x03
REG_STATUS = 0x04
REG_OUT1 = 0x05
REG_OUT2 = 0x06
REG_A_SHARE1 = 0x08
REG_B_SHARE1 = 0x09
REG_OUT1_SHARE1 = 0x0A
REG_OUT2_SHARE1 = 0x0B
REG_WRCOUNT = 0x70
REG_LAST_ADDR = 0x71
REG_LAST_BYTE = 0x72
REG_LAST_DATA = 0x73
REG_RAWPINS = 0x74
REG_FE_WRCOUNT = 0x75
REG_ID = 0x7E

DONE_MASK = 0x01
BUSY_MASK = 0x02
KYBER_Q = 3329
DILITHIUM_Q = 8380417


def b(x):
    if isinstance(x, int):
        return x & 0xFF
    return int(x[0]) & 0xFF


def read_bytes(target, reg, n):
    return bytearray(target.fpga_read(reg, n))


def write_bytes(target, reg, data):
    target.fpga_write(reg, list(data))


def u32_to_le(x):
    x &= 0xFFFFFFFF
    return [(x >> 0) & 0xFF, (x >> 8) & 0xFF, (x >> 16) & 0xFF, (x >> 24) & 0xFF]


def le_to_u32(data):
    data = list(data)
    return data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24)


def read_u8(target, reg):
    return b(target.fpga_read(reg, 1))


def write_u8(target, reg, value):
    target.fpga_write(reg, [value & 0xFF])


def read_u32(target, reg):
    return le_to_u32(read_bytes(target, reg, 4))


def write_u32(target, reg, value):
    write_bytes(target, reg, u32_to_le(value))


def connect(bitfile, no_program):
    if no_program:
        print("[1] CW305 connecting without programming...")
        return cw.target(None, cw.targets.CW305)
    bitpath = Path(bitfile).expanduser()
    if not bitpath.exists():
        raise FileNotFoundError(f"bitfile not found: {bitpath}")
    print("[1] CW305 connecting/programming...")
    target = cw.target(None, cw.targets.CW305, bsfile=str(bitpath), force=True)
    print(f"[2] FPGA programmed: {bitpath}")
    return target


def debug_readback(target):
    print(f"[debug] ID 0x7E = 0x{read_u8(target, REG_ID):02x}  (v4 should be 0xc4)")
    print("[debug] write-path debug before writes")
    print(f"    wr_count = 0x{read_u8(target, REG_WRCOUNT):02x}")
    print(f"    last_addr= 0x{read_u8(target, REG_LAST_ADDR):02x}")
    print(f"    last_byte= 0x{read_u8(target, REG_LAST_BYTE):02x}")
    print(f"    last_data= 0x{read_u8(target, REG_LAST_DATA):02x}")
    print(f"    raw_pins = 0x{read_u8(target, REG_RAWPINS):02x}  bits={{cen,wrn,rdn}} in low 3")
    print(f"    fe_wrcnt = 0x{read_u8(target, REG_FE_WRCOUNT):02x}")


def split_value(value, share1, q):
    value %= q
    share1 %= q
    return (value - share1) % q, share1


def write_inputs(target, a, bval, k, mode, mode2, seed):
    q = KYBER_Q if mode2 == 0 else DILITHIUM_Q
    rng = random.Random(seed)
    a0, a1 = split_value(a, rng.randrange(q), q)
    b0, b1 = split_value(bval, rng.randrange(q), q)

    print("[3] writing masked inputs")
    print(f"    a=0x{a % q:08x} ({a % q}) = a0({a0}) + a1({a1}) mod {q}")
    print(f"    b=0x{bval % q:08x} ({bval % q}) = b0({b0}) + b1({b1}) mod {q}")
    print(f"    k={k}")
    print(f"    mode={mode}, mode2={mode2}")
    write_u32(target, REG_A, a0)
    write_u32(target, REG_A_SHARE1, a1)
    write_u32(target, REG_B, b0)
    write_u32(target, REG_B_SHARE1, b1)
    write_bytes(target, REG_K, [k & 0xFF, (k >> 8) & 0x03])
    write_u8(target, REG_CTRL, (mode & 1) | ((mode2 & 1) << 1))
    return q


def readback_inputs(target):
    a_rb = read_u32(target, REG_A)
    b_rb = read_u32(target, REG_B)
    a1_rb = read_u32(target, REG_A_SHARE1)
    b1_rb = read_u32(target, REG_B_SHARE1)
    k_bytes = read_bytes(target, REG_K, 2)
    k_rb = k_bytes[0] | ((k_bytes[1] & 0x03) << 8)
    ctrl = read_u8(target, REG_CTRL)
    stat = read_u8(target, REG_STATUS)
    print("[debug] input/status readback")
    print(f"    a0_rb = 0x{a_rb:08x} ({a_rb})")
    print(f"    a1_rb = 0x{a1_rb:08x} ({a1_rb})")
    print(f"    b0_rb = 0x{b_rb:08x} ({b_rb})")
    print(f"    b1_rb = 0x{b1_rb:08x} ({b1_rb})")
    print(f"    k_rb = {k_rb}  (bytes={list(k_bytes)})")
    print(f"    ctrl = 0x{ctrl:02x}  mode={ctrl & 1}, mode2={(ctrl >> 1) & 1}")
    print(f"    stat = 0x{stat:02x}  done={1 if stat & DONE_MASK else 0}, busy={1 if stat & BUSY_MASK else 0}")
    print("[debug] write-path debug after writes")
    print(f"    wr_count = 0x{read_u8(target, REG_WRCOUNT):02x}")
    print(f"    last_addr= 0x{read_u8(target, REG_LAST_ADDR):02x}")
    print(f"    last_byte= 0x{read_u8(target, REG_LAST_BYTE):02x}")
    print(f"    last_data= 0x{read_u8(target, REG_LAST_DATA):02x}")
    print(f"    raw_pins = 0x{read_u8(target, REG_RAWPINS):02x}  bits={{cen,wrn,rdn}} in low 3")
    print(f"    fe_wrcnt = 0x{read_u8(target, REG_FE_WRCOUNT):02x}")


def start(target):
    print("[4] start")
    write_u8(target, REG_STATUS, 0x01)
    print(f"[debug] status just after start = 0x{read_u8(target, REG_STATUS):02x}")
    time.sleep(0.01)
    print(f"[debug] status after 10 ms    = 0x{read_u8(target, REG_STATUS):02x}")
    print("[debug] write-path debug after start")
    print(f"    wr_count = 0x{read_u8(target, REG_WRCOUNT):02x}")
    print(f"    last_addr= 0x{read_u8(target, REG_LAST_ADDR):02x}")
    print(f"    last_byte= 0x{read_u8(target, REG_LAST_BYTE):02x}")
    print(f"    last_data= 0x{read_u8(target, REG_LAST_DATA):02x}")
    print(f"    raw_pins = 0x{read_u8(target, REG_RAWPINS):02x}  bits={{cen,wrn,rdn}} in low 3")
    print(f"    fe_wrcnt = 0x{read_u8(target, REG_FE_WRCOUNT):02x}")


def wait_done(target, timeout_s, poll_interval_s, poll_log):
    t0 = time.time()
    i = 0
    last = 0
    while True:
        last = read_u8(target, REG_STATUS)
        if poll_log and (i < 20 or i % 100 == 0):
            print(f"    poll {i:04d}: status=0x{last:02x} done={1 if last & DONE_MASK else 0} busy={1 if last & BUSY_MASK else 0}")
        if last & DONE_MASK:
            return last
        if time.time() - t0 > timeout_s:
            raise TimeoutError(f"done=1 timeout. last status=0x{last:02x}")
        i += 1
        time.sleep(poll_interval_s)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--bitfile")
    p.add_argument("--no-program", action="store_true")
    p.add_argument("--a", type=lambda x: int(x, 0), required=True)
    p.add_argument("--b", type=lambda x: int(x, 0), required=True)
    p.add_argument("--k", type=lambda x: int(x, 0), required=True)
    p.add_argument("--mode", type=int, choices=[0, 1], required=True)
    p.add_argument("--mode2", type=int, choices=[0, 1], required=True)
    p.add_argument("--seed", type=int, default=1)
    p.add_argument("--timeout", type=float, default=2.0)
    p.add_argument("--poll-interval", type=float, default=0.001)
    p.add_argument("--debug-readback", action="store_true")
    p.add_argument("--poll-log", action="store_true")
    args = p.parse_args()

    target = connect(args.bitfile, args.no_program)
    if args.debug_readback:
        debug_readback(target)
    q = write_inputs(target, args.a, args.b, args.k, args.mode, args.mode2, args.seed)
    readback_inputs(target)
    start(target)
    status = wait_done(target, args.timeout, args.poll_interval, args.poll_log)
    print(f"[5] done, status=0x{status:02x}")
    out1_s0 = read_u32(target, REG_OUT1)
    out2_s0 = read_u32(target, REG_OUT2)
    out1_s1 = read_u32(target, REG_OUT1_SHARE1)
    out2_s1 = read_u32(target, REG_OUT2_SHARE1)
    out1 = (out1_s0 + out1_s1) % q
    out2 = (out2_s0 + out2_s1) % q
    print("[6] output")
    print(f"    out1_share0=0x{out1_s0:08x} ({out1_s0})")
    print(f"    out1_share1=0x{out1_s1:08x} ({out1_s1})")
    print(f"    out1       =0x{out1:08x} ({out1})")
    print(f"    out2_share0=0x{out2_s0:08x} ({out2_s0})")
    print(f"    out2_share1=0x{out2_s1:08x} ({out2_s1})")
    print(f"    out2       =0x{out2:08x} ({out2})")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)
