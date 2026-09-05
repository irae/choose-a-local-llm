# Gemma-4-12B — what the community already knows, and what to do

Run 2, 2026-09-04. **Owner decision, taken 2026-09-04.** The reasoning
and sources below are the proof behind it.

**The ruling: Gemma-4-12B on MLX or LM Studio is ruled out for
thinking-on agentic work, and no further item in this run chases that
combination.** GGUF Gemma-12B stays in scope.

## The two things I verified locally

**1. Patching the container is trivial, and I was wrong to call the MLX
arm impossible.** What is impossible is upstream `mlx_lm`, which has no
`gemma4_unified` implementation and refuses to load the model at all. But
an MLX container **is a directory**, and `chat_template.jinja` is a plain
text file in it. Copy the directory, replace that one file, point
LM Studio at the copy. No weights touched, nothing regenerated, no
maths. A GGUF would be harder — there the template sits in the binary's
metadata.

**2. Thinking off sidesteps the bug entirely, with no patch at all.** The
fix's branch is guarded by `and enable_thinking`. Rendering a
conversation that ends in a tool response:

| `enable_thinking` | pre-fix vs post-fix |
| --- | --- |
| false | **byte-identical**, `4b93421c48fc` |
| true | differ |

With thinking off the two templates are the same file as far as the
model is concerned.

## What the community established, which changes the conclusion

- **The loop reproduces at F16.** HF discussion 41 reports the
  full-precision release weights falling into the same thought attractor
  on long agent prompts. So this is a **model-level** behaviour, not only
  a template artifact and not a quantization one.
- **HF discussion 38** is exactly our case: the chat template re-injects
  prior-turn reasoning during multi-turn tool use, producing loops.
- **The known mitigation is partial.** `repeat-penalty 1.08` with
  `repeat-last-n 4096` is reported to reduce but not eliminate it. That
  agrees with what this run measured: DRY at a 2048 window did not stop
  the loop, it changed its shape.
- **LM Studio has a separate defect.** Bug 2013: Gemma-4's reasoning
  tokens default to `<think>` rather than `<|channel>thought`, so the
  reasoning parser must be overridden by hand every time.
- **No fixed MLX container was found.** mlx-community's Gemma-4 repos
  were updated in June 2026, before the 15 July template fix. That
  matches the pre-fix hash measured in our cache.

## The decision, and why

**Ruled out: Gemma-4-12B on MLX or LM Studio for thinking-on agentic
work. No further item chases that combination.**

Not because the template cannot be patched — it can, in one file — but
because the loop survives full precision. A patched template would
reduce the failure rather than cure it, and the cost is maintaining a
forked container plus a hand-set reasoning parser in LM Studio, for a
model with a known attractor.

If it is kept at all, keep it **thinking off**, which is free, needs no
patch, and makes the template question moot.

This frees the run's remaining time for the quant shortlist
(`quant-survey.md`) and the coding candidates
(`model-candidates.md`), which is where the daily-driver question is
actually decided.

## For the planner — every Gemma-12B Mendel row is MLX

Checked in `benchmarks/mendel/results*.csv`. All three Gemma-4-12B rows
ran on the `lmstudio` provider:

| Row | provider | backend |
| --- | --- | --- |
| `google-gemma-4-12b-high-guided-v3-issue-13` | lmstudio | lm-studio |
| `google-gemma-4-12b-low-guided-v3-issue-13` | lmstudio | lm-studio |
| `google-gemma-4-12b-high-issue-13` | lmstudio | lm-studio |
| `gemma-4-26b-a4b-issue-13` | llama | llama-server |

So **there is no scored GGUF Gemma-12B agent run at all**, and every
scored Gemma-12B agent number sits on the ruled-out combination.

**Request to the planner: queue a GGUF Gemma-12B Mendel run.** This run
is research and does not schedule scored benchmarks. The case for
queueing it is that the unscored replays here already show that path
working — the post-fix template arms ran 150 and 100 minutes without a
repetition loop, one of them committing three dependency removals with a
clean tree, where the LM Studio arm committed nothing. A scored row would
turn that into a comparable number and would give the model a fair
result on the backend that is not ruled out.

The vetted command is in
`docs/setups/m1-max-32gb/benchmarks/gemma-4-12b-it.md`, and the pi entry
`gemma-4-12b` on the `llama` provider already exists.

## What this does NOT change

The row verdicts in `row-verdicts.md` stand. The llama.cpp arms remain
the evidence that the pre-fix template makes the failure far more likely,
and the GGUF and EvalPlus rows remain keepers.

Sources: HF `google/gemma-4-12B-it` discussions 38 and 41;
`lmstudio-ai/lmstudio-bug-tracker` issue 2013; the mlx-community
Gemma-4 repository listing.
