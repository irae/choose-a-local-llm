# Local coding models on RTX 5060 Ti 16 GB

Cross-model picks · llama-server (CUDA) · first run started 2026-09-13

## Highlights

- **No pick yet.** Every row below is pending its first measurement.
  The picks land here when the first run closes.
- **The question this setup answers:** which builds serve on 16 GB of
  VRAM with a window the agent task can use, at what speed on real
  text, and whether NVFP4 pays on a card that runs it natively.

## Models evaluated

<!-- gen:models-evaluated:start -->
| Model / Config | Ctx | Cap | tok/s | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|
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
