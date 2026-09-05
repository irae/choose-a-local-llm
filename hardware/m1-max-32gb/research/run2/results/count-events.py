#!/usr/bin/env python3
"""count-events.py — loop metrics from a run-pi-rpc events stream.

Research run 2. Reads `<out>-events.jsonl` written by
`mendel-benchmark/benchmark/run-pi-rpc.mjs` and prints the three numbers
the Gemma-12B loop is measured by: total tool calls, distinct tool calls,
and the longest run of identical calls in a row.

Two file shapes are read, so an events stream and an archived session
log can be compared with one counter:

- `<out>-events.jsonl` — only `tool_execution_start` counts. The stream
  also carries `tool_execution_update` and `tool_execution_end` for the
  same call, and counting those inflates every number.
- a pi session log — `toolCall` parts inside `message` records.

Usage: count-events.py <file.jsonl> [...]
"""

import collections
import json
import sys


def call_from_event(record):
    if record.get('type') != 'tool_execution_start':
        return None
    name = (record.get('name')
            or record.get('toolName')
            or (record.get('tool') or {}).get('name')
            or '?')
    args = (record.get('arguments')
            or record.get('args')
            or record.get('input'))
    return name, args


def calls_from_message(record):
    if record.get('type') != 'message':
        return []
    content = (record.get('message') or {}).get('content')
    if not isinstance(content, list):
        return []
    found = []
    for part in content:
        if isinstance(part, dict) and part.get('type') == 'toolCall':
            found.append((part.get('name') or '?', part.get('arguments')))
    return found


def read_calls(path):
    calls = []
    for line in open(path, errors='replace'):
        line = line.strip()
        if not line:
            continue
        try:
            record = json.loads(line)
        except ValueError:
            continue
        found = calls_from_message(record)
        single = call_from_event(record)
        if single:
            found = [single]
        for name, args in found:
            text = json.dumps(args, sort_keys=True) if args is not None else ''
            calls.append((name, text))
    return calls


def longest_identical_run(calls):
    longest = 1 if calls else 0
    current = 1
    for first, second in zip(calls, calls[1:]):
        current = current + 1 if first == second else 1
        longest = max(longest, current)
    return longest


def report(path):
    calls = read_calls(path)
    counted = collections.Counter(calls)
    print('== %s' % path)
    print('   tool calls: %d' % len(calls))
    print('   distinct:   %d' % len(set(calls)))
    print('   longest identical run: %d' % longest_identical_run(calls))
    if counted:
        top, times = counted.most_common(1)[0]
        print('   most repeated: %d x %s %s' % (times, top[0], top[1][:100]))


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    for path in sys.argv[1:]:
        report(path)


if __name__ == '__main__':
    main()
