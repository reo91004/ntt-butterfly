#!/usr/bin/env python3
"""
Bit-specific TVLA: re-group an existing capture by individual bits of `b`
to identify WHICH input bits leak the most.

For each bit position i in 0..31:
    Group A: traces where (b >> i) & 1 == 0
    Group B: traces where (b >> i) & 1 == 1
    Compute Welch's t per sample, take peak |t|.

The result is a "leakage rank" of bits: which positions of b are most visible
in power.

Outputs (into the same results directory):
    spec_tvla_bit_<i>_t.npy     per-sample t-stat for bit i  (only saved for top-k bits)
    spec_tvla_bits.png          ranked-bar plot of peak |t| vs bit index
    spec_tvla_summary.txt       human-readable per-bit peak |t| + sample idx
"""
import argparse
import json
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

from sca_config import TVLA_THRESHOLD


def welch_t(a, b):
    if a.shape[0] < 2 or b.shape[0] < 2:
        return np.zeros(a.shape[1] if a.ndim == 2 else b.shape[1])
    ma = a.mean(0, dtype=np.float64); mb = b.mean(0, dtype=np.float64)
    va = a.var(0, ddof=1, dtype=np.float64); vb = b.var(0, ddof=1, dtype=np.float64)
    se = np.sqrt(va / a.shape[0] + vb / b.shape[0])
    se = np.where(se < 1e-30, 1e-30, se)
    return (ma - mb) / se


def main():
    p = argparse.ArgumentParser()
    p.add_argument("results_dir", type=Path)
    p.add_argument("--save-top-k", type=int, default=8,
                   help="Save full t-trace for the K most-leaky bit positions.")
    args = p.parse_args()

    rd = args.results_dir.resolve()
    traces = np.load(rd / "traces.npy")
    inputs = np.load(rd / "inputs.npz")
    b_arr  = inputs["b"]
    n, samples = traces.shape

    print(f"[spec_tvla] traces={traces.shape}, b range=[{b_arr.min()}, {b_arr.max()}]")

    bit_peak  = np.zeros(32)
    bit_arg   = np.zeros(32, dtype=np.int32)
    saved_paths = []

    for bit in range(32):
        mask = ((b_arr >> bit) & 1).astype(bool)
        a_set = traces[~mask]
        b_set = traces[mask]
        if a_set.shape[0] < 2 or b_set.shape[0] < 2:
            print(f"  bit {bit:>2d}: too unbalanced ({a_set.shape[0]} vs {b_set.shape[0]}) — skip")
            continue
        t = welch_t(a_set, b_set)
        bit_peak[bit] = float(np.abs(t).max())
        bit_arg[bit]  = int(np.argmax(np.abs(t)))
        print(f"  bit {bit:>2d}: peak |t|={bit_peak[bit]:7.3f} @ sample {bit_arg[bit]:>3d}  "
              f"({a_set.shape[0]:>5d} vs {b_set.shape[0]:>5d})")

    # Save top-K detailed traces
    order = np.argsort(bit_peak)[::-1]
    for rank, bit in enumerate(order[:args.save_top_k]):
        if bit_peak[bit] < TVLA_THRESHOLD * 0.5:
            continue
        mask = ((b_arr >> int(bit)) & 1).astype(bool)
        t = welch_t(traces[~mask], traces[mask])
        path = rd / f"spec_tvla_bit_{int(bit):02d}_t.npy"
        np.save(path, t)
        saved_paths.append(str(path))

    # Bar plot
    fig, ax = plt.subplots(figsize=(11, 4))
    colors = ["#2ca02c" if v > TVLA_THRESHOLD else "#d62728" if v < 1.0 else "#1f77b4"
              for v in bit_peak]
    ax.bar(range(32), bit_peak, color=colors)
    ax.axhline(TVLA_THRESHOLD, color="red", lw=0.8, ls="--", label=f"|t| = {TVLA_THRESHOLD}")
    ax.set_xlabel("bit index of b (0 = LSB, 31 = MSB)")
    ax.set_ylabel("peak |t| over capture window")
    ax.set_title(f"Bit-specific TVLA — {rd.name}\n"
                 f"peak shows which bits of b are most distinguishable in power")
    ax.set_xticks(range(0, 32, 2))
    ax.legend(loc="upper right", fontsize=9)
    ax.grid(axis="y", alpha=0.3)
    fig.tight_layout()
    plot_path = rd / "spec_tvla_bits.png"
    fig.savefig(plot_path, dpi=150)
    plt.close(fig)

    # Summary text
    with open(rd / "spec_tvla_summary.txt", "w") as f:
        f.write(f"# bit-specific TVLA on {rd.name}\n")
        f.write(f"# N = {n} traces, {samples} samples\n")
        f.write(f"# threshold = {TVLA_THRESHOLD}\n\n")
        f.write("rank  bit   peak|t|    sample  status\n")
        for rank, bit in enumerate(order):
            status = "LEAK" if bit_peak[bit] > TVLA_THRESHOLD else " ok "
            f.write(f"{rank+1:>4d}  {int(bit):>3d}   {bit_peak[bit]:>7.3f}    {bit_arg[bit]:>5d}   {status}\n")

    print()
    print(f"[spec_tvla] saved: {plot_path}")
    print(f"[spec_tvla] saved: {rd/'spec_tvla_summary.txt'}")
    print(f"[spec_tvla] saved {len(saved_paths)} per-bit t-traces")
    leaky = int(np.sum(bit_peak > TVLA_THRESHOLD))
    print(f"[spec_tvla] {leaky}/32 bits leak above threshold {TVLA_THRESHOLD}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
