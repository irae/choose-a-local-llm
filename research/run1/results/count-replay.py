#!/usr/bin/env python3
"""
count-replay.py — reads the replay-probe sessions and prints the numbers
the goal-3 trial compares: loop length, distinct calls, and crashes.

Usage: python3 count-replay.py [output-dir]
"""

import collections
import glob
import json
import os
import sys


def session_files(session_dir):
    return sorted(glob.glob(os.path.join(session_dir, '**', '*.jsonl'),
                            recursive=True))


def read_records(path):
    records = []
    for line in open(path, errors='replace'):
        line = line.strip()
        if not line:
            continue
        try:
            records.append(json.loads(line))
        except Exception:
            continue
    return records


def measure(session_dir):
    signatures = []
    tool_results = 0
    crashes = 0

    for path in session_files(session_dir):
        for r in read_records(path):
            if r.get('type') != 'message':
                continue

            msg = r.get('message') or {}
            content = msg.get('content')
            if not isinstance(content, list):
                continue

            if msg.get('role') == 'toolResult':
                tool_results += 1

            for part in content:
                if not isinstance(part, dict):
                    continue
                if part.get('type') != 'toolCall':
                    continue
                name = part.get('name', '?')
                args = json.dumps(part.get('arguments') or {}, sort_keys=True)
                signatures.append(name + ' ' + args)

    longest = 0
    current = 0
    previous = None
    longest_what = ''

    for s in signatures:
        if s == previous:
            current += 1
        else:
            current = 1
            previous = s
        if current > longest:
            longest = current
            longest_what = s[:90]

    counts = collections.Counter(signatures)
    most = counts.most_common(1)

    return {
        'calls': len(signatures),
        'distinct': len(counts),
        'longest_run': longest,
        'longest_what': longest_what,
        'most_count': most[0][1] if most else 0,
        'tool_results': tool_results,
        'crashes': crashes,
    }


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else '/tmp/toolcall-trial'

    dirs = sorted(glob.glob(os.path.join(out, 'session-*')))
    if not dirs:
        print('No sessions under %s' % out)
        return 1

    print('%-34s %6s %8s %8s %8s' % (
        'run', 'calls', 'distinct', 'longest', 'mostrep'))

    rows = {}
    for d in dirs:
        label = os.path.basename(d)[len('session-'):]
        m = measure(d)
        rows[label] = m
        print('%-34s %6d %8d %8d %8d' % (
            label, m['calls'], m['distinct'], m['longest_run'],
            m['most_count']))

    print()
    print('=== arm comparison ===')
    seen = set()
    for label in rows:
        if label.endswith('-no-rules'):
            base = label[:-len('-no-rules')]
        elif label.endswith('-with-rules'):
            base = label[:-len('-with-rules')]
        else:
            continue
        if base in seen:
            continue
        seen.add(base)

        a = rows.get(base + '-no-rules')
        b = rows.get(base + '-with-rules')
        if not a or not b:
            continue

        print('%s' % base)
        print('  longest identical run : %d without -> %d with  (%+d)' % (
            a['longest_run'], b['longest_run'],
            b['longest_run'] - a['longest_run']))
        print('  total calls           : %d without -> %d with  (%+d)' % (
            a['calls'], b['calls'], b['calls'] - a['calls']))
        if a['calls'] and b['calls']:
            ra = a['distinct'] / a['calls']
            rb = b['distinct'] / b['calls']
            print('  distinct fraction     : %.2f without -> %.2f with' % (ra, rb))

    return 0


if __name__ == '__main__':
    sys.exit(main())
