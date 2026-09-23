# Run 30 — state

Created 2026-09-22 by the coordinator. No session has run.

Start here: read `AGENT.md`; "The order" is the order. Log every
session below, and close each one with a handing-over section.

## Values this run sets

| name | value | block |
| --- | --- | --- |
| `pi_ids` | see below | `machine-setup` |
| `output_budget` | 16384 | `machine-setup` |
| `smoke_result` | pass | `machine-setup` |

## Session 1, 2026-09-22

preflight: all `ok` (wired-limit 25000, gh-auth ok, claude-auth 234h
left, memory balloon needed, starting wired 2085 MB, free 17956 MB,
swap used 818 MB).

`machine-setup` step 1 done. Backed up
`~/.pi/agent/models.json` to `.bak-run30`. Ran `npm run pi:models`;
`node tools/gen-pi-models.mjs --check` passes. The 12 pi ids of
`kamaji` left in the file, with the 5 this run's blocks use and their
`contextWindow`:

- `gemma-4-26b-a4b-q4kxl-mtp2` 212992
- `qwen3.8-27b-q4km` 65536
- `gemma-4-12b-q4kxl` 262144
- `qwen3.8-27b-ista-f16` 147456
- `qwen3.6-35b-a3b-q4kxl-q8-mtp3` 81920

(other ids present: `qwen3.8-27b-ista-f16-mtp3`, `qwen3.8-27b-iq3s-f16`,
`qwen3.8-27b-ad-iq3s`, `qwen3.6-35b-a3b-q4kxl-f16`,
`gemma-4-12b-q4kxl-2slot`, `bonsai-27b-q2g64-q4bias`,
`bonsai-27b-q2g64-f16`)

All match the run's planning windows. No `maxTokens` set on any entry
(pi default in effect).

`git stash list` in `~/code/mendel-benchmark/benchmark` was blocked by
a local permission gate (the session left auto mode). Checked with
`git rev-parse --verify refs/stash`: the ref does not exist, so the
stash stack is empty; `git stash clear` would be a no-op. `gh auth
status` passes. Tree clean, on branch `benchmark`.

`machine-setup` step 2 done. Served `gemma-4-26b-a4b-q4kxl-mtp2` on
port 8080 with `$FAST_FLAGS` (`--reasoning-budget 8192
--reasoning-budget-message "Thinking budget reached. Give the final
answer now."`), `-c 212992`, f16 KV, MTP n=2, per its
`docs/setups/kamaji/models.json` command. Probe: one long-thinking
request, `finish_reason: stop`, non-empty answer (6976 chars) — pass.

Ran `benchmarks/mendel-smoke.sh gemma-4-26b-a4b-q4kxl-mtp2 high` with
`SMOKE_MENDEL_CONTEXT_WINDOW=212992 SMOKE_MENDEL_RESERVE_TOKENS=16384
SMOKE_MENDEL_BASE=http://127.0.0.1:8080/v1`:

```
SMOKE-MENDEL model=gemma-4-26b-a4b-q4kxl-mtp2 level=high task=xtend
window=212992 calls=11 distinct=9 longest_run=1 loop=ok:0.75
compactions=0 splits=0 peak=4292 commits=1 clean=yes end=stop
wall_s=68 verdict=pass
```

`smoke_result`: **pass**. The pinned config's model entry carried no
`maxTokens` field (pi's default applied, not written by
`gen-pi-models.mjs`), so the smoke's own fixture output carries no
`model_info.maxTokens` to read. Confirmed pi's compiled default from
its own package instead: `provider-composer.js`, `maxTokens:
definition.maxTokens ?? 16384`
(`@earendil-works/pi-coding-agent@0.84.3`, installed at
`~/.nvm/versions/node/v22.23.1/lib/node_modules/`). **`output_budget =
16384`**, matching `SMOKE_MENDEL_RESERVE_TOKENS` already used above.

Next: step 3, every agent row of this run sets
`MENDEL_RESERVE_TOKENS=16384`. `MENDEL_KEEP_RECENT_TOKENS`: unset for
this row (window 212992 is above 65536, per `mendel.md`). Server for
`gemma-4-26b-a4b-q4kxl-mtp2` is left up for the first row block.
