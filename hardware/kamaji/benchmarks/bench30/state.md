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

## `gemma26-q4kxl-mtp2-guided-tb8192`, started 2026-09-22 ~23:42

Added temporary pi entry `gemma-4-26b-a4b-q4kxl-mtp2-tb8192` (copy of
`gemma-4-26b-a4b-q4kxl-mtp2`, `contextWindow 212992`). Server already
up from `machine-setup` (port 8080, `$FAST_FLAGS`).

Launched `run-worker.sh gemma-4-26b-a4b-q4kxl-mtp2-tb8192 pi guided
high` with `MENDEL_CONTEXT_WINDOW=212992 MENDEL_RESERVE_TOKENS=16384`
(no `MENDEL_KEEP_RECENT_TOKENS`, window above 65536). Worktree
`../mendel-bench-guided-gemma-4-26b-a4b-q4kxl-mtp2-tb8192-high`,
branch `gemma-4-26b-a4b-q4kxl-mtp2-tb8192-high-guided-v3-issue-13`.
`gh auth status` passed before the worker started (checked at
machine-setup, still valid). Output file
`~/.local/share/mendel-benchmark/runs/gemma-4-26b-a4b-q4kxl-mtp2-tb8192-high-guided-events.jsonl`,
growing. `benchmarks/run-watch.sh` armed on that file,
`RUNWATCH_SILENCE=2700`, memory log at
`hardware/kamaji/benchmarks/bench30/results/mem-gemma26-guided.log`.

Finished 2026-09-23 05:52 UTC (pi's own clock; about 3h10m). End
reason `done — model stopped, work complete`, a clean stop. Loop
verdict `ok`, worst ratio 0.23 on tool call (`<slug>-loop.txt`,
`<slug>-worker.json`). 29 commits, tree clean. `count-tool-calls.mjs`:
278 tool calls, 281 assistant messages, peak_context 212713 (window
212992). `output_limit_hits`: one entry, 1 output token, not at
budget, blocked thinking, at 04:47:54Z — a stray, not a budget hit.
`turn_timeout`: none. Grepped the server log for the budget message:
**0 fires**, so the reasoning budget 8192 never bound on this row,
matching run 22's finding on a different model.

**Correction, 2026-09-23** (coordinator, from an `arrietty` test on
the same build: the server log never carries the injected budget
message, confirmed independently). Re-counted from the pi-side files
instead: `…-events.jsonl` and `…-session.jsonl`, both `grep -c` 0
matches. Conclusion unchanged, now on the right evidence. See
`results.md` for the corrected note.

Scored by a subagent on `claude-opus-5` (per PLAN.md, "How to score a
run"): **56/100**, 6 of 8 libraries. Valid full run (not a partial,
not model-failed). Full matrix and defects in `results.md`. Row
written there beside both unbudgeted comparison rows (blind 47.5/100,
guided 57/100).

Cleanup: removed the temporary pi entry
`gemma-4-26b-a4b-q4kxl-mtp2-tb8192`; `node tools/gen-pi-models.mjs
--check` passes again. Stopped the server and the watcher. No stray
`Mendel Daemon` process found. Wired memory recovered to about
2.2 GB, near the pre-run 2085 MB. Removed the worker worktree
(`../mendel-bench-guided-gemma-4-26b-a4b-q4kxl-mtp2-tb8192-high`) and
pruned; its branch and evidence under
`~/.local/share/mendel-benchmark/runs/` stay, per the Mendel cleanup
rule.

## `qwen38-q4km-blind-tb8192`, started 2026-09-23 ~03:03

Added temporary pi entry `qwen3.8-27b-q4km-tb8192` (copy of
`qwen3.8-27b-q4km`, `contextWindow 65536`). Server: alias
`qwen3.8-27b-q4km`, no drafter, `-c 73728`, f16 KV, port 8080,
`$FAST_FLAGS`, matching `docs/setups/kamaji/models.json`
`qwen38-gguf-medium`'s command (the entry that carries the `pi` block
for id `qwen3.8-27b-q4km`). Probe: `finish_reason: stop`, non-empty
answer (851 chars) — pass.

