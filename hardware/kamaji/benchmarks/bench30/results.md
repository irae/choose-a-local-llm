# Run 30 — results

One section per agent row of `AGENT.md`, the budgeted row beside its
comparison row, in the site comparison form of
`docs/methodology/status-lines.md`. No verdicts.

## `gemma26-q4kxl-mtp2-guided-tb8192`

pi id `gemma-4-26b-a4b-q4kxl-mtp2-tb8192`, guided v3.0, thinking high,
reasoning budget 8192. Scored by `claude-opus-5` in a subagent,
2026-09-23.

| Row | Score | Libraries | End reason | Wall | Tool calls | Peak ctx | Budget fires | `output_limit_hits` | `turn_timeout` | Loop verdict |
|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| Comparison: blind, no budget | 47.5/100 | 8/8 | complete | — | — | — | n/a | n/a | n/a | — |
| Comparison: guided, no budget | 57/100 | 7/8 | complete | — | — | — | n/a | n/a | n/a | — |
| **This run: guided, budget 8192** | **56/100** | **6/8** | done — model stopped, work complete | 3h10m | 278 | 212713 (window 212992) | **0** | 1 (1 token, not at budget, blocked thinking, 04:47:54Z) | none | ok, 0.23 worst ratio (tool call) |

Config note: reasoning budget 8192, message fixed ("Thinking budget
reached. Give the final answer now."), KV f16, `-c 212992`, window
212992, `maxTokens` 16384 (pi default), `reserveTokens` 16384, wired
25000.

**Correction, 2026-09-23** (owner via the coordinator): the budget
fire count is counted wrong below and in `state.md`'s first pass. The
server log never carries the injected message (confirmed on
`arrietty`, same build, 2026-09-23: the message lands only in
`reasoning_content` of the pi-side response, never in the server's own
log). Re-counted from
`~/.local/share/mendel-benchmark/runs/gemma-4-26b-a4b-q4kxl-mtp2-tb8192-high-guided-events.jsonl`
and `…-session.jsonl` (both files, `grep -c` on the fixed message):
**0 matches in either file**. The original conclusion stands, now on
the right evidence: the budget never fired on this row.

The budget never fired: no thinking turn reached 8192 reasoning
tokens, matching the run-22 finding on a different model. Score fell
2 points from the unbudgeted guided comparison row (57 to 56) and the
model completed one fewer library (7 to 6): `rimraf` was left
declared and required in `mendel-requirify`'s test files, and root
`tmp` stayed declared. The scorer could not confirm this drop traces
to the budget rather than to run-to-run variance — no budget turn
fired, so the budget cannot be the direct cause. Other defects: 4
stray probe files committed, heavy `git add .` use (11 times), about
15 commits redoing earlier work (1 model nudge), 24% of commands
truncated in the log.

## `qwen38-q4km-blind-tb8192`

pi id `qwen3.8-27b-q4km-tb8192`, blind v1.1, effort xhigh, reasoning
budget 8192. Scored by `claude-opus-5` in a subagent, 2026-09-23.

| Row | Score | Libraries | End reason | Wall | Tool calls | Peak ctx | Budget fires | `output_limit_hits` | `turn_timeout` | Loop verdict |
|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| Comparison: blind, no budget | 93/100 | 8/8 | complete | 213.3 min | — | 61572 | n/a | n/a | n/a | — |
| **This run: blind, budget 8192** | **91/100** | **8/8 removed, 2 stale refs left** | done — model stopped, work complete | 4h18m (258 min) | 249 | 72829 (pinned window 65536, `-c` 73728) | **0** | 2 (both 1 token, not at budget, blocked thinking, 07:01:58Z and 07:49:17Z) | none | ok, 0.33 worst ratio (thinking) |

Config note: reasoning budget 8192, message fixed ("Thinking budget
reached. Give the final answer now."), KV f16, `-c 73728`, pinned
window 65536, no drafter, `maxTokens` 16384 (pi default),
`reserveTokens` 16384, wired 25000.

**Correction, 2026-09-23**: re-counted from
`~/.local/share/mendel-benchmark/runs/qwen3.8-27b-q4km-tb8192-xhigh-blind-events.jsonl`
and `…-session.jsonl` (the server-log method used originally cannot
see the message at all — see the gemma26 row's correction above):
**0 matches in either file**. The original conclusion stands, now on
the right evidence.

The budget never fired here either: no thinking turn came near 8192
reasoning tokens. Score fell 2 points from the unbudgeted comparison
row (93 to 91), on the machine's best row so far. The model found but
skipped the `mendel-requirify` rimraf references (trap B), calling
them out of scope since that package is not a pnpm workspace member;
this is the main point loss (17/20 on task completion). 3 tooling
nudges came from a hanging `mendel-pipeline` tap test harness after
tests passed (idle 42 and 36 minutes, unrelated to the model or the
budget), not from a loop or a slow generation. Wall time is about 45
minutes longer than the comparison row, almost all of it these
harness hangs. Other notes: only 2 of 17 commits use the `chore` type,
peak context (72829) briefly exceeded the pinned window (65536) before
a compaction cycle, server `-c` (73728) covers it.

## `gemma12-q4kxl-guided-high-tb8192`

pi id `gemma-4-12b-q4kxl-tb8192`, guided v3.0, thinking high (the
row's thinking-on level; thinking off is not allowed on a Mendel run),
reasoning budget 8192. Scored by `claude-opus-5` in a subagent,
2026-09-23.

| Row | Score | Libraries | End reason | Wall | Tool calls | Peak ctx | Budget fires | `output_limit_hits` | `turn_timeout` | Loop verdict |
|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| Comparison: card, guided high (×2) | 0/100 | 0/8 | repetition_loop (answer channel, text) | ~5 min each | — | — | n/a | n/a | n/a | LOOP |
| Comparison: this machine, guided off | 58/100 | — | repetition_loop | — | — | — | n/a | n/a | n/a | LOOP |
| **This run: guided high, budget 8192** | **47/100** | **1/8 committed, 2 more done uncommitted** | repetition_loop (thinking channel, text cycle) | 1h51m | 92 | 167401 (window 262144) | **1** | none | none | LOOP, 0.03 ratio (thinking) |

Config note: reasoning budget 8192, message fixed ("Thinking budget
reached. Give the final answer now."), KV f16, `-c 262144`, window
262144, `maxTokens` 16384 (pi default), `reserveTokens` 16384, wired
25000.

**Correction, 2026-09-23** (owner via the coordinator): the budget
fire count above and this section's first pass both said 0, counted
from the server log, which never carries the injected message (see
the gemma26 row's correction). Re-counted from
`~/.local/share/mendel-benchmark/runs/gemma-4-12b-q4kxl-tb8192-high-guided-events.jsonl`
(4 matches, one message serialized across `message_update`,
`message_end`, `turn_end`, `agent_end` — one real fire) and
`…-session.jsonl` (1 match, same turn). **The budget fired once, on
this row's very last turn** — the same turn the harness's live-loop
detector ended the run on. Read directly from the thinking content
(`…-session.jsonl` line 189): the two-phrase cycle ("Actually, I'll
just do the whole file content." / "Wait, I'll check if I can do the
targeted edit.") is already running, repeated many times, in the
29135 characters of that turn's thinking **before** the budget
message appears, appended once at the very end (character 29084 of
29135). The loop was not caused by the budget: it was already
established when the budget capped the turn. The budget's only
visible effect here is that it ended the runaway thinking generation
at the point the reasoning-token cap hit, at the same moment the
harness's own repetition detector also fired on the same content —
the two stops landed 6 ms apart (12:29:25.528Z budget,
12:29:25.534Z loop alarm) because both were scanning the same
finished turn.

A new loop signature for this row: the card's two guided-high rows
loop in the answer channel within 5 minutes with 0 commits; this run
loops in the **thinking channel** after 1h51m of real work. Only 1 of
8 libraries is committed (`uuid`), but the worktree carries
uncommitted, in-progress work on 2 more (`xtend`, `urlsafe-base64`
both code-complete; `rimraf` and `tmp` in progress). The model's final
message falsely claimed all 8 were done — a completion claim not
backed by the diff. The rubric scores the committed branch only.

Other defects: root `rimraf` and `tmp` still declared (critical), no
full test suite or lint run in the whole session, 5 Prettier warnings
in uncommitted files from whole-file rewrites.

## `qwen38-ista-f16-blind-tb8192`

pi id `qwen3.8-27b-ista-f16-tb8192`, blind v1.1, effort xhigh,
reasoning budget 8192. Scored by `claude-opus-5` in a subagent,
2026-09-23. Budget fires counted from the pi-side `events.jsonl` and
`session.jsonl`, per the correction above.

| Row | Score | Libraries | End reason | Wall | Tool calls | Peak ctx | Budget fires | `output_limit_hits` | `turn_timeout` | Loop verdict |
|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| Comparison: blind, no budget | 80.5/100 | 8/8 | complete | 109.4 min | — | — | n/a | n/a | n/a | — |
| **This run: blind, budget 8192** | **87/100** | **8/8, 1 stale ref left** | done — model stopped, work complete | 2h4m (124 min) | 214 | 119250 (window 147456) | **0** | none | none | ok, 0.27 worst ratio (tool call) |

Config note: reasoning budget 8192, message fixed ("Thinking budget
reached. Give the final answer now."), KV f16, `-c 163840`, window
147456, no drafter, ISTA-DASLab GSQ-RCO 3-bit (IQ3_S-mtp), `maxTokens`
16384 (pi default), `reserveTokens` 16384, wired 25000.

The budget never fired: the longest thinking block in the session was
about 5445 characters (~1400 tokens), roughly 17% of the 8192 budget
and about 6800 tokens below it — no turn came close. Score rose 6.5
points over the unbudgeted comparison (80.5 to 87); since the budget
never bound, this is run-to-run variance, not a budget effect. This
model was flagged going in as "the dense row most likely to reach the
budget" from its fast-mode EvalPlus forcing behavior, but that did not
carry over to the agent task. All 4 known traps checked: trap A
(async-iterator glob) passed, trap B (`mendel-requirify` rimraf
references) missed — same trap the other two dense-model rows also
missed or skipped, trap C (tmp exit hook) hit as an unrequested
regression (deletes a debug manifest), chalk trap passed. All 17
commits use `chore`, no repair commits, full suite run 8 times.
