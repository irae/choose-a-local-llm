# S5-nano BF16 (Maritaca AI)

File: [maritaca-ai/S5-nano-GGUF](https://huggingface.co/maritaca-ai/S5-nano-GGUF),
`S5-nano-BF16.gguf`, revision `5fd041274829d60aeeba1e2edc4aabb621a432e4`,
8,665,620,032 bytes. Server: official llama-server b12110 on CUDA.

- The quality evaluation used BF16 weights, f16 KV and high Think.
- The allocation was 65,536 tokens, with no MTP or vision.
- No full agent task was run.

## Configuration rows

The quality result below is separate from the Q8_0 serving row. No
64K depth curve or daily serving preset was selected for this file.

<!-- gen:binary-rows:start -->
No configuration row.
<!-- gen:binary-rows:end -->

## Quality

BF16 weights with f16 KV scored 138 base passes and 127 plus passes
out of 164, or 0.841 / 0.774. No answer was empty; 31 answers were
forced at the 8,192-token thinking budget. Output budget was 16,384,
temperature was 0, and the serving allocation was 65,536. Both weights
and KV differ from the Q8_0/q8_0 baseline, so the score difference does
not isolate either change. The full agent task remains unmeasured.

Active time was 221.2–222.1 minutes across three parts. Two T3
interruptions preserved completed samples. The table uses the upper
bound, 222.1 minutes; interruption gaps do not count. No 64K decode
curve was measured, so the quality table leaves speed blank for this
configuration. The separate depth curve used a 204,800-token allocation.

<!-- gen:binary-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="S5-nano" quant="BF16" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/s5-nano-maritaca-bf16" />](../setups/arrietty/benchmarks/s5-nano.md) | 8192 | 16384 | <ScoreCell value="0.841/0.774" sub="100% completion" top /> | none | 31/164 | — | 3h42 |
<!-- gen:binary-evalplus:end -->

## Agent task

<!-- gen:binary-mendel:start -->
No Mendel run yet.
<!-- gen:binary-mendel:end -->

## Speed and context

The separate allocation trial reached 204,800, with clean used depth
203,776 at 26.41 tok/s. It used f16 KV and reached 15,870 MiB total
GPU use. These are not measurements at the quality run's 64K allocation.
See the [measurement record](../setups/arrietty/benchmarks/s5-nano.md#bf16-weights-with-f16-kv).

## Log

- 2026-11-09: verified the pinned file, measured depth and completed full thinking-on quality at 64K.
