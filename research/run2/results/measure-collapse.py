#!/usr/bin/env python3
"""measure-collapse.py — find repetition collapse in a model's thinking.

Research run 2. `flood-check.py` looks for runs of newlines, which is
the shape the Gemma-12B flood took. This looks for the other shape:
the same LINE emitted over and over.

That shape is invisible to a newline check and to a tool-call counter,
because the model keeps producing varied, well-formed text while saying
one thing repeatedly inside the thought channel. It was found by hand on
run 2 arm 2, where one line repeated 173 times in a row.

Usage: measure-collapse.py <events.jsonl>
"""

import json
import collections
import sys

path = sys.argv[1] if len(sys.argv) > 1 else '/tmp/run2/replay-short/replay-events.jsonl"'.rstrip('"')
deltas = []
for line in open(path, errors='replace'):
    try:
        r = json.loads(line)
    except Exception:
        continue
    ev = r.get('assistantMessageEvent') or {}
    if ev.get('type') == 'thinking_delta' and isinstance(ev.get('delta'), str):
        deltas.append((r.get('t'), ev['delta']))

text = ''.join(d for _, d in deltas)
lines = [l for l in text.split('\n') if l.strip()]
counted = collections.Counter(lines)

print('thinking chars total:', len(text))
print('non-empty thinking lines:', len(lines), 'distinct:', len(set(lines)))
print('')
print('most repeated thinking lines:')
for line, n in counted.most_common(5):
    print('  %4d x  %s' % (n, line[:90]))

longest = 1
current = 1
worst = None
for a, b in zip(lines, lines[1:]):
    if a == b:
        current += 1
        if current > longest:
            longest = current
            worst = a
    else:
        current = 1
print('')
print('longest identical consecutive line run:', longest)
if worst:
    print('  the line:', worst[:90])
print('')
if deltas:
    print('first delta at', deltas[0][0], 'last at', deltas[-1][0])

THRESHOLD = 5
sys.exit(1 if longest >= THRESHOLD else 0)
