#!/usr/bin/env python3
"""measure-neardup.py — find near-duplicate repetition loop in model output.

Research run 2. Three detectors exist in this folder and each catches a
different shape:

- `count-events.py`   identical tool calls in a row
- `measure-repeat-run.py` identical lines in a row
- this one            lines that are not identical but are the same thing

The third shape is what a repetition penalty produces. Arm 3 ran DRY at
a 2048-token window and the model answered with 231 consecutive
`ls -d examples/<path>/*` lines, 229 of them distinct, every path
corrupted. Exact-match detectors read that as clean.

Two measures are printed, because one is not enough:

- **prefix run** — consecutive lines sharing their first N characters.
  Misses a counter that varies early in the line.
- **shape run** — consecutive lines identical after every letter run is
  replaced by `W` and every digit run by `N`. This is the one that
  catches a counter, because `bk-in_southple` and `bl-in_southple` have
  the same shape.

Usage: measure-neardup.py <events.jsonl> [prefix-length]
Exits 1 if any shape run reaches the threshold.
"""

import collections
import json
import re
import sys

SHAPE_THRESHOLD = 12


def shape(line):
    line = re.sub(r'[A-Za-z]+', 'W', line)
    line = re.sub(r'\d+', 'N', line)
    return line


def longest_run(values):
    longest = 1 if values else 0
    current = 1
    worst = None
    for first, second in zip(values, values[1:]):
        if first == second:
            current += 1
            if current > longest:
                longest = current
                worst = first
        else:
            current = 1
    return longest, worst


def read_deltas(path):
    kinds = collections.defaultdict(list)
    for line in open(path, errors='replace'):
        try:
            record = json.loads(line)
        except ValueError:
            continue
        event = record.get('assistantMessageEvent') or {}
        delta = event.get('delta')
        if isinstance(delta, str):
            kinds[event.get('type')].append(delta)
    return kinds


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    path = sys.argv[1]
    prefix_length = int(sys.argv[2]) if len(sys.argv) > 2 else 20

    worst_shape = 0
    for kind, parts in read_deltas(path).items():
        text = ''.join(parts)
        lines = [l for l in re.split(r'\\n|\n', text) if l.strip()]
        if not lines:
            continue
        prefix_run, _ = longest_run([l[:prefix_length] for l in lines])
        shape_run, shape_example = longest_run([shape(l) for l in lines])
        worst_shape = max(worst_shape, shape_run)
        print('%-16s lines=%-6d distinct=%-6d prefix-run=%-4d shape-run=%d'
              % (kind, len(lines), len(set(lines)), prefix_run, shape_run))
        if shape_run >= SHAPE_THRESHOLD:
            sample = next((l for l in lines if shape(l) == shape_example), '')
            print('                 LOOP: %d lines of one shape, e.g. %r'
                  % (shape_run, sample[:70]))

    sys.exit(1 if worst_shape >= SHAPE_THRESHOLD else 0)


if __name__ == '__main__':
    main()
