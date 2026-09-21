# Run 28 — report

Eleven blocks, 2026-09-20 to 2026-09-21. Every scored thinking row of
the RTX 5060 Ti 16 GB got an EvalPlus score in fast mode
(`docs/methodology/evalplus.md`, "Fast mode"): the server closes the
thinking at 8192 tokens, `max_tokens` is 16384, and there is no
calibration and no forced re-run. One rule for every row, so the rows
compare. The method page is
[the thinking budget](../../../../docs/methodology/reasoning-budget.md).

The run measured; it decided nothing. No serving config changed, no
model was chosen, and no agent row ran.

Six rows were spliced: where an earlier run of the same config left a
finish log, the block kept the answers that finished under 8192
thinking tokens and generated only the rest. Four rows were generated
in full. One planned row was cancelled when the owner retired its
model.

## Every row, before and after

"Before" is the score this row published under the earlier method.
Empty and forced are out of 164. Wall is active minutes.

| row | before | empty | wall | after | forced | wall |
|---|---|--:|--:|---|--:|--:|
| Gemma-4-12B NVFP4, thinking on | 0.659 / 0.640 | 53 | 204 | **0.976 / 0.951** | 44 | 211 |
| Gemma-4-12B UD-Q4_K_XL, thinking on | 0.793 / 0.780 | 34 | 259 | **0.988 / 0.963** | 34 | 198 |
| Gemma-4-26B-A4B NVFP4, thinking on | 0.909 / 0.878 | 14 | 215 | **0.988 / 0.951** | 19 | 154 |
| Qwen3.6-35B-A3B UD-Q4_K_XL, thinking on | 0.945 / 0.902 | 6 | 192 | **0.976 / 0.933** | 12 | 144 |
| Qwen3.8-27B UD-IQ3_S, effort xhigh | 0.957 / 0.921 | 3 | 290 | 0.963 / 0.921 | 8 | 188 |
| Bonsai-2-27B PTQ1_0, f16 KV | 0.970 / 0.939 | 0 | 196 | 0.976 / 0.945 | 12 | 125 |
| Bonsai-2-27B PQ2_0, f16 KV | 0.982 / 0.945 | 0 | 183 | 0.982 / 0.945 | 12 | 121 |
| Bonsai-2-27B PTQ1_0, q8_0 KV | 0.982 / 0.945 | 0 | 245 | 0.982 / 0.945 | 16 | 140 |
| Bonsai-2-27B PQ2_0, q8_0 KV | 0.982 / 0.939 | 0 | 176 | **0.988 / 0.945** | 12 | 119 |
| Bonsai-2-27B PTQ1_0 + refusal-ablation LoRA, f16 KV | 0.976 / 0.945 | 0 | 274 | 0.976 / 0.945 | 18 | 152 |

Every "after" row has zero empty answers.

## What the run found

**Four rows had been measuring the output budget, not the model.** The
four rows that ran without any thinking budget carried 3 to 53 empty
answers each. Every one of those answers came back under fast mode, and
the scores moved by 1 to 32 points of base pass@1. The Gemma-4-12B
NVFP4 row moved from 0.659 to 0.976. A score published without a
thinking budget on a model that reasons long is not a quality reading.

**Rows that already converged did not move.** The five ternary arms
moved from 0.970-0.982 to 0.976-0.988 base, which is one to two
problems. The budget took nothing from a model that stops on its own.

**No row went down.**

**The wall fell on nine rows of ten.** The spliced ternary rows fell 32
to 45 percent, because only 12 to 18 problems were generated again. The
rows that used to run out of output budget also fell, 215 to 154 and
259 to 198 minutes, because a forced answer is cheaper than a
generation that never ends. One row rose: Gemma-4-12B NVFP4 went from
204 to 211 minutes, where 44 forced answers each paid 8192 thinking
tokens before answering.

**The budget value is not critical.** Gemma-4-12B NVFP4 had scored
0.976 / 0.951 with 45 forced answers under a calibrated budget of 7350.
The 8192 run reads the same pair with 44 forced. Qwen3.8 ISTA reads
0.976 / 0.933 at both 8192 and 30000, in 175 against 273 minutes.

**The forced count is the reading that matters beside the score.** A
row can score 0.988 with 34 forced answers (Gemma-4-12B UD-Q4_K_XL) or
with 12 (Bonsai-2-27B PQ2_0 q8_0). Both scores are true. The forced
count says how much of the score the budget had to rescue.

## What the run changed outside its own numbers

- The abliterated Qwen3.8 build was retired by the owner during the
  run, and both its files were deleted, 29 GB. Its fast-mode block was
  cancelled. The record is
  [the retired page](../../../../docs/setups/arrietty/qwen38-obliterated-retired.md).
- `benchmarks/run-humaneval.sh` searched the whole result directory for
  the samples file, so it could hand the evaluator the finish log and
  stop. Two blocks were evaluated by hand before the fix; both were
  recomputed from the per-problem results and both matched.
- The serve command of the LoRA row downloaded its adapter from a
  Hugging Face path that does not exist. The adapter is on GitHub. The
  command now uses a cached clone, and a fresh clone reproduces the
  published sha256.

## Limits

No agent row has ever run under a thinking budget, on either machine.
This run says nothing about what a budget does to a tool-calling
session, where a budget that fires inside a tool call may do harm.

The run did not test a budget under 8192, and it tested one machine.
Both Gemma rows and the Qwen3.6 row keep a high forced count, so a
larger budget would rescue fewer answers, not more.
