import json
import sys
import collections

for path in sys.argv[1:]:
    kinds = collections.Counter()
    chars = collections.Counter()
    for line in open(path, errors='replace'):
        try:
            r = json.loads(line)
        except Exception:
            continue
        ev = r.get('assistantMessageEvent') or {}
        t = ev.get('type')
        if t and 'delta' in t:
            kinds[t] += 1
            chars[t] += len(ev.get('delta') or '')
    print('==', path.split('/')[-2])
    for t in sorted(kinds):
        print('   %-18s %6d deltas  %8d chars' % (t, kinds[t], chars[t]))
