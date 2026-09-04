import json
import sys
import re
import collections

path = sys.argv[1]
kinds = collections.defaultdict(list)
for line in open(path, errors='replace'):
    try:
        r = json.loads(line)
    except Exception:
        continue
    ev = r.get('assistantMessageEvent') or {}
    d = ev.get('delta')
    if isinstance(d, str):
        kinds[ev.get('type')].append(d)

for kind, parts in kinds.items():
    text = ''.join(parts)
    # tool-call arguments carry literal backslash-n; treat both as breaks
    lines = [l for l in re.split(r'\\n|\n', text) if l.strip()]
    if not lines:
        continue
    longest = 1
    current = 1
    worst = ''
    for a, b in zip(lines, lines[1:]):
        if a[:20] == b[:20]:
            current += 1
            if current > longest:
                longest = current
                worst = a
        else:
            current = 1
    counted = collections.Counter(l[:20] for l in lines)
    top, n = counted.most_common(1)[0]
    print('%-16s lines=%-6d distinct=%-6d longest same-prefix run=%d'
          % (kind, len(lines), len(set(lines)), longest))
    print('                 most common prefix %r x %d' % (top, n))
    if worst:
        print('                 run example: %r' % worst[:70])
