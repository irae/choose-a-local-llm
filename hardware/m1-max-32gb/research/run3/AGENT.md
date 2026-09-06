# Research run 3 — DRAFT, not started, not committed

Coordinator draft, 2026-09-04, revised twice after the owner's
criteria. The measurements that need no more thinking moved to
`hardware/m1-max-32gb/benchmarks/bench9/`. This run keeps one goal: try candidate containers
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
  `hardware/m1-max-32gb/research/run2/results/model-pins.md`.
- K-quants only on llama-server; IQ quants are reported 3.5x slower on
  Apple GPUs, so a decode check comes before any IQ trial.

The three quick checks, in this order, always against the config we
run today for that model or class:

1. **Context sweep**, one or two configs (GGUF and MLX where both
   exist), with the creep runner. The ceiling and the curve decide
   whether the container is worth the next two checks.
2. **Mendel smoke**: one handed task, wall-capped, unscored, using run
   2's replay kit (`hardware/m1-max-32gb/research/run2/results/replay-llama.sh` and the
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

## Goal 3 — a config that reaches Mendel never runs out of memory

Owner rule to establish (2026-09-05): when a config gets to a Mendel
run, its window and budget values are safe, so the run cannot end in
a Metal OOM. Today the values come from a creep ceiling and a rule
for `maxTokens`; nothing tests the in-turn growth that killed runs.
This goal derives the margin from the incidents below, tests it, and
writes the rule. Everything a planner needs is here or in the files
named; the executor on the Mac should not have to search for data.

### Every memory incident in an agent run, from the committed records

All on `mlx_lm.server`. No llama-server agent run has an OOM in any
evidence file (`grep` over the whole evidence tree finds the signature
only in creep server logs); llama's risk sits at load and at the first
real request, below.

| when | run and row | declared window / maxTokens | what happened | source |
| --- | --- | --- | --- | --- |
| 2026-09-02 | run 7, Qwen3.8 MLX blind low | 26624 / 16384 | eleven 1-token `length` stops at context 23566 to 23676 with prompts of about 20.3K: prompt plus budget did not fit the window; `tooling_budget_exhausted` at 88 percent. Not an OOM, the window arithmetic. | `../../../../../mendel-benchmark/benchmark/runs/mlx-community-Qwen3.8-27B-4bit-low-issue-13-session.jsonl`, `run2/results/config-proposals.md` P1 |
| 2026-09-02 | run 7, Qwen3.8 MLX guided low v3 (invalid) | 26624 / 16384 | the context grew to 27421, 29062, 30333, 29640 and 30092 tokens, past the declared window, with 1-token stops between; then three generation-thread deaths (timeouts, "terminated", connection error). Peak 30333. | `.../runs/mlx-community-Qwen3.8-27B-4bit-low-guided-v3-issue-13-session.jsonl`; row in `benchmark/results-guided.json` |
| 2026-09-05 | run 9 block E, Qwen3.8 MLX guided low, three attempts (invalid) | 26624 / 8192 | eight 1-token stalls recovered by nudges; two Metal OOM crashes of the generation thread at prompts of 22892 and 27969 tokens, the second past the window, `/health` still 200. | `../../benchmarks/bench9/results.md`, block E |
| 2026-09-04 | research run 2, Qwen3.8 MLX ceiling probe | no window, raw creep | the server thread died on the prompt-cache eval between 26708 and 28672 tokens at wired limit 24000; the last served row is 26708 at 15.4 tok/s. | `inputs/qwen38-mlx-ceiling-sweep.log`, `inputs/qwen38-mlx-ceiling-server-tail.log` (copied from the Mac evidence `run2-qwen38-ceiling/`) |
| 2026-08-30 to 09-02 | Bonsai MLX, four scored rows | 57344 / 16384 | peaks 45850 to 51723, 80 to 89 percent of the window, no crash. The closest healthy runs to a ceiling. | `benchmark/results.csv`, `results-guided.csv`, `peak_context` |

llama-server, for contrast: Qwen3.6 GGUF rows peaked at 94448, 96
percent of the 98304 window then declared, with no crash; Gemma-12B
llama thinking off peaked at 125135 of 262144. llama preallocates the
KV from `-c`, so a run inside `-c` does not grow into the machine.
Its two failures are at load and at the first real request: run 9
found every published `-c` OOMs at load under the 24000 limit
(`../../benchmarks/bench9/results.md`, block A1b), and run 10 found a
`-c` that loads and answers a trivial warmup can still fail on compute
buffers at the first 4096-token completion
(`../../benchmarks/bench10/results.md`, blocks A1 and A2). One
consequence already on the site: the Qwen3.6 daily-driver Mendel rows
ran at a window the machine no longer loads; the entry now says 49152.

### What the numbers say

- pi compacts between turns, when `contextTokens > contextWindow -
  reserveTokens` (pi docs, `compaction.md`). It never compacts inside a
  turn. A turn grows by the model's output up to `maxTokens` and by
  every tool result appended before the next turn. The run 7 v3 peak
  of 30333 against a 26624 window is 3.7K of in-turn growth past the
  declared window, before the budget cut of run 9.
