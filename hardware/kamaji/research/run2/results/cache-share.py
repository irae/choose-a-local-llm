#!/usr/bin/env python3
"""cache-share.py — prompt-cache health for a local-backend run.

Research run 2, experiment T0.4 (AGENT.md section G). A config that
never hits the prompt cache re-reads the whole context every turn. It
runs far slower and can die on the time budget. That is the config's
fault, not the model's, and it is visible from the first minutes.

Reads `<out>-events.jsonl` from `run-pi-rpc.mjs` and reports, per
assistant turn, how much of the prompt came from the cache. The numbers
come from pi's own usage records, which local backends do populate:
`cacheRead` is filled from `usage.prompt_tokens_details.cached_tokens`,
which both llama-server and `mlx_lm.server` 0.31.3 return.

Alert rule, proposed: after turn 3, a cache share below 20 percent means
the serving config is wrong. Fix the config before blaming the model.

Usage: cache-share.py <events.jsonl> [--threshold 0.2] [--after 3]
"""

import json
import sys

DEFAULT_THRESHOLD = 0.2
DEFAULT_AFTER_TURN = 3


def read_turns(path):
    turns = []
    seen = set()
    for line in open(path, errors='replace'):
        line = line.strip()
        if not line:
            continue
        try:
            record = json.loads(line)
        except ValueError:
            continue
        message = record.get('message') or {}
        if message.get('role') != 'assistant':
            continue
        usage = message.get('usage')
        if not usage:
            continue
        prompt = usage.get('input', 0) + usage.get('cacheRead', 0)
        if prompt == 0:
            continue
        key = (prompt, usage.get('output', 0), usage.get('cacheRead', 0))
        if key in seen:
            continue
        seen.add(key)
        turns.append({
            'prompt': prompt,
            'fresh': usage.get('input', 0),
            'cached': usage.get('cacheRead', 0),
            'output': usage.get('output', 0),
        })
    return turns


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    path = sys.argv[1]
    threshold = DEFAULT_THRESHOLD
    after = DEFAULT_AFTER_TURN
    if '--threshold' in sys.argv:
        threshold = float(sys.argv[sys.argv.index('--threshold') + 1])
    if '--after' in sys.argv:
        after = int(sys.argv[sys.argv.index('--after') + 1])

    turns = read_turns(path)
    print('turn  prompt   fresh   cached  share')
    total_prompt = 0
    total_cached = 0
    low = []
    for number, turn in enumerate(turns, start=1):
        share = turn['cached'] / turn['prompt']
        total_prompt += turn['prompt']
        total_cached += turn['cached']
        print('%4d  %6d  %6d  %7d  %5.1f%%'
              % (number, turn['prompt'], turn['fresh'], turn['cached'],
                 100 * share))
        if number > after and share < threshold:
            low.append(number)

    if not turns:
        print('no usage records with a prompt; nothing to judge')
        return

    print('')
    print('run cache share: %.1f%% (%d of %d prompt tokens)'
          % (100 * total_cached / total_prompt, total_cached, total_prompt))
    if low:
        print('ALERT: %d turns after turn %d served under %.0f%% from cache: %s'
              % (len(low), after, 100 * threshold,
                 ', '.join(str(n) for n in low[:12])))
    else:
        print('cache health OK')


if __name__ == '__main__':
    main()
