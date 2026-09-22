# Run 22 — report

Fourteen blocks, 2026-09-16 to 2026-09-22, paused by the owner from
2026-09-17 to 2026-09-21. The run began as a test of the calibrated
thinking budget and finished as the machine's move to fast mode: the
owner changed the method on 2026-09-19, and every block from
`bonsai-fork-fast-think` on ran at a thinking budget of 8192 with an
output budget of 16384, no calibration and no forced re-run.

Six EvalPlus rows in fast mode, one agent row under the same budget.

## The fast table

"Before" is the score the row published under the earlier method:
a calibrated budget where the row had one, else no budget at all.
Empty and forced are out of 164. Wall is active minutes; a spliced row
carries its source's time for the answers it kept.

| row | before | empty | wall | after | forced | wall |
|---|---|--:|--:|---|--:|--:|
| Ternary-Bonsai-27B fork, Q2_g64, q4_0 KV + bias, thinking on | 0.927 / 0.890 | 4 | 595 | **0.951 / 0.915** | 4 | 551 |
| Qwen3.8-27B Q4_K_M, f16 KV, effort xhigh | 0.982 / 0.951 | 0 | 448 | 0.982 / 0.951 | 9 | 304 |
| Gemma-4-26B-A4B UD-Q4_K_XL, MTP, thinking on | 0.988 / 0.957 | 0 | 166 | 0.988 / 0.957 | 19 | 117 |
| Ternary-Bonsai-2-27B PTQ1_0, f16 KV, effort xhigh | 0.988 / 0.939 | 0 | 337 | 0.988 / 0.939 | 10 | 289 |
| Qwen3.8-27B UD-IQ3_S (unsloth), effort xhigh | 0.945 / 0.927 | 8 | 816 | **0.976 / 0.945** | 17 | 389 |
| Qwen3.8-27B IQ3_S (ISTA), no drafter, effort xhigh | 0.945 / 0.921 | 5 | 583 | **0.976 / 0.945** | 13 | 332 |
| Qwen3.6-35B-A3B MTP, q8_0 KV, thinking on | 0.957 / 0.939 | — | — | **0.976 / 0.939** | 17 | 147 |

Every row after fast mode has zero empty answers.

**The pattern of the card repeats here.** A row that had a calibrated
budget did not move: three rows read exactly the same pair as before.
A row that had no budget, or a budget too small to stop the loops, went
up: the two 3-bit Qwen3.8 builds each gained 3.1 points of base and 1.8
to 2.4 of plus, and each lost every empty answer. The Qwen3.6 row
gained one problem.

**The wall fell on every row that ran again in full**, by 27 to 52
percent: 816 to 389 minutes on the unsloth build, 583 to 332 on the
ISTA build. The spliced rows fell further still, because only 10 to 19
problems were generated.

**Three rows share a score** under the shared-score rule and carry the
cell without running: the second slot arm of the fork, the 2x arm of
the Gemma MoE, and the two f16 arms of the Qwen3.6 MoE.

The effort-medium and effort-low rows of the dense 27B keep their
earlier scores and their marker, on the owner's word of 2026-09-19.

## The first agent row under a thinking budget

`simulator(mendel-guided)`, prompt guided-v3.0, level high, on the
fork at Q2_g64. The result that matters is not the score:

**The budget never fired.** Zero of 369 session lines carry the budget
message, so no turn of the run reached 8192 thinking tokens. A guided
agent task at thinking high does not think as long as one hard
HumanEval+ problem does.

Two things follow. A thinking budget is free on the agent side, and it
is also useless there at this value. And the run is serving-identical
to the no-budget row, so the score difference between them — 44.5
against 31.5, 5 of 8 libraries against 1 of 8 — is **run-to-run
variance on one sample per cell, not an effect of the budget**. It must
not be published as one.

The worst defect stayed critical in both runs. The budgeted run did
more of the task and carried new critical bugs the shorter run never
reached: a `chalk` shim built on `util.styleText` that returns an empty
style set, so every call throws, and a hand-written `glob` replacement
that always returns an empty list and drops every ignore rule.

## What the run caught on its own

- The Mendel worker builds its branch name from the model id, so a
  second run of the same model and level collides with the first. The
  run used a temporary pi id for the budgeted row instead of touching
  the published branch, and removed the entry afterwards.
- `hf download` returned an empty path once and the server came up with
  no model in the wrong mode. The runner killed it before any request
  and retried with the direct cache path, so no reading is affected.

## Limits

The agent row is one sample against one sample. Nothing here says the
budget helps or harms an agent task; it says the budget was never
reached. A level above high, or a task with longer reasoning per turn,
would be a different test.
