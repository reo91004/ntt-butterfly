"""Shared configuration for SCA capture/analysis on the unified butterfly2 target."""

from pathlib import Path

# Serial of the ChipWhisperer scope we MUST NOT use (another experiment occupies it).
# capture_traces.py picks any other ChipWhisperer device it can find.
EXCLUDE_SCOPE_SERIAL = "50203220594a48303330373133323037"

# CW305 register map (matches rtl/cw305_unified_butterfly2_top_v4_directwrite.v).
REG_A           = 0x00
REG_B           = 0x01
REG_K           = 0x02
REG_CTRL        = 0x03
REG_STATUS      = 0x04
REG_OUT1        = 0x05
REG_OUT2        = 0x06
REG_WRCOUNT     = 0x70
REG_LAST_ADDR   = 0x71
REG_LAST_BYTE   = 0x72
REG_LAST_DATA   = 0x73
REG_RAWPINS     = 0x74
REG_FE_WRCOUNT  = 0x75
REG_ID          = 0x7E

DONE_MASK = 0x01
BUSY_MASK = 0x02

# PQC moduli — used to bound TVLA random groups to legitimate ranges.
KYBER_Q     = 3329
DILITHIUM_Q = 8380417

# Welch's t-test threshold widely used by NIST PQC SCA evaluators.
TVLA_THRESHOLD = 4.5

# Default scope-clock parameters for CW305 SCA setups.
#
# Empirically, CW305's usb_clk (the parallel-FIFO clock from the SAM3U) is
# ~10 MHz, not 96 MHz. Husky's scope.clock.freq_ctr measures it as 10.000305
# MHz with the unified_butterfly2 wrapper loaded. The XDC has a 100 MHz
# create_clock constraint but that is a worst-case timing budget, not the
# actual frequency.
#
# adc_mul = 10 gives a 100 MHz ADC clock, well within Husky's 250 MHz spec
# and the standard CW-Lite/Pro 4× equivalent in oversample density per
# target cycle (10 ADC samples per usb_clk cycle).
DEFAULT_TARGET_FREQ_HZ = 10_000_000
DEFAULT_ADC_MUL        = 10

# Device-name prefixes used to auto-detect scope type from cw.list_devices().
SCOPE_NAMES = {
    "husky-plus": ("ChipWhisperer-Husky-Plus",),
    "husky":      ("ChipWhisperer-Husky",),       # matched after husky-plus
    "lite":       ("ChipWhisperer-Lite",),
    "pro":        ("ChipWhisperer-Pro",),
    "nano":       ("ChipWhisperer-Nano",),
}

# Folder where every experiment writes its own timestamped subdirectory.
RESULTS_ROOT = Path(__file__).resolve().parent / "results"
