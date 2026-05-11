# Unified Butterfly2 — Side-Channel Evaluation Platform

A FPGA hardware accelerator that implements a **single, unified butterfly datapath** for the
NTT (Number Theoretic Transform) used by both **Kyber (ML-KEM)** and **Dilithium (ML-DSA)** —
the two NIST post-quantum cryptography standards based on lattices — together with a
ChipWhisperer-based capture/analysis pipeline for **side-channel leakage assessment** on it.

> **이 프로젝트를 처음 보시는 분**: [docs/leakage_explained.md](docs/leakage_explained.md)
> 가 친절한 입문서입니다. 부채널 공격, NTT butterfly, FPGA 파이프라인, 누설점 식별까지
> 그림과 비유로 설명합니다. 이후 [docs/experiments/](docs/experiments/) 의 각 실험 문서로.

The design is built for the [ChipWhisperer CW305](https://rtfm.newae.com/Targets/CW305%20Artix%20FPGA/)
target board. The wrapper exposes a USB register interface for the host and routes a
trigger signal to the 20-pin connector so a CW capture scope (CW-Lite, CW-Pro, Husky,
Husky-Plus) can synchronously sample the FPGA's power line during each butterfly evaluation.

---

## 1. What this project does

Two intertwined goals:

| Goal | Concretely |
|---|---|
| **PQC accelerator** | One pipelined data path that handles Kyber (q=3329) and Dilithium (q=8380417), both forward (Cooley-Tukey) and inverse (Gentleman-Sande) butterflies. Reduction is Montgomery (R=2^32). 7-stage pipeline, 1 result/cycle throughput. |
| **SCA platform** | Run the butterfly under host-controlled inputs while a CW scope captures power/EM traces, then analyze the traces with TVLA (Welch's t-test) to detect input-dependent leakage. |

Why "unified"? Because the same multiplier, the same Montgomery reducer, and the same
final add/sub stage process **both** Kyber and Dilithium operands. The interesting research
question is whether this unification introduces leakage paths that a single-algorithm
implementation would not have.

### 1.1 The butterfly equations

```
Cooley-Tukey  (mode = 1):   out1 = (a + b·ζ) mod q     out2 = (a − b·ζ) mod q
Gentleman-Sande(mode = 0):  out1 = (a + b)   mod q     out2 = ((a − b)·ζ) mod q
```

`ζ` is read from a 1024×32 ROM (the IP `blk_mem_gen_0`) initialized from
`unified_zeta.coe`. The ROM is divided into four 256-entry zones — Kyber forward, Kyber
inverse, Dilithium forward, Dilithium inverse — selected by `mode`/`mode2`.

### 1.2 Side-channel platform

The wrapper drives `tio_trigger = busy_reg`. So during each butterfly evaluation:
- start register write → `busy_reg` rises on the same FPGA cycle
- `tio_trigger` rises → CW scope (already armed) begins ADC capture
- 72 cycles later (CAPTURE_DELAY) → `done_reg` rises, `busy_reg` falls → trigger drops
- host reads outputs, clears `done`, moves on

This gives **sub-cycle-accurate trace alignment** independent of USB latency.

---

## 2. Hardware setup

```
[PC]  ──USB──  [ChipWhisperer-Husky-Plus or CW-Lite/Pro]
                     │
                     │ 20-pin CW connector
                     │   (TIO4 = trigger,  HS-IN = clock,  power/gnd)
                     │
[PC]  ──USB──  [CW305 Artix-7 FPGA target]
                     │
                     └─── X4 SMA "MEASURE" ───→  scope's SMA "Measure In"
```

CW305 has a built-in shunt resistor + amplifier on Vcc-int that exposes a clean
power-consumption waveform on the X4 SMA jack. This is what the scope captures.

The 20-pin connector carries `tio_trigger` (TIO4) and `tio_clkout` (= `usb_clk_buf`)
from the FPGA back into the scope so the scope can sync its ADC clock.

---

## 3. Software requirements

```
Python 3.10+         (3.11 tested)
chipwhisperer        (NewAE — pip install chipwhisperer)
numpy                (analysis)
matplotlib           (plot)
Vivado 2024.2+       (only needed when re-synthesizing)
```

A typical `pyenv` virtualenv works. The published instructions assume the venv is
named `sca`:

```bash
pyenv activate sca
pip install chipwhisperer numpy matplotlib
```

---

## 4. Folder layout

After the cleanup described in §6, the project is organized as:

```
butterfly/
├── README.md                                 — this file
├── .gitignore                                — keeps Vivado build artifacts out of git
│
├── rtl/                                      — canonical Verilog sources (human-edited)
│   ├── cw305_unified_butterfly2_top_v4_directwrite.v   # CW305 USB-register wrapper
│   ├── cw305_usb_reg_fe.v                              # NewAE official USB register frontend
│   ├── unified_butterfly2_top.v                        # mux + ROM + core wiring
│   ├── unified_bufferfly2.v                            # 7-stage pipelined butterfly core
│   │                                                   #   (filename has typo "bufferfly", kept for Vivado)
│   ├── Modular_Reduction32.v                           # 4-stage Montgomery reducer
│   ├── mux2_1.v                                        # legacy small mux (unused after pipeline)
│   └── demux1_2.v                                      # legacy small demux (unused)
│
├── constraints/
│   └── cw305_unified_butterfly2_top_v4.xdc            # pin map + clocks for CW305
│
├── sim/
│   └── tb_unified_butterfly2.v                        # 4-case behavioural testbench
│
├── ip/
│   └── unified_zeta.coe                               # Kyber/Dil ζ tables (ROM init)
│
├── host/                                              — PC-side scripts
│   ├── sca_config.py                                  # shared constants (register map, q, threshold)
│   ├── run_cw305_unified_butterfly2_top_v4.py         # one-shot sanity check (no scope)
│   ├── capture_traces.py                              # bulk trace capture (Husky/Lite branched)
│   ├── tvla.py                                        # Welch t-test + plot
│   ├── diag_trigger.py                                # diagnostic for trigger problems
│   └── results/                                       # per-experiment subdirs (gitignored)
│       └── <YYYYMMDD_HHMMSS_label>/
│           ├── traces.npy
│           ├── inputs.npz
│           ├── metadata.json
│           ├── tvla_t_stat.npy
│           └── tvla_plot.png
│
├── bitstream/
│   └── cw305_unified_butterfly2_top_v4.bit            — symlink → Vivado output (auto-syncs)
│
├── unified_zeta.coe                                   — kept at root because the IP's
│                                                        relative path resolves to here
│
└── unified_butterfly2/                                — Vivado workspace (gitignored except .xpr/.srcs)
    ├── unified_butterfly2.xpr                         # project file
    ├── unified_butterfly2.srcs/                       # Vivado's internal copies of sources
    │                                                    (the canonical copies live in rtl/, etc.)
    ├── unified_butterfly2.cache/      ← gitignored
    ├── unified_butterfly2.runs/       ← gitignored (impl_1 holds the .bit)
    ├── unified_butterfly2.gen/        ← gitignored
    ├── unified_butterfly2.hw/         ← gitignored
    ├── unified_butterfly2.ip_user_files/  ← gitignored
    └── unified_butterfly2.sim/        ← gitignored
```

### 4.1 Why are sources duplicated in `rtl/` and `unified_butterfly2.srcs/sources_1/new/`?

Because Vivado imports source files into the project workspace at project-creation time.
The canonical copy is `rtl/`; the workspace copy is what Vivado actually compiles. They
must be kept in sync — when you edit RTL, edit BOTH (or open Vivado, which can be
configured to refresh from `rtl/`).

---

## 5. Source-file responsibilities

### 5.1 RTL (`rtl/`)

| File | Module | What it does |
|---|---|---|
| `Modular_Reduction32.v` | `Modular_Reduction32` | 4-stage pipelined Montgomery reduction (R = 2^32). QPRIME constants chosen automatically per `q`. |
| `unified_bufferfly2.v` | `unified_butterfly2_core` | 7-stage pipelined CT/GS butterfly. Pre-mul mux → 32×32 multiplier → Montgomery → final add/sub. Latency 7 cycles, throughput 1/cycle. |
| `unified_butterfly2_top.v` | `unified_butterfly2_top` | Wraps the core with the ROM (`blk_mem_gen_0`), selects the correct ζ zone via `mode`/`mode2`. |
| `cw305_usb_reg_fe.v` | `cw305_usb_reg_fe` | NewAE official module that decodes the SAM3U USB-FIFO parallel interface into register-style read/write signals. |
| `cw305_unified_butterfly2_top_v4_directwrite.v` | `cw305_unified_butterfly2_top_v4` | Top module. Defines a register map (a, b, k, ctrl, status, out1, out2, debug counters), latches inputs, drives the butterfly, and asserts `tio_trigger = busy_reg` for the SCA scope. |
| `mux2_1.v`, `demux1_2.v` | small combinational helpers, kept for Vivado project history; unused after the pipelined core was inlined. |

### 5.2 Constraints + sim

| File | Purpose |
|---|---|
| `constraints/cw305_unified_butterfly2_top_v4.xdc` | Pin map for CW305 (USB FIFO, switches, LEDs, 20-pin connector), 100 MHz clock declarations, false paths. |
| `sim/tb_unified_butterfly2.v` | Four hand-checked test cases (Kyber CT/GS, Dilithium CT/GS) with expected Montgomery-domain outputs. |

### 5.3 IP

| File | Purpose |
|---|---|
| `ip/unified_zeta.coe` | 1024 × 32-bit ROM contents: 0..127 Kyber inv-ζ, 256..383 Kyber ζ, 512..767 Dil inv-ζ, 768..1023 Dil ζ. |
| `unified_zeta.coe` (root) | Same file at root because the IP's `.xci` references it via the relative path `../../../../../unified_zeta.coe`. Both copies are byte-identical (md5 verified). |

### 5.4 Host scripts (`host/`)

| File | Role |
|---|---|
| `sca_config.py` | Single source of truth for register map, modulus values, the excluded scope serial, default clock parameters. Imported by every host script. |
| `run_cw305_unified_butterfly2_top_v4.py` | Original sanity check. Programs the FPGA, writes one (a, b, k, mode, mode2), reads (out1, out2). No scope involved. Useful for verifying USB + bitstream basics. |
| `capture_traces.py` | The SCA capture engine. Auto-detects scope type (Husky / Husky-Plus / Lite / Pro), branches the clock API accordingly, runs N butterflies in TVLA-style fixed-vs-random groups, saves traces + metadata. |
| `tvla.py` | Loads a results directory, computes Welch's t-statistic per sample, saves `tvla_t_stat.npy` and `tvla_plot.png`. |
| `diag_trigger.py` | Debugging helper that walks through scope-connect → FPGA-program → register R/W → status-poll → scope-capture, printing each step's status. Used to localize "no trigger seen" failures. |

---

## 6. History of changes

This project was received as a fragmented file dump (.bit, .xdc, raw `new/` Verilog
folder, and a Vivado workspace) from an earlier author. The work to date:

### 6.1 Initial layout (received)

```
butterfly/
├── cw305_unified_butterfly2_top_v4.bit      ← loose at root
├── cw305_unified_butterfly2_top_v4.xdc      ← loose at root
├── new/                                      ← raw Verilog dump
│   └── *.v   (7 files)
└── unified_butterfly2/                       ← Vivado workspace
    └── ...   (everything inside)
```

The same `.bit`, `.xdc`, and `.v` files were duplicated under `unified_butterfly2/.srcs/`.

### 6.2 Reorganization

Verified all root files were byte-identical to their counterparts in the Vivado workspace
(diff on `new/`, md5 on `.bit` and `.xdc`). Then:

```
new/                            →  rtl/
cw305_..._v4.xdc                →  constraints/
cw305_..._v4.bit                →  bitstream/
unified_butterfly2/...sim_1/    →  sim/  (testbench copied out)
unified_butterfly2/...impl_1/   →  host/run_cw305_..._v4.py  (host script copied out)
```

The Vivado workspace `unified_butterfly2/` was left untouched because its `.xpr` has
internal path references.

### 6.3 RTL change for SCA alignment

Original wrapper had `assign tio_trigger = usb_trigger;` — meaning the host had to toggle
a separate USB trigger pin, with USB-transaction latency (~125 µs on Husky) between the
trigger and the actual butterfly start. Trace alignment would suffer.

Changed both copies of the wrapper so the default build drives
`tio_trigger = busy_reg` via `pUSE_INTERNAL_TRIGGER=1`. Now `tio_trigger` rises and
falls precisely with the FPGA's busy state, giving sub-cycle alignment. Set
`pUSE_INTERNAL_TRIGGER=0` only for legacy host-toggle tests. The bitstream must be
re-synthesized after this change.

### 6.4 Host pipeline added

Three new scripts under `host/`:

- `sca_config.py` (constants)
- `capture_traces.py` (Husky/Lite-branched scope setup, TVLA-style capture loop)
- `tvla.py` (Welch t-test + plot)
- `diag_trigger.py` (added later for debugging)

The capture script auto-detects scope kind from `cw.list_devices()` and branches the
clock-config API:

| Scope | Clock API | Notes |
|---|---|---|
| ChipWhisperer-Husky / Husky-Plus | `clkgen_src`, `clkgen_freq`, `adc_mul` | requires PLL lock wait |
| ChipWhisperer-Lite / Pro | `adc_src = "extclk_x1"` by default | single string API; use x4 only if the target clock is slowed enough for the ADC limit |

It also supports a scope-side device-serial filter (a default `EXCLUDE_SCOPE_SERIAL`
plus runtime `--scope-sn` / `--exclude-scope-sn none` override) so it never grabs a
scope that another experiment on the same machine is using.

### 6.5 IP file recovery

Vivado's `.xci` for `blk_mem_gen_0` references `unified_zeta.coe` at the project root;
the file was missing (original author kept it under their `~/Downloads/`). We located
identical copies cached inside the Vivado workspace (md5 `3115860c...`) and placed the
file at both `unified_zeta.coe` (where the IP expects it) and `ip/unified_zeta.coe`
(canonical).

### 6.6 Bitstream symlink

`bitstream/cw305_unified_butterfly2_top_v4.bit` is now a symlink to
`unified_butterfly2/unified_butterfly2.runs/impl_1/cw305_unified_butterfly2_top_v4.bit`.
Vivado writes the .bit there on each rebuild; the symlink propagates automatically with
no manual `cp`.

---

## 7. How to use

### 7.1 First-time build

```bash
# 1) Re-synthesize the FPGA (only needed when RTL changes)
vivado unified_butterfly2/unified_butterfly2.xpr &
# inside Vivado:  Flow Navigator → PROGRAM AND DEBUG → Generate Bitstream
# wait ~5–15 min; .bit ends up under unified_butterfly2.runs/impl_1/ and
# is auto-visible at  bitstream/cw305_unified_butterfly2_top_v4.bit  via the symlink

# 2) Sanity-check the bitstream without a scope
python3 host/run_cw305_unified_butterfly2_top_v4.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --a 3100 --b 2800 --k 16 --mode 1 --mode2 0 --debug-readback
# expected: out1=2721, out2=150  (matches testbench case "Kyber CT")
```

### 7.2 Capture traces

```bash
python3 host/capture_traces.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --num-traces 2000 \
    --label kyber_ct_b_first \
    --mode 1 --mode2 0 --k 16
```

Defaults:
- scope auto-detect (Husky-Plus, Husky, Lite, Pro)
- `--trigger-mode internal` (assumes the new wrapper with `tio_trigger = busy_reg`)
- `--target-freq 96e6`, `--adc-mul 0` (auto: Husky/Husky-Plus x2, CW-Lite/Pro x1)
- a-input 0xCAFEBABE is reduced mod q before FPGA write, b-fixed 0x12345678 is reduced mod q, seed 0xC0FFEE for reproducibility
- output → `host/results/<timestamp>_kyber_ct_b_first/`

Portable CW-Lite/Pro repro example. This captures the same target-cycle window even
though Lite/Pro sample at 96 MS/s by default while Husky/Husky-Plus use 192 MS/s:

```bash
python3 host/diag_trigger.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --scope-type lite --adc-mul 1 --samples 800 --exclude-scope-sn none

python3 host/capture_traces.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --scope-type lite --adc-mul 1 --sample-cycles 400 \
    --num-traces 2000 \
    --label kyber_ct_lite_repro \
    --mode 1 --mode2 0 --k 16 --exclude-scope-sn none
```

For Husky/Husky-Plus, omit `--scope-type` and `--adc-mul`, or use
`--scope-type husky --adc-mul 2 --sample-cycles 400`; the script records the measured
target clock, estimated ADC MHz, and samples-per-target-cycle in `metadata.json`.

### 7.3 Analyze for leakage

```bash
python3 host/tvla.py host/results/<timestamp>_kyber_ct_b_first/
```

Outputs:
- `tvla_t_stat.npy` — per-sample Welch's t-statistic
- `tvla_plot.png` — the t-stat curve with ±4.5 leakage threshold lines

A peak with `|t| > 4.5` flags input-dependent leakage at that sample.

---

## 8. Configuration knobs (CLI)

```
--bitfile PATH                  required
--scope-sn SN                   force scope serial (else auto, see EXCLUDE list)
--target-sn SN                  force CW305 serial (else auto)
--scope-type {auto,husky-plus,husky,lite,pro}
--trigger-mode {internal,host-toggle}
                                internal   = recommended, requires new wrapper
                                host-toggle = legacy bitstream fallback (wider
                                              --samples needed to absorb USB latency)
--num-traces N                  default 2000
--samples N                     default 400 (internal) — go to ~50000 for host-toggle
--sample-cycles F               convert target cycles to samples using adc_mul
--gain-db F                     default 25
--target-freq F                 default 96e6   (CW305 usb_clk target)
--adc-mul N                     default 0  — auto: Husky x2, Lite/Pro x1
--exclude-scope-sn SN|none      skip one shared scope during auto-detect
--label STR                     becomes part of results-dir name
--a, --b-fixed, --k, --mode, --mode2, --seed
                                input controls
```

### 8.1 The excluded scope

`sca_config.EXCLUDE_SCOPE_SERIAL = "50203220594a48303330373133323037"` (a CW-Lite
that another experiment uses on the same workstation). The auto-discovery never picks
it. Pass `--scope-sn` to force a specific scope, or `--exclude-scope-sn none` on a
separate workstation where no scope needs to be reserved.

---

## 9. Known issues and caveats

1. **Clock MHz changes sample indexing.** The CW305 target clock is normally about
   96 MHz. Husky/Husky-Plus auto-select `adc_mul=2` (about 192 MS/s, 2 samples/cycle);
   CW-Lite/Pro auto-select `adc_mul=1` (about 96 MS/s, 1 sample/cycle). Use
   `--sample-cycles` for cross-scope runs and compare cycles, not raw sample indices.
   The saved metadata records measured target MHz and estimated ADC MHz.

2. **Husky PLL frequency rounding.** Some ChipWhisperer versions still print transient
   PLL rounding warnings while settling, but the saved metadata should show
   `pll_locked=true` and an ADC frequency near 192 MHz for the standard Husky setup.

3. **Trace alignment depends on the wrapper change.** If the .bit on the FPGA was built
   from the *old* wrapper (`tio_trigger = usb_trigger`), `--trigger-mode internal` will
   time out with "no trigger seen". Either re-synthesize, or use `--trigger-mode host-toggle`
   with a much wider `--samples` window.

4. **Two source-of-truth copies of the RTL.** Edits made in `rtl/` are not auto-mirrored
   into `unified_butterfly2/.srcs/sources_1/new/`. Edit both, or open Vivado and let it
   refresh.

5. **The `unified_butterfly2/` workspace contains macOS `.DS_Store` files** because the
   project came from a Mac. They're harmless and gitignored.

6. **The hardware is shared.** The CW-Lite at SN `50203220594a48303330373133323037` is
   reserved by another project on the original workstation; capture scripts exclude it
   by default. Use `--exclude-scope-sn none` on a standalone reproduction PC.

7. **Filename typo.** `unified_bufferfly2.v` (with `bufferfly`) is preserved because
   Vivado references files by name; renaming would break the project file.

---

## 10. Reproducing a clean build from scratch

If `unified_butterfly2/` is blown away or corrupted:

1. Open Vivado, *File → New Project*, choose Artix-7 / xc7a100tftg256-2 (CW305's part).
2. Add sources: all files in `rtl/`.
3. Add constraints: `constraints/cw305_unified_butterfly2_top_v4.xdc`.
4. Add simulation source: `sim/tb_unified_butterfly2.v`.
5. Create IP: `blk_mem_gen_0` (1024×32 single-port ROM, COE init = `unified_zeta.coe`
   placed at the project root).
6. Generate Bitstream.
7. Re-create the symlink:
   ```bash
   ln -sf ../unified_butterfly2/unified_butterfly2.runs/impl_1/cw305_unified_butterfly2_top_v4.bit \
          bitstream/cw305_unified_butterfly2_top_v4.bit
   ```
