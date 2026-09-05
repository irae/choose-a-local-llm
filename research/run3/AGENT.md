# Research run 3 — DRAFT, not started, not committed

Coordinator draft, 2026-09-04, revised twice after the owner's
criteria. The measurements that need no more thinking moved to
`benchmarks/bench9/`. This run keeps one goal: try candidate containers
and say whether they look better, with three quick checks and no
published numbers. Gemma-12B is closed: run 2 finishes its bench work.

## What this run is for — the owner's criteria

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
  these shapes: the same model at the same quant size but a better
  container (a fixed chat template, a quant done with a better method,
  proof shown); a lower quant of the same model that buys context; or a
  smaller model that credible reports say matches a larger one we run
  (the Bonsai case). A new model in the same size class enters only
  when reports place it at or above our best in that class, and its
  llama.cpp or MLX support is merged, not announced.
- Weights at the chosen quant leave at least 32K of KV inside the
  24000 MB wired limit at the model's KV cost (bench 9 for llama-server;
  measured ceiling for MLX).
- The HF revision is pinned at download time and added to
  `research/run2/results/model-pins.md`.
- K-quants only on llama-server; IQ quants are reported 3.5x slower on
  Apple GPUs, so a decode check comes before any IQ trial.

The three quick checks, in this order, always against the config we
run today for that model or class:

1. **Context sweep**, one or two configs (GGUF and MLX where both
   exist), with the creep runner. The ceiling and the curve decide
   whether the container is worth the next two checks.
2. **Mendel smoke**: one handed task, wall-capped, unscored, using run
   2's replay kit (`research/run2/results/replay-llama.sh` and the
   counters beside it). Compared against the same smoke on the config
   we run today.
3. **EvalPlus smoke**: the fixed subset defined in
   `backlog/evalplus-smoke-subset.md` (a few fast problems plus one
   that often goes empty or scores low), same budget on both sides,
   compared against the current config.

A trial is a KEEP when the sweep is not worse, and the two smokes are
level or better. A keep becomes a bench item (full EvalPlus, then a
scored Mendel row); research never publishes a number.

## Goal 1 — the container trials

The survey behind this goal needs no hardware, so it is planning: the
coordinator lists candidates of the three shapes above for
Qwen3.6-35B-A3B, Qwen3.8-27B and Gemma-26B-A4B, with size, revision,
the claim and its proof, computes the context each buys from bench 9's
KV cost per token, and shortlists at most three. Run 2's survey
covered OptiQ only and found it bigger than our 4-bit builds
(`../run2/results/quant-survey.md`).

This run executes the approved trials: download at a pinned revision,
then the three quick checks, then the keep verdict with the numbers
beside it. Judgment is in reading a borderline result and in stopping
a trial early when the sweep already says no.

## Goal 2 — Qwen3.8-27B: find a configuration that finishes agent work

The best single-turn score on this hardware has never completed a
Mendel run (five attempts, four partial, one invalid; the report page
opens with it). Run 9 gave its llama row f16 KV and 49K. Before the
model retires from the daily-driver question, this run tries, in
order, and stops at the first that yields a completed Mendel smoke:

1. **Vision off.** A video on this model
   (https://www.youtube.com/watch?v=0xUxO_9zqTU, diagrams only, read
   the transcript) says dropping the vision tower frees memory. Our
   llama command already passes `--no-mmproj`; check whether the MLX
   container and LM Studio still load the tower, and what the GGUF
   saves with and without it at the same `-c`.
2. **Alternative quants, GGUF first.** GGUF takes every flag we use
   (KV type, drafter, slots, no vision); MLX takes none of them. List
   community GGUF builds of this model at 3-bit and at other 4-bit
   recipes, with their proof, and compute the context each buys from
   run 9's KV cost per token. A 3-bit build that reaches 96K at 12
   tok/s beats a 4-bit build at 49K for agent work.
3. **The OOM-at-load threshold.** A GGUF served right should die at
   speed, not at load: run 9 found every published `-c` OOMs at load
   under the 24000 limit, and the fit prediction's margin in the
   machine file did not predict it. Find the llama-server settings
   that make an oversized `-c` fail its fit check instead of loading
   and then failing (the memory fitting that `-ngl 999` bypasses,
   `--no-kv-offload`, unified KV), and re-derive the margin from run
   9's wired readings so the KV pick's prediction matches what loads.

Each candidate goes through the Mendel smoke on the llama row; a pass
becomes a bench item. Research publishes no number.

## Not in this run

- LM Studio engine template probe, Gemma-4 MLX container patches, more
  sampler arms, OptiQ Gemma-12B: all on the path the owner ruled out.
- Re-quantization of any kind. Owner ruling.
- Laguna XS until llama.cpp support is merged.
- Parallel contexts. The rule stands: pi almost never decodes two
  contexts at once, so the method measures sequential and round-robin
  use only (`N_CONTEXTS` on the creep runner). Nothing to research.
- An energy meter. It improves neither quality nor speed and needs
  sudo. Dropped.
- The worker-profile table: no hardware needed, so it is a `backlog/`
  item, not research.
- The container survey: planning, done by the coordinator after bench
  9 reports.

## Open owner decisions (also in HANDOFF.md)

- Bonsai: which corpus produced the scored KV bias file.
- Devstral Small 2 download (about 14 GB at Q4).
- The EvalPlus smoke subset (`backlog/evalplus-smoke-subset.md`) must
  exist before the first trial.
- `peak_context` caveat, `tool_calls` gap (parked since run 2).
