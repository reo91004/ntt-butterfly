#!/usr/bin/env python3
"""
Correlation Power Analysis (CPA) recovering the secret `b` from a vary-k capture.

Setup expected:
    - capture_traces.py was run with  --vary k  (k uniform, b fixed = secret)
    - inputs.npz contains b (constant), k (per-trace), and traces.npy

Attack:
    For each candidate b_hyp in [0, q):
        for each trace i:  predicted = HW( (b_hyp * zeta(k_i)) mod 2^32 )
        score(b_hyp) = max_s |Pearson_corr( predicted, traces[:, s] )|
    Plot score vs b_hyp.   The maximum at b_hyp = b_secret demonstrates recovery.

Outputs (into results dir):
    cpa_scores.npy            shape=(num_candidates,) max-corr per candidate
    cpa_winning_corr.npy      shape=(samples,) corr trace for the winning candidate
    cpa_plot.png              candidate vs score, with secret marked
"""
import argparse
import json
import re
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

from sca_config import KYBER_Q, DILITHIUM_Q


def load_zeta_table(coe_path):
    text = Path(coe_path).read_text()
    m = re.search(r"memory_initialization_vector\s*=\s*([0-9a-fA-F,\s;]+)", text)
    if not m:
        raise RuntimeError(f"could not parse vector from {coe_path}")
    vals = [int(h, 16) for h in re.split(r"[,\s;]+", m.group(1)) if h.strip()]
    return np.array(vals, dtype=np.uint32)


def hamming_weight_u32(x):
    """Vectorized HW for uint32. Returns int8."""
    x = x.astype(np.uint32, copy=False)
    x = (x & 0x55555555) + ((x >> 1) & 0x55555555)
    x = (x & 0x33333333) + ((x >> 2) & 0x33333333)
    x = (x & 0x0F0F0F0F) + ((x >> 4) & 0x0F0F0F0F)
    x = (x & 0x00FF00FF) + ((x >> 8) & 0x00FF00FF)
    x = (x & 0x0000FFFF) + ((x >> 16) & 0x0000FFFF)
    return x.astype(np.int8)


def pearson_corr_vec(x, Y):
    """Pearson correlation between 1-D x (n,) and each column of Y (n, S).

    Returns (S,) — uses fast vectorized formula.
    """
    n = x.shape[0]
    x = x.astype(np.float64)
    Y = Y.astype(np.float64)
    xm = x - x.mean()
    Ym = Y - Y.mean(axis=0)
    num = xm @ Ym
    den = np.sqrt((xm @ xm) * (Ym * Ym).sum(axis=0))
    den = np.where(den < 1e-30, 1e-30, den)
    return num / den


