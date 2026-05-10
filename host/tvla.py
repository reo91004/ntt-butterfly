#!/usr/bin/env python3
"""
TVLA (Welch's t-test) on a trace set captured by capture_traces.py.

Usage:
    python3 tvla.py <results_dir>

Reads:  traces.npy, inputs.npz, metadata.json   from <results_dir>
Writes: tvla_t_stat.npy, tvla_plot.png          into the SAME <results_dir>

Group A (g=0) = fixed input, Group B (g=1) = random input.
A sample is flagged as leaking when |t| > TVLA_THRESHOLD (default 4.5).
"""

import argparse
import json
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")          # headless / no DISPLAY needed
import matplotlib.pyplot as plt
import numpy as np

from sca_config import TVLA_THRESHOLD


def welch_t(traces_a, traces_b):
    """Per-sample Welch's t-statistic. Inputs shape: (n_a, S), (n_b, S). Returns (S,)."""
    mean_a = traces_a.mean(axis=0, dtype=np.float64)
    mean_b = traces_b.mean(axis=0, dtype=np.float64)
    var_a  = traces_a.var(axis=0, ddof=1, dtype=np.float64)
    var_b  = traces_b.var(axis=0, ddof=1, dtype=np.float64)
    n_a, n_b = traces_a.shape[0], traces_b.shape[0]
    se = np.sqrt(var_a / n_a + var_b / n_b)
    se = np.where(se < 1e-30, 1e-30, se)        # numerical guard
    return (mean_a - mean_b) / se


def main():
    p = argparse.ArgumentParser()
    p.add_argument("results_dir", type=Path, help="Directory written by capture_traces.py")
    p.add_argument("--threshold", type=float, default=TVLA_THRESHOLD,
                   help="|t| threshold for leakage flag (default 4.5)")
    args = p.parse_args()

    rd = args.results_dir.resolve()
    if not rd.is_dir():
        print(f"ERROR: not a directory: {rd}", file=sys.stderr)
        return 2

    traces = np.load(rd / "traces.npy")
    inputs = np.load(rd / "inputs.npz")
    meta_path = rd / "metadata.json"
    metadata = json.loads(meta_path.read_text()) if meta_path.exists() else {}

    groups = inputs["group"]
    a_idx = np.where(groups == 0)[0]
    b_idx = np.where(groups == 1)[0]
    n_a, n_b = a_idx.size, b_idx.size
    if n_a < 2 or n_b < 2:
        print(f"ERROR: not enough traces per group: A={n_a}, B={n_b}", file=sys.stderr)
        return 3

    print(f"[tvla] loaded  traces={traces.shape}  groups: A(fixed)={n_a}, B(random)={n_b}")
    t_stat = welch_t(traces[a_idx], traces[b_idx])
    np.save(rd / "tvla_t_stat.npy", t_stat)

    abs_t = np.abs(t_stat)
    peak_idx = int(np.argmax(abs_t))
    peak_val = float(abs_t[peak_idx])
    n_above  = int(np.sum(abs_t > args.threshold))
    n_total  = int(t_stat.size)

    print(f"[tvla] peak |t| = {peak_val:.3f} at sample {peak_idx}")
    print(f"[tvla] {n_above}/{n_total} samples exceed |t| > {args.threshold}")
    if n_above > 0:
        print(f"[tvla] LEAKAGE DETECTED at threshold {args.threshold}")
    else:
        print(f"[tvla] no leakage above threshold {args.threshold} (with N={n_a + n_b})")

    # ---- plot ----
    fig, ax = plt.subplots(figsize=(12, 4.2))
    samples_axis = np.arange(t_stat.size)
    ax.plot(samples_axis, t_stat, color="#1f77b4", lw=0.9, label="Welch's t")
    ax.axhline( args.threshold, color="red", lw=0.8, ls="--",
                label=f"±{args.threshold} (TVLA threshold)")
    ax.axhline(-args.threshold, color="red", lw=0.8, ls="--")
    leak_mask = abs_t > args.threshold
    if leak_mask.any():
        ax.fill_between(samples_axis, -args.threshold, args.threshold,
                        where=leak_mask, color="red", alpha=0.15,
                        label=f"|t| > {args.threshold}")

    title_label = metadata.get("label", rd.name)
    n_total_traces = metadata.get("num_traces", n_a + n_b)
    title = (f"TVLA (Welch's t)  —  {title_label}\n"
             f"N={n_total_traces}  (A_fixed={n_a}, B_random={n_b})  "
             f"peak |t|={peak_val:.2f} @ sample {peak_idx}")
    ax.set_title(title)
    ax.set_xlabel("Sample index (ADC)")
    ax.set_ylabel("Welch's t-statistic")
    ax.grid(True, alpha=0.3)
    ax.legend(loc="upper right", fontsize=9)
    fig.tight_layout()
    plot_path = rd / "tvla_plot.png"
    fig.savefig(plot_path, dpi=150)
    plt.close(fig)
    print(f"[tvla] plot saved: {plot_path}")
    print(f"[tvla] t-stat saved: {rd/'tvla_t_stat.npy'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
