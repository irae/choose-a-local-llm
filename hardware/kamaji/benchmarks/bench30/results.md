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