def main():
    p = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    p.add_argument("results_dir", type=Path)
    p.add_argument("--coe", default="ip/unified_zeta.coe",
                   help="Path to the ROM .coe file (relative to project root)")
    p.add_argument("--mode2", type=int, choices=[0, 1], default=None,
                   help="0=Kyber, 1=Dilithium. If omitted, read from metadata.")
    p.add_argument("--mode", type=int, choices=[0, 1], default=None,
                   help="1=CT (zeta), 0=GS (inv_zeta). If omitted, from metadata.")
    p.add_argument("--max-cand", type=int, default=None,
                   help="Cap number of candidates evaluated; default = q.")
    p.add_argument("--focus-sample", type=int, default=None,
                   help="If set, only score against this single sample (faster).")
    args = p.parse_args()

    rd = args.results_dir.resolve()
    traces = np.load(rd / "traces.npy")
    inputs = np.load(rd / "inputs.npz")
    meta_path = rd / "metadata.json"
    metadata = json.loads(meta_path.read_text()) if meta_path.exists() else {}

    mode  = args.mode  if args.mode  is not None else int(metadata.get("fixed_inputs", {}).get("mode",  1))
    mode2 = args.mode2 if args.mode2 is not None else int(metadata.get("fixed_inputs", {}).get("mode2", 0))
    q = KYBER_Q if mode2 == 0 else DILITHIUM_Q
    secret = int(inputs["b"][0])      # we wrote b_fixed everywhere
    print(f"[cpa] mode2={mode2} ({'Kyber' if mode2==0 else 'Dilithium'})  "
          f"mode={mode} ({'CT/zeta' if mode==1 else 'GS/inv_zeta'})  q={q}")
    print(f"[cpa] true secret b = {secret}  (this is what we should recover)")
    print(f"[cpa] N={traces.shape[0]} traces, samples={traces.shape[1]}")

    # zeta lookup
    coe_path = (Path(__file__).resolve().parent.parent / args.coe)
    rom = load_zeta_table(coe_path)
    if mode2 == 0:
        base = 256 if mode == 1 else 0       # Kyber zeta vs inv_zeta
    else:
        base = 768 if mode == 1 else 512     # Dilithium zeta vs inv_zeta
    k_arr = inputs["k"].astype(np.int64)
    zeta_per_trace = rom[base + k_arr].astype(np.uint64)
    print(f"[cpa] zeta table base={base}, sample zetas per first 5 traces: "
          f"{[int(z) for z in zeta_per_trace[:5]]}")

    # candidates
    n_cand = args.max_cand if args.max_cand else q
    print(f"[cpa] sweeping {n_cand} candidate b values...")

    scores = np.zeros(n_cand, dtype=np.float64)
    if args.focus_sample is not None:
        x_traces = traces[:, args.focus_sample:args.focus_sample+1]
    else:
        x_traces = traces

    # to keep memory manageable, do candidates in chunks
    CHUNK = 256
    for start in range(0, n_cand, CHUNK):
        stop = min(start + CHUNK, n_cand)
        for cand in range(start, stop):
            # predicted intermediate value: (cand * zeta) mod 2^32
            pred = (np.uint64(cand) * zeta_per_trace) & np.uint64(0xFFFFFFFF)
            hw = hamming_weight_u32(pred)
            corr = pearson_corr_vec(hw, x_traces)
            scores[cand] = float(np.max(np.abs(corr)))
        print(f"  [{stop}/{n_cand}]  best-so-far b={int(np.argmax(scores))}  "
              f"score={scores.max():.4f}")

    winner = int(np.argmax(scores))
    print()
    print(f"[cpa] winner: b_hyp = {winner}   score = {scores[winner]:.4f}")
    if winner == secret:
        print(f"[cpa] ✓ SUCCESS — recovered the secret correctly")
    else:
        print(f"[cpa] ✗ MISMATCH — true secret was {secret}")
    rank_of_secret = int(np.sum(scores > scores[secret])) + 1
    print(f"[cpa] true-secret rank: {rank_of_secret}/{n_cand}  (score={scores[secret]:.4f})")

    # save winning candidate's full corr trace (for plot)
    pred = (np.uint64(winner) * zeta_per_trace) & np.uint64(0xFFFFFFFF)
    hw = hamming_weight_u32(pred)
    win_corr = pearson_corr_vec(hw, traces)

    np.save(rd / "cpa_scores.npy",        scores)
    np.save(rd / "cpa_winning_corr.npy",  win_corr)

    # ------ plot ------
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(11, 6))

    ax1.plot(scores, color="#1f77b4", lw=0.6)
    ax1.axvline(secret, color="green", lw=1.2, ls="--",
                label=f"true secret b = {secret}")
    ax1.scatter([secret], [scores[secret]], color="green", s=80, zorder=5)
    if winner != secret:
        ax1.scatter([winner], [scores[winner]], color="red", s=80, zorder=5,
                    label=f"top guess b = {winner}")
    ax1.set_xlabel("candidate b value")
    ax1.set_ylabel("max |Pearson r| over samples")
    ax1.set_title(f"CPA — max-correlation per candidate  (winner = {winner}, "
                  f"true = {secret}, "
                  f"{'✓ SUCCESS' if winner == secret else '✗ FAIL'})")
    ax1.legend(loc="upper right", fontsize=9)
    ax1.grid(alpha=0.3)

    ax2.plot(win_corr, color="#1f77b4", lw=0.8)
    peak_s = int(np.argmax(np.abs(win_corr)))
    ax2.scatter([peak_s], [win_corr[peak_s]], color="red", s=60, zorder=5,
                label=f"peak |r| @ sample {peak_s}, r={win_corr[peak_s]:+.3f}")
    ax2.axhline(0, color="grey", lw=0.5)
    ax2.set_xlabel("sample index")
    ax2.set_ylabel("Pearson r (HW model vs trace)")
    ax2.set_title(f"Correlation trace for winning candidate b={winner}")
    ax2.legend(loc="upper right", fontsize=9)
    ax2.grid(alpha=0.3)

    fig.tight_layout()
    plot_path = rd / "cpa_plot.png"
    fig.savefig(plot_path, dpi=150)
    plt.close(fig)
    print(f"[cpa] plot saved: {plot_path}")
    return 0 if winner == secret else 1


if __name__ == "__main__":
    sys.exit(main())
