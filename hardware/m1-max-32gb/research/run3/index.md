# Research run 3, task list

Not started. The runbook (`AGENT.md`) and the rest of the kit appear
when the run starts. Items are one file each in `../`, named by
mnemonic and never numbered. **This list is the order.** The executor
checks the items off here as it goes and writes results beside the
item (`../<mnemonic>/results.md`).

Everything here runs at wired 25000, the limit the next runs drive.
Items that wait on a decision, on a download, or on the MLX margin
rule live in `../unscheduled/`, which has no index and no order.

Five rules hold across every item in this run:

- **One effort or thinking level per candidate: the level its control
  row already uses** (owner rule, 2026-09-07). That level takes the
  candidate through its whole chain of steps, creep, then the Mendel
  smoke, then the EvalPlus smoke. A second level enters the run only
  when a research item names that level itself, and then it is its own
  line in the list below.
- **The KV cache is f16.** This hardware is slow at a quantized KV
  cache. Use q8_0 only where a build cannot reach a needed depth at
  f16, and say so in the row.
- **Every candidate gets a context creep.** The creep answers speed,
  which no desk survey can.
- **A gate is a task, never a decision taken as one result lands.**
  Every creep runs, then one gate item reads them all and writes which
  later items it invalidated. Every EvalPlus smoke runs, then one gate
  item does the same for the Mendel smokes. A gate logs every
  candidate it looked at, the ones it passed as well as the ones it
  stopped.
- **No full Mendel run and no full EvalPlus run.** Research stops at
  the two smokes. A candidate that passes both becomes a bench item.
- **GGUF only.** An MLX build enters only when it is the only build of
  that model that exists.

- [x] `downloads-background` — start the model files this run still
  needs, in the background, and go on to the next item at once. The
  `unsloth/…:UD-Q3_K_XL` build is already on disk (2026-09-07);
  `AtomicChat/…:AD-IQ3_S` and
  `ISTA-DASLab/…:GSQ-RCO-IQ3_S-mtp` are not, with their MTP drafters.
  Two downloads at a time, never three. The download's own notes live
  with the machine's model pins, not here.
- [x] `tool-check` — clone or `git pull --ff-only`
  `git@github.com:irae/local-llm-eval-tools.git` at
  `~/code/local-llm-eval-tools`, record `git rev-parse --short HEAD`
  in `state.md`, and run `creep.py llama --help`. That hash is pinned
  for the whole run: no second pull in the middle of it. The two
  tools were already compared on this machine and they agree, so this
  item measures nothing; it only fixes which version the run used.
- [x] `qwen38-unsloth-q3kxl-creep` — `unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL`,
  ladder, then context creep at f16 KV, MTP drafter on.
  **The priority of this run.** It is the only K-quant of the three,
  so it is the one build whose speed does not depend on the i-quant
  Metal path. If it cannot hold 8 tok/s at the depth the agent task
  needs, no 3-bit build will, and the two builds below stop mattering.
- [x] `qwen38-atomicchat-iq3s-creep` —
  `AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S`, ladder, then creep at f16
  KV. At almost the same size as the build above it drifts 18 percent
  less against BF16 by the publisher's own KLD. This creep also gives
  the first i-quant decode number this machine has ever had.
