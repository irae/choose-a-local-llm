import json
import os
import collections

RUNS = '../mendel-benchmark/scratchpad/benchmark/runs/'
BENCH = '../mendel-benchmark/benchmark/'


def load_session(slug):
    path = RUNS + slug + '-session.jsonl'
    if not os.path.exists(path):
        return None

    records = []
    for line in open(path):
        line = line.strip()
        if not line:
            continue
        try:
            records.append(json.loads(line))
        except Exception:
            continue
    return records


def is_split_turn(record):
    summary = record.get('summary') or ''
    if summary.startswith('No prior history'):
        return True
    if 'split turn' in summary[:400].lower():
        return True
    return False


def analyse(slug):
    records = load_session(slug)
    if records is None:
        return None

    levels = [r.get('thinkingLevel') for r in records
              if r.get('type') == 'thinking_level_change']

    compactions = [r for r in records if r.get('type') == 'compaction']
    splits = [r for r in compactions if is_split_turn(r)]

    signatures = []
    errors = 0
    results_seen = 0

    for r in records:
        if r.get('type') != 'message':
            continue
        msg = r.get('message') or {}
        content = msg.get('content')
        if not isinstance(content, list):
            continue

        for part in content:
            if not isinstance(part, dict):
                continue

            if part.get('type') == 'toolCall':
                name = part.get('name', '?')
                args = json.dumps(part.get('arguments') or {}, sort_keys=True)
                signatures.append(name + ' ' + args)

        if msg.get('role') == 'toolResult':
            results_seen += 1
            blob = json.dumps(content).lower()
            if any(w in blob for w in ('error', 'no such file', 'not found',
                                       'failed', 'cannot', 'traceback')):
                errors += 1

    repeats = collections.Counter(signatures)
    longest = 0
    longest_what = ''
    current = 0
    previous = None
    for s in signatures:
        if s == previous:
            current += 1
        else:
            current = 1
            previous = s
        if current > longest:
            longest = current
            longest_what = s[:100]

    most = repeats.most_common(1)

    return {
        'levels': levels,
        'compaction_records': len(compactions),
        'real_compactions': len(compactions) - len(splits),
        'split_turns': len(splits),
        'tool_calls': len(signatures),
        'tool_results': results_seen,
        'error_results': errors,
        'longest_run': longest,
        'longest_what': longest_what,
        'most_count': most[0][1] if most else 0,
        'most_what': most[0][0][:100] if most else '',
        'distinct': len(repeats),
    }


def telemetry_for(slug):
    """Finds the results row whose branch or ids match this slug."""
    for fname in ['results.json', 'results-guided.json']:
        d = json.load(open(BENCH + fname))
        for r in d['runs']:
            if not r.get('local'):
                continue
            branch = (r.get('branch') or '')
            model = (r.get('model_id') or '').replace('/', '-')
            think = r.get('thinking') or ''
            kind = 'guided' if 'guided' in fname else 'blind'
            guess = '%s-%s-%s' % (model, think, kind)
            if guess == slug or slug in branch:
                return fname, r
    return None, None


available = sorted(set(
    f[:-len('-session.jsonl')] for f in os.listdir(RUNS)
    if f.endswith('-session.jsonl')
))

for slug in available:
    a = analyse(slug)
    fname, row = telemetry_for(slug)
    tel = (row or {}).get('telemetry') or {}

    print("=" * 72)
    print(slug)
    print("  row matched            : %s" % (fname or 'NOT MATCHED'))
    print("  thinking events in log : %s" % (a['levels'] or 'NONE'))
    print("  row says thinking      : %s" % (row or {}).get('thinking'))
    print("  compaction records     : %d  (real %d, split-turn %d)" % (
        a['compaction_records'], a['real_compactions'], a['split_turns']))
    print("  row says compactions   : %s" % tel.get('compactions'))
    print("  tool calls in log      : %d  (distinct %d)" % (
        a['tool_calls'], a['distinct']))
    print("  row says tool_calls    : %s" % tel.get('tool_calls'))
    print("  error-ish results      : %d / %d" % (
        a['error_results'], a['tool_results']))
    print("  row says tool_errors   : %s" % tel.get('tool_errors'))
    print("  longest identical run  : %d  %s" % (a['longest_run'], a['longest_what']))
    print("  most repeated call     : %d  %s" % (a['most_count'], a['most_what']))
