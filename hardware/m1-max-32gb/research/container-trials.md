# Container trials: better builds of models we already run

Status: draft, owner criteria of 2026-09-04. Needs hardware: yes, for
the three quick checks per candidate; the survey needs none.

## What this is for, the owner's criteria

Not doing:

- Adding models to make the benchmark bigger.
- Trying older models that already score below the current set.

Doing:

1. **Same weights, better container.** A published quant of a model
   we already benchmark, made with a method that claims more quality
   per byte on Apple Silicon (mixed-precision OptiQ, QAT builds,
   unsloth dynamic UD quants).
2. **Lower quant, larger context, most of the intelligence kept.** A
   3-bit or 2-bit build of a model we already benchmark, when it buys
   context we cannot reach at 4-bit.
3. **A smaller model that credible reports say matches a larger one
   we run** (the Bonsai case: a compressed 27B built from a model we
   already score).

## Entry criteria, written so a runner can apply them

Research runs no full EvalPlus and no scored Mendel. Those are bench
runs, and this project scores its own quantized files there. Research
tries candidates and reports whether they look better; the evidence it
uses is what the community already has (user impressions, "this is my
daily driver on a 32 GB machine" reports, a quant publisher's own proof
that their build of the same model at the same size is done better)
plus the three quick checks below.

A candidate container enters a trial only if ALL hold:

- It is a claimed improvement on something we already run, of one of
  the three shapes above. A new model in the same size class enters
  only when reports place it at or above our best in that class, and
  its llama.cpp or MLX support is merged, not announced.
- Weights at the chosen quant leave at least 32K of KV inside the
  wired limit of the machine file at the model's KV cost (run 9 for
  llama-server; the measured ceiling for MLX).
- The HF revision is pinned at download time and added to
  `run2/results/model-pins.md`.
- K-quants only on llama-server; IQ quants are reported 3.5x slower on
  Apple GPUs, so a decode check comes before any IQ trial.

The three quick checks, in this order, always against the config we
run today for that model or class:

1. **Context sweep**, one or two configs (GGUF and MLX where both
   exist), with the creep runner. The ceiling and the curve decide
   whether the container is worth the next two checks.
2. **Mendel smoke**, `benchmarks/mendel-smoke.sh`, against the same
   smoke on the config we run today.
3. **EvalPlus smoke**, `benchmarks/evalplus-smoke.py`, same budget on
   both sides, against the current config.

A trial is a KEEP when the sweep is not worse, and the two smokes are
level or better. A keep becomes a bench item (full EvalPlus, then a
scored Mendel row); research never publishes a number.

## The survey, then the trials

The survey needs no hardware, so it is planning: list candidates of
the three shapes for Qwen3.6-35B-A3B, Qwen3.8-27B and Gemma-26B-A4B,
with size, revision, the claim and its proof; compute the context each
buys from run 9's KV cost per token; shortlist at most three. Run 2's
survey covered OptiQ only and found it bigger than our 4-bit builds
(`run2/results/quant-survey.md`).

The run then executes the approved trials: download at a pinned
revision (a planning decision written into the runbook), the three
quick checks, the keep verdict with the numbers beside it. Judgment is
in reading a borderline result and in stopping a trial early when the
sweep already says no.

## Waits on

- `backlog/devstral-download.md`: the first coding-model candidate.
- Not in scope, owner rulings: LM Studio engine template probes,
  Gemma-4 MLX container patches, more sampler arms, OptiQ Gemma-12B,
  re-quantization of any kind, Laguna XS until llama.cpp support is
  merged, parallel contexts, an energy meter.