- [ ] `qwen38-ista-iq3s-mtp-creep` —
  `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, ladder, then creep
  at f16 KV. The only build with task-level proof and the only one
  with papers. Its projected window sits above 120K, so this creep
  carries the long-prompt completion check for llama.cpp issue 27756.
- [ ] `qwen38-creep-gate` — **a task, not a judgment call.** Read all
  three creep files together, after the last one ends. For each build
  write one line in `results.md`: the build, its clean depth, the
  reference depth, the ratio, and `evalplus: run` or
  `evalplus: skipped, context too small`. The reference is the deepest
  clean depth this machine has measured for Qwen3.8 at the same KV
  type: **49152 at f16** (the row we serve today). The rule: a build
  whose clean depth is more than 20 percent under the reference, so
  **under 39322 tokens at f16**, skips its EvalPlus smoke and every
  step after it. A build at or above that depth runs its EvalPlus
  smoke. Log every build, including the ones that pass, so the run
  records which creep invalidated which EvalPlus smoke.
- [ ] `qwen38-unsloth-q3kxl-evalplus-smoke` — EvalPlus smoke, same
  budget on both sides, against the row we serve today. Runs only if
  `qwen38-creep-gate` marked it `run`.
- [ ] `qwen38-atomicchat-iq3s-evalplus-smoke` — the same, under the
  same gate.
- [ ] `qwen38-ista-iq3s-mtp-evalplus-smoke` — the same, under the same
  gate.
- [ ] `qwen38-evalplus-gate` — **a task, not a judgment call.** Read
  every EvalPlus smoke this run produced, after the last one ends. For
  each build write one line in `results.md`: the build, its pass
  count, and `mendel: run` or `mendel: skipped, EvalPlus returned
  nothing`. The rule: a build whose EvalPlus smoke returned an empty
  result on every task skips its Mendel smoke. A build the creep gate
  already skipped is logged here too, as `mendel: skipped, no EvalPlus
  smoke ran`. Log every build, so the run records which EvalPlus
  invalidated which Mendel smoke.
- [ ] `qwen38-unsloth-q3kxl-mendel-smoke` — Mendel smoke on the window
  its creep supports, against the same smoke on the row we serve
  today. Runs only if `qwen38-evalplus-gate` marked it `run`.
- [ ] `qwen38-atomicchat-iq3s-mendel-smoke` — the same, under the same
  gate.
- [ ] `qwen38-ista-iq3s-mtp-mendel-smoke` — the same, under the same
  gate. This is the clean test of whether a "task-lossless" 3-bit
  claim survives an agent loop.
- [ ] `qwen38-effort-low-smoke` — the row we serve today
  (`bartowski/Qwen3.8-27B-GGUF:Q4_K_M`, f16, `-c 49152`), Mendel smoke
  at effort low, against the medium row's 87
  (../qwen38-configs.md, "Reasoning effort"). Research named this
  level, so it is tested.
- [ ] `qwen38-effort-xhigh-smoke` — the same row, Mendel smoke at
  effort xhigh. Research named this level too. Public evidence runs
  against the report that medium is worst, which makes the pair more
  interesting, not less.
- [ ] `compaction-qwen38` — the window ladder on Qwen3.8 GGUF Q4_K_M,
  f16 KV, `-c 49152`, effort medium (../compaction-experiment.md). Two
  baseline runs, then up to three rungs, two repeats each.
- [ ] `compaction-gemma12` — the same ladder on Gemma-4-12B,
  llama-server, f16 KV, thinking off, the probe arm of research run 2.
- [ ] `compaction-bonsai-mlx` — the same ladder on Bonsai MLX at
  thinking off. Runs only if its smoke line says `pass`.
- [ ] `compaction-gemma26` — the same ladder on Gemma-26B GGUF at f16.
  Runs only if its smoke line says `pass`.
- [ ] `strip-qwen38-pair` — one load pair with and without the mmproj
  on `bartowski/Qwen3.8-27B-GGUF:Q4_K_M`, same `-c`, KV type and
  drafter on both sides (../strip-modules.md). About ten minutes,
  unattended. This pair runs first of the three; the other two are
  optional.
- [ ] `strip-gemma26-pair` — the same pair on
  `unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL` at `-c 212992`. Expect
  an OOM at load on the "with" side; the item says what to do then.
  Optional.
- [ ] `strip-qwen36-pair` — the same pair on
  `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` at `-c 49152`, drafter
  removed on both sides. Optional. Gemma-12B has no pair: its 175 MB
  sits below the noise of `vm_stat` between runs.
- [ ] `strip-qwen38-nodrafter-creep` — ladder and creep on the Qwen3.8
  row with `--spec-type draft-mtp` removed, everything else unchanged.
  The projector pairs above measure a saving the served rows already
  take, so they change no pick. The drafter is the arm that can: the
  head is worth about 200 to 300 MB, and a drafter costs depth, so
  dropping it may buy a deeper window at a shallower speed. Only a
  ladder and a creep can price that trade.
- [ ] `strip-gemma26-nodrafter-creep` — the same on the Gemma-26B row,
  where the drafter is a separate 462 MB file. Optional. Qwen3.6 has
  no such item: its drafter is small against a 22.9 GB file, and it
  pays 68 to 74 tok/s shallow.

The container trials are not in this run. The owner moved that item to
`../unscheduled/container-trials.md` on 2026-09-07. Its survey is
finished and its shortlist stands: the owner dropped the Google QAT
Gemma-26B build, its second pick is the same file as
`qwen38-unsloth-q3kxl-*` above at the same revision, and only the
Qwen3.6 3-bit candidate is left of it.