Window is exactly 65536, not under it, so `MENDEL_KEEP_RECENT_TOKENS`
stays unset (pi's default 20000, per `mendel.md`, "Compaction keep").

Launched `run-worker.sh qwen3.8-27b-q4km-tb8192 pi blind xhigh` with
`MENDEL_CONTEXT_WINDOW=65536 MENDEL_RESERVE_TOKENS=16384`. Worktree
`../mendel-bench-qwen3.8-27b-q4km-tb8192-xhigh`, branch
`qwen3.8-27b-q4km-tb8192-xhigh-issue-13`. `gh auth status` still valid
from earlier. `benchmarks/run-watch.sh` armed on
`~/.local/share/mendel-benchmark/runs/qwen3.8-27b-q4km-tb8192-xhigh-blind-events.jsonl`,
`RUNWATCH_SILENCE=2700`. This is the best row of the machine's
comparison (93/100, 8/8, 213.3 minutes, no budget), so a long run is
expected.

Finished 2026-09-23 10:28 UTC (about 4h18m). End reason `done — model
stopped, work complete`, a clean stop. Loop verdict `ok`, worst ratio
0.33 on thinking. 17 commits (15 non-chore), tree clean.
`count-tool-calls.mjs`: 249 tool calls, 227 assistant messages,
peak_context 72829 (pinned window 65536, `-c` 73728 covers it — the
peak briefly exceeded the pinned window before a compaction cycle).
`output_limit_hits`: two stray 1-token entries, neither at budget.
`turn_timeout`: none. Budget message grep in the server log: **0
fires**, same finding as the first row.

**Correction, 2026-09-23**: the server-log check is wrong (see the
first row's correction above). Re-counted from `…-events.jsonl` and
`…-session.jsonl`: 0 matches in either. Conclusion unchanged.

3 tooling nudges came from a hanging `mendel-pipeline` tap test
harness after tests already passed (idle 42 and 36 minutes each,
unrelated to the model or the budget) — not a loop, not slow
generation.

Scored by a subagent on `claude-opus-5`: **91/100**, all 8 libraries
removed but 2 stale references left in `mendel-requirify` (found by
the model, skipped as out of scope). Valid full run. Full matrix and
defects in `results.md`, beside the unbudgeted comparison row
(93/100, 8/8, 213.3 min).

Cleanup: removed the temporary pi entry `qwen3.8-27b-q4km-tb8192`;
`gen-pi-models.mjs --check` passes. Stopped the server and the
watcher. No stray `Mendel Daemon` process found. Wired memory
recovering (~1.85 GB). Removed the worker worktree
(`../mendel-bench-qwen3.8-27b-q4km-tb8192-xhigh`) and pruned; branch
and evidence under `~/.local/share/mendel-benchmark/runs/` stay.

## `gemma12-q4kxl-guided-high-tb8192`, started 2026-09-23 ~07:44

Added temporary pi entry `gemma-4-12b-q4kxl-tb8192` (copy of
`gemma-4-12b-q4kxl`, `contextWindow 262144`). Server: alias
`gemma-4-12b-q4kxl`, no drafter, `-c 262144`, f16 KV, port 8080,
`$FAST_FLAGS`, matching `docs/setups/kamaji/models.json`
`gemma12-gguf-f16`'s command (the entry that carries the `pi` block
for id `gemma-4-12b-q4kxl`). Probe: `finish_reason: stop`, non-empty
answer (6704 chars) — pass.

Level: **high** (thinking on), per the block's note — this row's
level on this machine is off, but no Mendel run at thinking off is
allowed (owner rule, 2026-09-14), so it uses its thinking-on level.
Comparison rows: the card's two guided rows at high both ended in
about 5 minutes on an answer-channel text loop (818 and 520 repeats),
0 commits; this machine's own thinking-off guided row ended on a loop
at 58. A thinking budget cannot cut an answer-channel loop, so this
row measures whether thinking high with the budget changes the loop
at all — a short run here (well under an hour) would match the loop
pattern, not a failure of setup.

Launched `run-worker.sh gemma-4-12b-q4kxl-tb8192 pi guided high` with
`MENDEL_CONTEXT_WINDOW=262144 MENDEL_RESERVE_TOKENS=16384` (no
`MENDEL_KEEP_RECENT_TOKENS`, window above 65536). Worktree
`../mendel-bench-guided-gemma-4-12b-q4kxl-tb8192-high`, branch
`gemma-4-12b-q4kxl-tb8192-high-guided-v3-issue-13`. `gh auth status`
still valid. `benchmarks/run-watch.sh` armed on
`~/.local/share/mendel-benchmark/runs/gemma-4-12b-q4kxl-tb8192-high-guided-events.jsonl`,
`RUNWATCH_SILENCE=2700`.

Finished 2026-09-23 12:29 UTC (1h51m). End reason `repetition_loop`
(the harness's own live-loop stop): 658 repeats of "Actually, I'll
just do the whole file content." on the **thinking channel**, window
ratio 0.03 — a new loop signature for this row, not the answer-channel
loop the card shows. Loop verdict `LOOP` (`<slug>-loop.txt`,
`<slug>-worker.json`). Per `mendel.md`, "Live loop stop": a valid
partial, not invalid, counts as an attempt. 1 commit (`uuid`), 16
files with uncommitted in-progress work (`xtend`, `urlsafe-base64`
code-complete; `rimraf`, `tmp` in progress). `count-tool-calls.mjs`:
92 tool calls, 93 assistant messages, peak_context 167401 (window
262144). `output_limit_hits`: none. `turn_timeout`: none. Budget
message grep: **0 fires** again (server log; wrong method, see
correction below).

Scored by a subagent on `claude-opus-5`: **47/100**, 1/8 libraries
committed (2 more done but uncommitted). Model's final message falsely
claimed all 8 done. Full matrix and defects in `results.md`.

**Correction, 2026-09-23** (coordinator; the server log never carries
the injected budget message, confirmed independently on `arrietty`,
same build). Re-counted from the pi-side files:
`…-events.jsonl` has 4 matches (one message serialized across
`message_update`/`message_end`/`turn_end`/`agent_end`, so one real
fire) and `…-session.jsonl` has 1 match, same turn. **The budget fired
once, on the run's final turn** — the same turn the live-loop detector
ended the run on. Reading the thinking content directly
(`…-session.jsonl` line 189, 29135 characters): the two-phrase cycle
is already repeated many times **before** the budget message is
appended at the very end (character 29084 of 29135). The budget did
not cause the loop — it was already running when the budget capped
the turn — and the budget's forced stop and the harness's own
repetition-loop alarm landed within 6 ms of each other on the same
finished turn (12:29:25.528Z budget, 12:29:25.534Z loop alarm), both
scanning the same content once it was done. See `results.md` for the
full note.

Cleanup: removed the temporary pi entry `gemma-4-12b-q4kxl-tb8192`;
`gen-pi-models.mjs --check` passes. Stopped the server and the
watcher. No stray `Mendel Daemon` process found. Wired memory
recovering (~1.85 GB). Removed the worker worktree
(`../mendel-bench-guided-gemma-4-12b-q4kxl-tb8192-high`, including its
uncommitted changes) and pruned; branch and evidence under
`~/.local/share/mendel-benchmark/runs/` stay.

## `qwen38-ista-f16-blind-tb8192`, started 2026-09-23 ~09:41

Added temporary pi entry `qwen3.8-27b-ista-f16-tb8192` (copy of
`qwen3.8-27b-ista-f16`, `contextWindow 147456`). Server: alias
`qwen3.8-27b-ista-f16`, no drafter, `-c 163840`, f16 KV, port 8080,
`$FAST_FLAGS`, matching `docs/setups/kamaji/models.json`
`qwen38-gguf-ista-nodrafter-xhigh`'s command. Probe: `finish_reason:
stop`, non-empty answer (763 chars) — pass.

Launched `run-worker.sh qwen3.8-27b-ista-f16-tb8192 pi blind xhigh`
with `MENDEL_CONTEXT_WINDOW=147456 MENDEL_RESERVE_TOKENS=16384` (no
`MENDEL_KEEP_RECENT_TOKENS`, window above 65536). Worktree
`../mendel-bench-qwen3.8-27b-ista-f16-tb8192-xhigh`, branch
`qwen3.8-27b-ista-f16-tb8192-xhigh-issue-13`. `gh auth status` still
valid. `benchmarks/run-watch.sh` armed on
`~/.local/share/mendel-benchmark/runs/qwen3.8-27b-ista-f16-tb8192-xhigh-blind-events.jsonl`,
`RUNWATCH_SILENCE=2700`. This is the 3-bit row: comparison 80.5/100,
8/8, 109.4 minutes, no budget. Its fast-mode EvalPlus forced the most
answers of the dense Qwen rows here, so it is the dense row most
likely to reach the budget on an agent turn — count fires from the
pi-side events/session files, not the server log (correction above).

Finished 2026-09-23 14:42 UTC (about 2h4m). End reason `done — model
stopped, work complete`, a clean stop. Loop verdict `ok`, worst ratio
0.27 on tool call. 17 commits (all chore), tree clean.
`count-tool-calls.mjs`: 214 tool calls, 175 assistant messages,
peak_context 119250 (window 147456). `output_limit_hits`: none.
`turn_timeout`: none. 1 tooling nudge (a 10-minute stall). Budget
message grep, pi-side files this time: **0 fires** in both
`events.jsonl` and `session.jsonl`. The longest thinking block in the
session was about 5445 characters (~1400 tokens), roughly 6800 tokens
below the 8192 budget — no turn came close.

Scored by a subagent on `claude-opus-5`: **87/100**, 8/8 libraries
(1 stale `rimraf` reference left in `mendel-requirify`, the same trap
the other two dense-model rows also missed or skipped). Valid full
run. Score rose 6.5 points over the unbudgeted comparison (80.5 to
87); since the budget never bound, this is run-to-run variance, not a
budget effect. Full matrix and defects in `results.md`.

Cleanup: removed the temporary pi entry `qwen3.8-27b-ista-f16-tb8192`;
`gen-pi-models.mjs --check` passes. Stopped the server and the
watcher. No stray `Mendel Daemon` process found. Wired memory
recovering (~1.86 GB). Removed the worker worktree
(`../mendel-bench-qwen3.8-27b-ista-f16-tb8192-xhigh`) and pruned;
branch and evidence stay.

## `qwen36-q4kxl-q8-mtp3-guided-tb8192`, started 2026-09-23 ~11:45

Added temporary pi entry `qwen3.6-35b-a3b-q4kxl-q8-mtp3-tb8192` (copy
of `qwen3.6-35b-a3b-q4kxl-q8-mtp3`, `contextWindow 81920`). Server:
alias `qwen3.6-35b-a3b-q4kxl-q8-mtp3`, MTP n=3, q8_0 KV, `-c 98304`,
port 8080, `$FAST_FLAGS`, matching `docs/setups/kamaji/models.json`
`qwen36-gguf-think`'s command. Probe: `finish_reason: stop`,
non-empty answer (8023 chars) — pass.

Launched `run-worker.sh qwen3.6-35b-a3b-q4kxl-q8-mtp3-tb8192 pi guided
high` with `MENDEL_CONTEXT_WINDOW=81920 MENDEL_RESERVE_TOKENS=16384`
(no `MENDEL_KEEP_RECENT_TOKENS`, per the block's own note, window
above 65536). Worktree
`../mendel-bench-guided-qwen3.6-35b-a3b-q4kxl-q8-mtp3-tb8192-high`,
branch `qwen3.6-35b-a3b-q4kxl-q8-mtp3-tb8192-high-guided-v3-issue-13`.
`gh auth status` still valid. `benchmarks/run-watch.sh` armed on
`~/.local/share/mendel-benchmark/runs/qwen3.6-35b-a3b-q4kxl-q8-mtp3-tb8192-high-guided-events.jsonl`,
`RUNWATCH_SILENCE=2700`. The MoE row: three prior guided runs at
46.5, 62.5, 83 (all 8/8, ~90 min), the widest variance on the
machine, so this run is a fourth sample, not a verdict. Budget-fire
counting uses the pi-side events/session files.

**Attempt 1 failed, invalid: harness/serving collapse.** The server's
Metal backend crashed with an unrecoverable GPU OOM 23 seconds into
the run's first real turn (task 2018, prompt 4340 tokens, well inside
the 98304 `-c` and the 81920 pinned window): `ggml_metal_synchronize:
error: command buffer 1 failed with status 5` / `error: Insufficient
Memory (00000008:kIOGPUCommandBufferCallbackErrorOutOfMemory)`. Every
request after that failed with "backend is in error state from a
previous command buffer failure" (10 in a row), and pi ended on
`tooling_budget_exhausted`, 0 commits. Per `mendel.md`, "Live loop
stop": zero commits from a serving collapse, not the model's own
failure, makes this **invalid**, never scored. Per the owner rule
(2026-09-13), "a row the machine killed is retried at once, in a
fresh worktree, before the next block starts": killed the dead server
(the Metal backend cannot recover in place) and the watcher, and
retried fresh below. The failed worktree and branch stay untouched
(never delete before scoring, even though there is nothing here to
score).

**Attempt 2, started 2026-09-23 ~15:00.** Restarted the server with
the same command. In progress.

This is the last block of run 30's row list.
