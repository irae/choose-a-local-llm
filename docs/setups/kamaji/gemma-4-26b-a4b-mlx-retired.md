# Gemma-4-26B-A4B on MLX, retired on this machine

Retired 2026-09-12 (owner). The MLX build
`mlx-community/gemma-4-26b-a4b-it-4bit` on `mlx_lm.server` is no longer
a candidate here. Its measurements stay on
[the model page](./reports/gemma-4-26b-a4b.md), in italics and marked
💀, because they are real and they explain the decision. They are gone
from the [comparison page](./comparison.md) and from the home table.

## The agent smoke failed

The Mendel smoke ran at thinking high on a 65536 window at wired limit
25000. It ended after six tool calls with zero commits and a dirty
tree: the server truncated a tool call in the middle of generation, and
the harness could not parse it. The log shows no OOM and no server
death. A failed smoke means no full agent run, so this build has no
Mendel row.

## The same model finishes the task on another build

The GGUF UD-Q4_K_XL build of the same model on llama-server completes
the agent task: 47.5 blind at thinking high with all eight libraries,
and 57 guided with seven of eight. The quant is the difference, so this
build is not run again.

## Quality was already low

EvalPlus at thinking on reads 0.793 / 0.768, with 31 of 164 problems
empty (81 percent completion), every empty proven as the output budget
after a re-run: the same convergence failure in another form. The GGUF build at the same level reads 0.896 / 0.872.

## What it did give

Real-text speed, read 2026-09-12 with `llama-benchy`: 49.3 tok/s at 4K
and 23.4 at 64K. The earlier creep read the same server alternating
between 13 and 24 tok/s from 60K up. No agent run turned that speed
into finished work.
