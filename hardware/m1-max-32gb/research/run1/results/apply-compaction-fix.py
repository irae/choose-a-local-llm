#!/usr/bin/env python3
"""
Applies the two compaction corrections found by the goal-2 label audit.

It edits the benchmark result files in place. Check the diff afterwards:
only the two compaction values should move. ensure_ascii=False matters —
without it every non-ASCII character in the file is re-escaped and the
diff becomes unreviewable.

    python3 apply-compaction-fix.py --check    # show what would change
    python3 apply-compaction-fix.py --apply    # write the change

Why: pi writes a `compaction` record for a split turn as well as for a
real compaction. A split turn is not a compaction. Two rows counted the
marker. See research/run1/results/label-audit.md for the full audit.
"""

import argparse
import json
import os
import sys


BENCH = '../mendel-benchmark/benchmark/'

CORRECTIONS = [
    {
        'file': 'results.json',
        'model_id': 'bonsai-prism',
        'thinking': 'high',
        'was': 1,
        'should_be': 0,
        'why': 'its one compaction record is a split-turn marker',
    },
    {
        'file': 'results-guided.json',
        'model_id': 'google/gemma-4-12b',
        'thinking': 'low',
        'was': 4,
        'should_be': 3,
        'why': 'three real compactions plus one split-turn marker',
    },
]


def find_row(runs, model_id, thinking):
    """Returns the single local row matching model and thinking level."""
    hits = [
        r for r in runs
        if r.get('local')
        and r.get('model_id') == model_id
        and r.get('thinking') == thinking
    ]
    return hits


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--bench', default=BENCH, help='path to benchmark/')
    args = parser.parse_args()

    if not args.apply and not args.check:
        parser.error('pass --check or --apply')

    problems = 0

    for c in CORRECTIONS:
        path = os.path.join(args.bench, c['file'])

        if not os.path.exists(path):
            print('MISSING  %s' % path)
            problems += 1
            continue

        data = json.load(open(path))
        hits = find_row(data['runs'], c['model_id'], c['thinking'])

        if len(hits) != 1:
            print('AMBIGUOUS  %s %s %s matched %d rows, expected 1' % (
                c['file'], c['model_id'], c['thinking'], len(hits)))
            problems += 1
            continue

        row = hits[0]
        telemetry = row.get('telemetry') or {}
        current = telemetry.get('compactions')

        if current == c['should_be']:
            print('ALREADY OK  %s %s: compactions is %s' % (
                c['model_id'], c['thinking'], current))
            continue

        if current != c['was']:
            print('UNEXPECTED  %s %s: compactions is %s, audit saw %s' % (
                c['model_id'], c['thinking'], current, c['was']))
            print('            Re-audit before changing anything.')
            problems += 1
            continue

        print('%s  %s %s: compactions %s -> %s (%s)' % (
            'WOULD SET' if args.check else 'SET      ',
            c['model_id'], c['thinking'], current, c['should_be'], c['why']))

        if args.apply:
            telemetry['compactions'] = c['should_be']
            row['telemetry'] = telemetry
            with open(path, 'w') as handle:
                json.dump(data, handle, indent=2, ensure_ascii=False)
                handle.write('\n')

    if problems:
        print()
        print('%d problem(s). Nothing was written for those.' % problems)
        return 1

    if args.apply:
        print()
        print('Written. Regenerate the report and commit in the mendel repo.')

    return 0


if __name__ == '__main__':
    sys.exit(main())