- The MLX ceiling for this model is 26708 to 28672 at the 24000 limit,
  and the declared window sat 84 tokens under the last served depth.
  Any in-turn growth past the window lands in the dead band. So the
  window must sit below the ceiling by at least the in-turn growth.
- Current entries after the 2026-09-05 edits: `reserveTokens` 8192
  for every model, `maxTokens` 8192 (6656 on Qwen3.8 MLX). The pi
  settings and every entry's `contextWindow` are listed in
  `~/.pi/agent/models.json` and `settings.json` on the Mac; the values
  as of 2026-09-05 are in `HANDOFF.md` on the coordinator's box and in
  the Mendel `PLAN.md` maxTokens section.
- pi's own count and the server's count differ by the chat template
  and the tool definitions. llama-server reports `prompt_n` in its
  timings; a comparison of pi `usage.totalTokens` with `prompt_n` for
  the same turn sizes that overhead. mlx_lm.server reports nothing.

### What to research before the Mac (online, no hardware)

1. `mlx_lm.server` flags that bound memory instead of dying:
   `--max-kv-size` (rotating KV in `mlx_lm.generate`), whether the
   server honours a maximum prompt length, and what it does when a
   request exceeds it (error, truncation, or crash). The goal is a
   server that refuses a request it cannot serve.
2. llama-server memory fitting: what `-ngl 999` bypasses, whether a
   fit check exists that fails at load instead of on compute buffers,
   `--no-kv-offload`, unified KV, and the compute-buffer size as a
   function of `-c`, batch and slots, so the fit prediction in
   `docs/methodology/kv-cache-pick.md` can include it.
3. pi: whether a per-turn hard cap exists (`contextWindow` enforcement
   on the request, not only the compaction check), and how
   `reserveTokens` interacts with `maxTokens` when both are set.

### What to test on the Mac, in order

1. **Overhead.** One llama-server turn with pi: compare
   `usage.totalTokens` with the server's `prompt_n` for the same
   request. Record the difference as the template overhead per model.
2. **In-turn growth.** On the Qwen3.8 MLX entry at the current values,
   a synthetic tool that returns an 8K-token result while the context
   sits at 85 percent of the window. Watch the server log for the
   death signature and pi for a compaction. Repeat at 90 and 95
   percent. The largest survivable growth is the margin.
3. **The rule under test.** `contextWindow = ceiling_low - maxTokens -
   margin`, `reserveTokens = maxTokens + margin`, where `ceiling_low`
   is the lowest depth at which the creep saw the server die, not the
   last good row. Apply it to the Qwen3.8 MLX entry and run the
   Mendel smoke (`benchmarks/mendel-smoke.sh`) three times. No crash
   in three smokes is the pass.
4. **llama load check.** For every llama entry, one real completion at
   the entry's full `contextWindow` minus `maxTokens` after load, so a
   `-c` that fails on compute buffers is caught before a run. This
   becomes a line in `tools/preflight.sh` or in the Mendel worker.

The executor fixes tools and searches online when a result needs it;
the material above is the start, not the limit. Output: the rule as a
sentence for `docs/methodology/mendel.md` and `kv-cache-pick.md`, the
margin per backend with its evidence, and the preflight or worker
change as a bench item.

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

## Goal 4 — pi compaction on this hardware (draft, 2026-09-05)

Not a per-model test; it needs two or three approved models. pi
compacts between turns when the context passes `contextWindow -
reserveTokens`, and the model under test writes the summary itself,
so the quality of a compaction differs per model and can be scored.

The candidate task is the Mendel smoke, which some models already
finish at their normal window: Qwen3.8 GGUF f16 at effort medium (run
10 block B, 8 calls, one commit, 62 s) and Gemma-12B llama f16
thinking off (research run 2 probe, 42 calls, one commit). Run the
same smoke with `contextWindow` lowered on a ladder until pi compacts
mid-task, and record per run: whether compaction fired, the summary
pi wrote, the peak context, and whether the task still completed with
a clean commit. A small rubric scores the summary: does it keep the
task, the files touched, and the remaining steps, and does the run
after it finish.

The design with the ladder, the rubric, the repeats and the commands is
`compaction-experiment.md` in this folder (in preparation on branch
`research-compaction`, with the `mendel-smoke.sh` parameters it needs).
Outcome: a `contextWindow` floor per model at which compaction still
rescues the task, or a note that it does not for that model.

## Goal 0 — the wired limit, retested with the slow creep (draft, 2026-09-05)

Top item of this run because the owner is present for sudo and a
reboot. 24000 was set before the slow creep existed and 25000 was
never retried since; runs 9 and 10 served with wired memory at 25.1 to
25.6 GB under the 24000 limit, so what the sysctl bounds is not what
the number says. The procedure page and the research item are in
preparation on branch `wired-limit-method`
(`docs/methodology/wired-limit.md`, Mac only, grouped with the
services script; `wired-limit-retest.md` in this folder with the
history table and the ladder).
