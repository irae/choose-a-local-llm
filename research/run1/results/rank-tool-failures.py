import json

rows = []
for fname, kind in [('results.json', 'blind'), ('results-guided.json', 'guided')]:
    d = json.load(open('../mendel-benchmark/benchmark/' + fname))
    for r in d['runs']:
        if not r.get('local'):
            continue
        t = r.get('telemetry') or {}
        calls = t.get('tool_calls') or 0
        errs = t.get('tool_errors') or 0
        rows.append({
            'model': r.get('model_id', '?'),
            'kind': kind,
            'think': r.get('thinking'),
            'end': r.get('end_reason'),
            'calls': calls,
            'errors': errs,
            'rate': (errs / calls * 100) if calls else 0.0,
            'nudge_tool': t.get('nudges_tooling'),
            'compactions': t.get('compactions'),
            'peak': t.get('peak_context'),
        })

rows.sort(key=lambda x: -x['rate'])

print("%-38s %-7s %-6s %6s %6s %7s %5s" % (
    "model", "kind", "think", "calls", "errs", "err%", "nudge"))
for r in rows:
    print("%-38s %-7s %-6s %6d %6d %6.1f%% %5s" % (
        r['model'][:38], r['kind'], str(r['think']),
        r['calls'], r['errors'], r['rate'], str(r['nudge_tool'])))

print()
print("=== totals by model ===")
agg = {}
for r in rows:
    a = agg.setdefault(r['model'], {'calls': 0, 'errors': 0, 'runs': 0})
    a['calls'] += r['calls']
    a['errors'] += r['errors']
    a['runs'] += 1

for m, a in sorted(agg.items(), key=lambda kv: -(kv[1]['errors'] / kv[1]['calls'] if kv[1]['calls'] else 0)):
    rate = a['errors'] / a['calls'] * 100 if a['calls'] else 0
    print("%-38s runs=%d calls=%5d errors=%4d  %5.1f%%" % (
        m[:38], a['runs'], a['calls'], a['errors'], rate))
