#!/usr/bin/env python3
"""flood-check.py — is the model flooding right now?

Research run 2. Reads a `run-pi-rpc.mjs` events stream and reports runs
of newlines produced BY THE MODEL.

The distinction matters and cost one false alarm. A tool result can hold
any amount of blank space — the first version of this check fired on
HTML that `curl` fetched from a GitHub issue page. Only
`assistantMessageEvent` deltas are model output. Tool results,
`tool_execution_update` records and prompts are not.

Usage: flood-check.py <events.jsonl> [min-newlines]
Exit 1 if a flood is present, 0 if not, so a monitor can act on it.
"""

import json
import re
import sys

DEFAULT_MIN = 8


def model_text(path):
    chunks = []
    for line in open(path, errors='replace'):
        line = line.strip()
        if not line:
            continue
        try:
            record = json.loads(line)
        except ValueError:
            continue
        event = record.get('assistantMessageEvent') or {}
        delta = event.get('delta')
        if isinstance(delta, str):
            chunks.append((event.get('type'), delta))
    return chunks


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    path = sys.argv[1]
    minimum = int(sys.argv[2]) if len(sys.argv) > 2 else DEFAULT_MIN

    chunks = model_text(path)
    joined = {}
    for kind, delta in chunks:
        joined[kind] = joined.get(kind, '') + delta

    found = False
    for kind, text in sorted(joined.items()):
        runs = re.findall(r'\n{%d,}' % minimum, text)
        channels = text.count('<|channel>')
        if runs:
            found = True
            print('FLOOD in %s: %d runs of %d+ newlines, longest %d, '
                  '%d channel-open tokens'
                  % (kind, len(runs), minimum, max(len(r) for r in runs),
                     channels))
        else:
            print('clean: %s, %d chars, %d channel-open tokens'
                  % (kind, len(text), channels))

    sys.exit(1 if found else 0)


if __name__ == '__main__':
    main()
