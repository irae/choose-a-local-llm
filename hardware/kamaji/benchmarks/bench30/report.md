# Run 30 — report

Five agent rows on the Mac, 2026-09-22 to 2026-09-23, about 11 hours.
One question: does the fast-mode thinking budget of 8192 change an
agent row? Run 22 asked it once, on one row, and the budget never
fired. This run asked it on five rows, across three models, a MoE and
a dense build, blind and guided prompts.

## The answer

**The budget fired once in the whole run, and that one fire changed
nothing.** Four rows completed and none of them reached 8192 reasoning
tokens in any turn. The fifth fire came on a row that was already in a
repetition loop, and it capped the loop's own turn.

| row | prompt, level | score | comparison | budget fires |
|---|---|--:|--:|--:|
| Gemma-4-26B-A4B Q4_K_XL, MTP n=2 | guided, high | 56 | 57 guided, 47.5 blind | 0 |
| Qwen3.8-27B Q4_K_M, no drafter | blind, xhigh | 91 | 93 | 0 |
| Gemma-4-12B Q4_K_XL | guided, high | 47 (partial) | 0 and 0 on the card, 58 here | 1 |
| Qwen3.8-27B IQ3_S (ISTA), f16 KV | blind, xhigh | 87 | 80.5 | 0 |
| Qwen3.6-35B-A3B Q4_K_XL, MTP n=3 | guided, high | unmeasured | 46.5 / 62.5 / 83 | — |
| Qwen3.6-35B-A3B Q4_K_XL, no drafter | guided, high | 79 | not comparable | 0 |

The scores move both ways against their comparison rows: two down by
1 and 2 points, one up by 6.5. **No movement here is a budget
effect**, because no row in the table reached the budget. They are
run-to-run variance on one sample per cell.

The longest thinking block measured in the run was about 1400 tokens,
on the row that was expected to think longest. That is 17 percent of
the budget.

## What the budget did do, once

The Gemma-4-12B row looped and the budget fired on the loop's turn.
The session log settles the order: the two-phrase cycle repeats many
times inside the 29135 characters of that turn's thinking, and the
budget message is appended once at character 29084, at the very end.
The budget capped a turn that was already degenerate. It did not cause
the loop, and it did not save the row.

That row also carries a **new loop signature for this project**: a
repetition loop in the thinking channel, after 1h51m of real work,
against the card's answer-channel loops that arrive in five minutes
with nothing committed. The model then claimed all eight libraries
were done, which the diff does not support.

## The row that could not be served

The MoE row at MTP n=3 crashed twice in the speculative-decode path,
inside the first real agent turn, on a serving command that this same
file passed in September. The two failures do not even agree:
`Insufficient Memory` first, `failed to process speculative batch`
second. A plain completion probe passed both times; only an agent turn
brings it down.

The one change against the validated command is `--reasoning-budget`,
and the one change against the validated machine is the server build:
10621 then, 10964 now, about 340 builds apart. Rather than a third
blind retry, the run served the same row with the drafter removed and
nothing else changed. It completed clean at 79/100, which names the
drafter as the trigger and leaves the cause open.

**The MTP row stays unmeasured.** The 79 is a different serving
config and does not replace it. A reader who wants that number needs a
re-run against a build known to serve this file, or an upstream fix.

## Method defect, found and corrected inside the run

The first three rows counted budget fires by grepping the server log.
The server never logs the injection: it appends the message to
`reasoning_content` in the answer and writes nothing. The coordinator
proved this on the other machine with a deliberate 64-token budget —
the message arrives in the response, `grep -ic budget` on the whole
server log gives 0.

All three rows were re-counted from the pi-side `events.jsonl` and
`session.jsonl`. Two conclusions held. One changed: the Gemma-4-12B
row had fired once, and the wrong method had hidden it. Every later
row used the pi-side count.

## Limits

One sample per cell. A score difference of a few points between two
single agent runs carries no signal, and this run's own comparison
column shows the same configuration scoring 46.5, 62.5 and 83 on three
attempts. The finding that stands is the negative one, and it is
robust because it does not rest on scores: across three models and
both prompt shapes, an agent turn at thinking high does not reach 8192
reasoning tokens.
