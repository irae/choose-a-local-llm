# Local coding models on RTX 5060 Ti 16 GB

Cross-model picks · llama-server (CUDA) · first run 2026-09-13 to 2026-09-15

## Highlights

- **The pick: Qwen3.8-27B, the ISTA 3-bit build, no drafter, q8_0
  KV.** The only build that finished the agent task: 85 guided and 91
  blind, both 8 of 8, on a 61440 window at 29.4 → 21.1 tok/s.
- **For speed at a long window: Qwen3.6-35B-A3B with its MTP drafter.**
  It serves 97K at 61 → 45 tok/s with part of the experts in host RAM,
  and scores 48.5 guided, 6 of 8.
- **NVFP4 fits and reads fast, and Gemma-4-12B still fails the task.**
  The NVFP4 build serves the trained 262K window at 49.6 → 33.1 tok/s;
  both Gemma-4-12B builds end the agent task with zero commits.
- **Leave VRAM for the desktop.** The desktop shares the card and holds
  about 1.2 GB; a served arm with about 440 MiB free crashed three
  times.
- **No EvalPlus on this machine yet** (owner, 2026-09-13).

## Models evaluated

<!-- gen:models-evaluated:start -->
| Model / Config | Ctx | Cap | tok/s | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" top /> | 65k | mem | <TokCell shallow="29.43" deep="21.13" /> | <ScoreCell value="pending" /> | <ScoreCell value="91" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" top /> | 65k | mem | <TokCell shallow="29.36" deep="20.92" /> | <ScoreCell value="pending" /> | <ScoreCell value="79" note="88%" pill="mendel-guided" top /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" /> | **97k** | mem | <TokCell shallow="61.16" deep="45.42" top-shallow top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" /> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" /> | **97k** | mem | <TokCell shallow="58.77" deep="45.59" top-shallow top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" /> | **261k** | mem | <TokCell shallow="49.55" deep="33.11" /> | <ScoreCell value="pending" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" /> | **261k** | mem | <TokCell shallow="49.55" deep="33.11" /> | <ScoreCell value="pending" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" /> | **261k** | mem | <TokCell shallow="47.39" deep="32.18" /> | <ScoreCell value="pending" /> | <ScoreCell value="not run" /> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" /> | **261k** | mem | <TokCell shallow="47.39" deep="32.18" /> | <ScoreCell value="pending" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> |

Fewer than two rows pass the filter of this table, so it shows every row it can hold.
<!-- gen:models-evaluated:end -->

#### Legend

- **Ctx**, the usable context: the deepest context the config served
  above the floor, set by Cap. The coding harness gets the same
  window, rounded down to a multiple of 4096.
- **Cap**, what stops the context from growing: memory holds the
  weights, the drafter and the runtime's buffers, and what is left is
  context. Some models do not fit their trained window; others fit it
  and then decode too slowly to use. The floor is 8 tok/s. `mem`
  means memory ended the curve, `speed` means decode fell under the
  floor while memory still had room.
- **tok/s**, decode speed shallow, near an empty context, then deep,
  at Ctx, read on real code text at the server's own sampling. A
  drafter row is read at more than one draft depth, with its
  acceptance.
- **EvalPlus**, scored once per model and thinking mode; runtimes
  serving the same model at a standard quant share the score. Each
  run gets an output budget from a ten-problem calibration, capped at
  30000 tokens. A problem that runs to the cap counts as failed; the
  completion percentage says how many finished.
- **Coding**, a simulated pull request: the `pi` coding agent fixes a
  real issue in a real repository with known traps, over many turns.
  Mendel blind gives the terse issue; Mendel guided gives the same
  task as steps with the traps disclosed. The pill names the test. Of
  the config's valid runs the cell shows the one with the most
  libraries done, then the higher score; a muted percentage before
  the score is the share of libraries done when the run did not
  finish. Rows sort by the average of the EvalPlus base score and
  this one.

Server commands live in each model's report; aliases equal the pi
model ids.

### Rows still being measured

Every row above has all three measurements: tok/s, EvalPlus and
Mendel. The rows below have at least one of the three and are missing
one or two. Rows with none of the three stay on their model page.
When fewer than two rows pass the filter of a table, that table shows
every row it can hold, and a note under it says so.

<!-- gen:models-evaluated-partial:start -->
| Model / Config | Ctx | Cap | tok/s | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|
<!-- gen:models-evaluated-partial:end -->

## Per-model reports

- [Gemma-4-12B-it](./reports/gemma-4-12b-it.md): the NVFP4 build that
  fits the card with its trained window, and the k-quant control
- [Qwen3.8-27B](./reports/qwen3.8-27b.md): the strongest base model,
  in the 3-bit build that leaves room for a KV cache
- [Qwen3.6-35B-A3B](./reports/qwen3.6-35b-a3b.md): MoE with the MTP
  drafter, NVFP4, part of the experts in host RAM
- [Gemma-4-26B-A4B](./reports/gemma-4-26b-a4b.md): MoE, NVFP4 with
  attention at Q8, part of the experts in host RAM

## Decode speed vs used context — the 8 tok/s usability floor

Pending: the curves land here when the first run closes. Every
reading comes from `llama-benchy` on real code text at two or three
depths, the shallow one and the row's deep one, as
[the measurement rules](../../methodology/context-creep.md) say.

## Code quality — EvalPlus HumanEval+

Pending: no EvalPlus score exists on this machine yet. The first run
skips the gate on the owner's word (2026-09-13) and its agent rows say
so.

## Mendel — agentic quality

Pending: the rows land on [the Mendel page](./benchmarks/mendel.md)
as the first run scores them.
