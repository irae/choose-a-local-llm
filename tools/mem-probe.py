#!/usr/bin/env python3
"""
mem-probe.py — measure how much wired GPU memory this Mac will actually
yield to MLX, and whether forcing memory pressure first changes that.

Two probes run back to back. Each grows an MLX allocation in steps until
the allocation fails, records the ceiling, then frees everything.

  Probe 1 finds the ceiling from the machine's current state.
  Probe 2 finds it again, after probe 1 has already pushed the system.

If probe 2 reaches higher, pressure moved idle pages out of the way and
they stayed out. That is the balloon effect. If the ceilings match, the
system yields the same amount either way and pre-warming is pointless.

Safety: MLX raises on a failed allocation, so the ceiling is found by a
caught exception, not by an out-of-memory kill. STEP_MB and CAP_MB bound
the walk. Everything is freed between probes and at exit.

Usage: python3 tools/mem-probe.py [--step MB] [--cap MB]
"""

import argparse
import gc
import subprocess
import sys
import time

import mlx.core as mx


PAGE_SIZE = 16384
MB = 1024 * 1024


def vm_stat():
    """Returns the vm_stat page counters as a dict of MB."""
    out = subprocess.run(["vm_stat"], capture_output=True, text=True).stdout

    stats = {}
    for line in out.splitlines():
        if ":" not in line:
            continue

        name, _, value = line.partition(":")
        value = value.strip().rstrip(".")

        if not value.isdigit():
            continue

        stats[name.strip()] = int(value) * PAGE_SIZE // MB

    return stats


def swap_used_mb():
    """Returns megabytes of swap in use."""
    out = subprocess.run(
        ["sysctl", "-n", "vm.swapusage"], capture_output=True, text=True
    ).stdout

    parts = out.replace("=", " ").split()

    for index, word in enumerate(parts):
        if word == "used":
            return float(parts[index + 1].rstrip("M"))

    return 0.0


def report(label):
    """Prints one two-line memory snapshot and returns the raw stats."""
    stats = vm_stat()

    print(
        "  {:<22} free {:>6} MB   active {:>6} MB   wired {:>5} MB".format(
            label,
            stats.get("Pages free", 0),
            stats.get("Pages active", 0),
            stats.get("Pages wired down", 0),
        )
    )

    print(
        "  {:<22} compressor {:>4} MB   inactive {:>6} MB   swap {:>5.0f} MB".format(
            "",
            stats.get("Pages occupied by compressor", 0),
            stats.get("Pages inactive", 0),
            swap_used_mb(),
        )
    )

    return stats


def allocate_one_block(size_mb):
    """Allocates size_mb of GPU memory and writes to it so it is resident."""
    elements = size_mb * MB // 4
    block = mx.ones((elements,), dtype=mx.float32)
    mx.eval(block)
    return block


def free_everything(blocks):
    blocks.clear()
    gc.collect()
    mx.clear_cache()


def run_probe(name, step_mb, cap_mb):
    print()
    print("=== {} ===".format(name))

    before = report("before")

    blocks = []
    held_mb = 0
    failure = None

    while held_mb + step_mb <= cap_mb:
        try:
            blocks.append(allocate_one_block(step_mb))
        except Exception as error:
            failure = str(error).split("\n")[0][:90]
            break

        held_mb = held_mb + step_mb

        if held_mb % 4096 == 0:
            print("  holding {:>6} MB".format(held_mb))

    print("  CEILING {} MB".format(held_mb))

    if failure:
        print("  stopped by: {}".format(failure))
    else:
        print("  stopped by: reached the {} MB cap".format(cap_mb))

    at_peak = report("at peak")

    free_everything(blocks)
    time.sleep(5)

    after = report("after release")

    return {
        "name": name,
        "ceiling_mb": held_mb,
        "before": before,
        "at_peak": at_peak,
        "after": after,
    }


def check_wired_limit():
    """Reads the GPU wired limit and warns when it is unset."""
    out = subprocess.run(
        ["sysctl", "-n", "iogpu.wired_limit_mb"], capture_output=True, text=True
    ).stdout.strip()

    limit = int(out) if out.isdigit() else 0
    print("iogpu.wired_limit_mb = {}".format(limit))

    if limit == 0:
        print("WARNING: 0 means the system default, not 'no limit'.")
        print("It resets to 0 on every reboot. Set it before a run:")
        print("  sudo sysctl iogpu.wired_limit_mb=24000")

    return limit


def summarize(first, second, step_mb):
    print()
    print("=== RESULT ===")
    print("  probe 1 ceiling: {:>6} MB".format(first["ceiling_mb"]))
    print("  probe 2 ceiling: {:>6} MB".format(second["ceiling_mb"]))

    delta = second["ceiling_mb"] - first["ceiling_mb"]
    print("  delta:           {:>+6} MB".format(delta))

    if delta > step_mb:
        print("  Pressure helped. The balloon effect is real.")
    elif delta < -step_mb:
        print("  Pressure hurt. The first probe left the machine worse off.")
    else:
        print("  No difference beyond one step. Pre-warming is pointless.")

    compressor = first["after"].get("Pages occupied by compressor", 0)

    print()
    print("  compressor after probe 1 released: {} MB".format(compressor))

    if compressor > 0:
        print("  Pages stayed compressed, so pressure did move idle memory out.")
    else:
        print("  Nothing stayed compressed. The system had room without it.")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--step", type=int, default=512, help="step size in MB")
    parser.add_argument("--cap", type=int, default=30000, help="stop at this many MB")
    args = parser.parse_args()

    print("mem-probe — {}".format(time.strftime("%Y-%m-%d %H:%M:%S")))
    check_wired_limit()
    print("step {} MB, cap {} MB".format(args.step, args.cap))

    first = run_probe("probe 1, from current state", args.step, args.cap)

    print()
    print("Settling for 60 seconds before the second probe.")
    time.sleep(60)

    second = run_probe("probe 2, after pressure", args.step, args.cap)

    summarize(first, second, args.step)


if __name__ == "__main__":
    sys.exit(main())
