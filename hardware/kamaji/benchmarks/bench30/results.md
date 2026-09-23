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
