"""Turn one or more GPU sample files into a table row each.

Reads the CSV that `gpu-sample.sh` writes and the CSV that `laya-run.py`
writes with `--gpu-log`; both carry the same columns, and the runner's
also carries a `phase`. With `--phase measure` only the measured window
of a runner file is read.

  gpu-table.py [--phase P] [--label-from-name] <file> [file ...]
"""
import argparse
import csv
import os
import statistics


def read(path, phase=None):
    rows = []
    with open(path) as f:
        for r in csv.DictReader(f):
            if phase and r.get("phase") != phase:
                continue
            rows.append(r)
    return rows


def col(rows, name):
    return sorted(float(r[name]) for r in rows if r.get(name) not in (None, ""))


def stats(v):
    if not v:
        return None
    return (v[0], v[len(v) // 2], v[min(len(v) - 1, int(0.95 * len(v)))], v[-1],
            statistics.fmean(v))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="+")
    ap.add_argument("--phase", default="")
    ap.add_argument("--idle-mb", type=float, default=954.0,
                    help="the desktop's own use, subtracted for the test-only column")
    args = ap.parse_args()

    print("| test | samples | seconds | VRAM MB min | p50 | p95 | max | max over idle | GPU util % p50 | p95 | max | mem util % p50 | max | power W p50 | max | clock MHz p50 | max | temp C max |")
    print("| " + " | ".join(["---"] * 18) + " |")
    for path in args.files:
        rows = read(path, args.phase or None)
        if not rows:
            print("| `%s` | 0 | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — |"
                  % os.path.basename(path))
            continue
        t = col(rows, "t")
        mem = stats(col(rows, "mem_used_mb"))
        ug = stats(col(rows, "util_gpu_pct"))
        um = stats(col(rows, "util_mem_pct"))
        pw = stats(col(rows, "power_w"))
        ck = stats(col(rows, "clock_mhz"))
        tp = stats(col(rows, "temp_c"))
        name = os.path.basename(path).replace(".csv", "")
        print("| `%s` | %d | %.0f | %.0f | %.0f | %.0f | %.0f | %.0f | %.0f | %.0f | %.0f | %.0f | %.0f | %.1f | %.1f | %.0f | %.0f | %.0f |"
              % (name, len(rows), t[-1] - t[0],
                 mem[0], mem[1], mem[2], mem[3], mem[3] - args.idle_mb,
                 ug[1], ug[2], ug[3], um[1], um[3], pw[1], pw[3], ck[1], ck[3], tp[3]))


if __name__ == "__main__":
    main()
