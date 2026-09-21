# Qwen3.8-27B OBLITERATED, retired on this machine

Retired 2026-09-20 (owner). The abliterated repack
`OBLITERATUS/Qwen3.8-27B-OBLITERATED`, revision `a58c3b5`, is no longer
a candidate here. Both its files, Q3_K_M and Q4_K_M, are deleted from
the machine, 29 GB in all, and the fast-mode EvalPlus block planned for
it in run 28 is cancelled.

Its measurements stay on this page because they are real and they
explain the decision. They are gone from the
[comparison page](./comparison.md), from the
[model report](./reports/qwen3.8-27b.md) tables and from the home
table.

## The build cannot do the agent task

The Q3_K_M smoke ended with zero tool calls in 9 seconds. The file's
own chat template carries no `tools` and no `tool_call` handling, so
`--jinja` has nothing to parse and the model writes its calls as
literal text. A thinking block was present in the session log, so the
level reached the server: the fault is the file, not the harness and
not the window. A tools-capable template supplied to the server would
be a different serving config and a different row. A failed smoke means
no agent run, so this build never had a Mendel row.

## Quality was the lowest on the card

EvalPlus at effort medium, an owner overrule of 2026-09-17 — `AGENTS.md`
bans medium for this model everywhere else — scored 2026-09-18 under a
server thinking budget of 3986 (answer budget 2048, `max_tokens` 6034):

| | base | plus | completion | empty | forced | wall |
|---|--:|--:|--|--|--|--:|
| Q3_K_M, q8_0 KV, effort medium | 0.854 | 0.787 | 164/164 | 3/164 | 5/164 | 89 min |

Three answers came back empty and the cause is the model. Five problems
hit the budget and were forced to answer; one of those passed. The four
that failed fail again without the budget at the 30000-token cap, as
wrong answers and not as loops, so the budget lost nothing. Medium
reasons far shorter than xhigh on this model, which is why the budget
is 3986 against 25209 on a ternary build at xhigh. Build and level
moved together, so neither alone explains the distance to the 3-bit
builds of the same model at xhigh, which read 0.957 and 0.976 base. The
xhigh row this note once called pending was never run, and the
fast-mode re-score of 2026-09-20 was cancelled with the retirement.

## The larger file never reached the usability floor

The Q4_K_M file is 15.66 GiB of weights, larger than the card. It ran
as the one row on this machine that keeps part of a model in host RAM
by design: `-ngl 45` of 64 layers, 19 in host RAM, at `-c 65536` under
a VRAM cap of 13811 MiB that leaves 2.5 GB for the system (owner,
2026-09-18).

| depth | 4K | 24K | 49K | 64512 |
|---|--:|--:|--:|--:|
| tok/s | 5.13 | 3.49 | 2.67 | 2.31 |

The floor is 8 tok/s, so no depth reaches it. Against the same model's
Q3_K_M inside the card that is about 4.4 times slower at both ends.
Memory was never the limit: VRAM held flat at 13422 MiB against the cap
through the whole sweep, so the cost is the transfer of 19 layers per
token, not capacity. Halving the window to 32768 frees 1088 MiB of
cache, about four more layers at the ladder's own 226 MiB per layer,
which still does not reach the floor. The run ended at the sweep on its
speed gate (coordinator, 2026-09-18), so this file has no EvalPlus row
and no agent row.

## What it did give

The Q3_K_M row kept the window that the two 3-bit builds of this model
keep: q8_0 serves `-c 65536`, where f16 stops at 32768. Its speed read
22.67 tok/s at 4K, 20.65 at 24K and 16.74 at 64512, about 23 percent
under the 3-bit builds at both ends, with no depth under the floor. No
run turned that speed into finished work, because the template denies
the build every tool call.
