# Binary pages: one page per model file per machine

Status: in progress, filed 2026-09-16 on the owner's request. Origin:
the owner's word of 2026-09-16, "pages for all the models per binary
on each system, aggregating all runs, from all efforts, KV types and
so on; runs invalidated by defects and harness issues are not shown;
every run, retired ones included, shows; then a log of all that was
done". Needs hardware: no. Every source is in this repository.

## What exists

- The generator fills three blocks per page from `models.json`
  (`binaries` list) and the Mendel CSVs: `gen:binary-rows`,
  `gen:binary-evalplus`, `gen:binary-mendel`. `EDITOR.md`, "Binary
  pages", gives the page shape. Read that section first.
- Two finished pages are the models to copy:
  `docs/setups/kamaji/binaries/qwen38-ista-iq3s-mtp.md` (Mac) and
  `docs/setups/arrietty/binaries/gemma12-freedomaisvr-nvfp4.md` (card).
- The sidebar already lists every page below. A missing page is a
  build failure, so every item below must land.

## Rules for the agent that writes one page

1. Read `CONVENTIONS.md`, then `EDITOR.md` "Binary pages", then the two
   finished pages, then the sources of your page. Write in ASD-STE100
   Simplified Technical English: short sentences, active voice, one
   idea per sentence.
2. Write only your page. Do not edit `models.json`, the generator, the
   sidebar or any other page. Do not run `npm run docs:tables`; the
   coordinator runs it once at the end. Copy the six marker lines from
   a finished page verbatim and leave them empty.
3. Every number carries its date and its condition (wired limit, KV
   type, drafter, `-c`, level). A number that is superseded says so.
   Never invent a number: a fact you cannot find in the sources is
   left out, and the reply to the coordinator names the gap.
4. The Log is chronological, oldest first, one bullet per event, with
   the run kit path at the end of the bullet. Every run that touched
   the file appears, retired and superseded rows included. A run the
   harness or a serving defect voided is not a row; it may be one log
   sentence that says why it is not shown.
5. The three bullets under the file line quote the owner's decisions in
   the owner's words where a source has them ("owner rule",
   "owner, date", commit bodies).
6. Sources common to every page: the setup's `models.json` row notes
   for the rows whose spec matches (base, quant, publisher, server);
   `hardware/<setup>/benchmarks/INDEX.md`; the `report.md`, `state.md`
   and `results.md` of every run kit named below; the archive page
   `docs/setups/<setup>/benchmarks/<model>.md`; `docs/setups/kamaji/historical.md`
   for superseded Mac numbers; `benchmarks/mendel/results.csv` and
   `results-guided.csv` for every agent run (the `model` column names
   the build); `git log --all --oneline -- <paths>` for dates.
7. Reply with the page path, the count of log bullets, and the list of
   facts you could not source.

## Pages, one agent each

### M1 Max 32 GB (`docs/setups/kamaji/binaries/`)

- [ ] `qwen38-bartowski-q4km.md` — Qwen3.8-27B Q4_K_M (bartowski),
  rows `qwen38-gguf-medium`, `qwen38-gguf-xhigh`. The first Qwen3.8
  file on the machine: MTP sweeps and the MLX comparison (bench1,
  bench2), the medium blind row at reserve 16384 (87) and its re-run
  at reserve 8192 (76, bench12), wired 25000 creep and `-c 73728`
  (bench12), the drafter read on real text (bench14, bench16), blind
  at xhigh 93 (bench14), EvalPlus at xhigh (bench15), the ramps at the
  retired 27000 limit (historical page). Runs 22 on the Mac adds a
  budgeted EvalPlus row; log it as pending if its results are not in
  `hardware/kamaji/benchmarks/bench22/` yet.
- [ ] `qwen38-unsloth-ud-iq3s.md` — Qwen3.8-27B UD-IQ3_S (unsloth),
  row `qwen38-gguf-unsloth-iq3s-xhigh`. bench18 (ladder, creep, benchy,
  EvalPlus at xhigh, blind 90.5 with the merge anomaly, guided 62.5
  partial), bench20 (`qwen38-unsloth-xhigh-rerun`, eight empties
  proven). Name the anomaly as the report does.
- [ ] `qwen38-atomicchat-ad-iq3s.md` — Qwen3.8-27B AD-IQ3_S
  (AtomicChat), row `qwen38-gguf-atomicchat-iq3s`. Research run 3
  (candidate, creep, smokes), bench12 (EvalPlus 0.988/0.927 at medium,
  the n-max sweep the owner asked for, blind ended on a repetition
  loop at 3 of 8, 37.5 capped from 74 raw). Medium is banned since
  2026-09-09; say the rows are records.
- [ ] `qwen38-unsloth-ud-q3kxl.md` — Qwen3.8-27B UD-Q3_K_XL (unsloth).
  No row. Research run 3 only: creep with and without the drafter
  (mem stop at 49198 with it, clean past 131072 without), dropped as
  a candidate by the owner on 2026-09-08, its creep stands as a
  measurement. A short page; the generated blocks will read "No
  configuration row" and "No EvalPlus run yet".
- [ ] `qwen38-mlx-4bit.md` — Qwen3.8-27B MLX 4-bit (mlx-community),
  rows `qwen38-mlx-medium`, `qwen38-mlx-low`. bench1 and bench2 (first
  scores, the MLX creep and Metal OOM near 28K to 30K, MTP-on-MLX
  disqualified for want of an API), bench5 to bench10 (Mendel at
  medium and low, every run partial or invalid on the 26624 window,
  two Metal OOM crashes), the "not run" decision of 2026-09-10.
- [ ] `qwen36-unsloth-ud-q4kxl.md` — Qwen3.6-35B-A3B UD-Q4_K_XL
  (unsloth), rows `qwen36-gguf-think`, `qwen36-gguf-off`,
  `qwen36-gguf-f16-nodrafter`, `qwen36-gguf-f16`. bench1 and bench2
  (MTP sweep, the 3072-cap score and its correction to 26624), bench5
  to bench7 (guided rows, the drafter allocation failure on the brew
  build, the 46.5 row on a 49152 window), bench11 (wired 25000, the
  ladder and creep the owner asked for, window 81920), bench10 (thinking
  off scored), bench16 (real text, thinking-off blind 50.5), bench20
  (empties proven, score 0.957/0.939), the historical page (24000 and
  27000 rows).
- [ ] `qwen36-mlx-4bit.md` — Qwen3.6-35B-A3B MLX 4-bit (mlx-community),
  row `qwen36-mlx-think`. bench2 (creep, Metal OOM near 41K), bench16
  (blind 37.5 on a 36864 window, the foreign-stash re-run), the 5
  percent MLX window rule (owner, 2026-09-12).
- [ ] `gemma26-unsloth-ud-q4kxl.md` — Gemma-4-26B-A4B UD-Q4_K_XL
  (unsloth), rows `gemma26-gguf`, `gemma26-gguf-2x`. bench1 to bench3
  (first scores, thinking on and off), the park of 2026-08-30 (bench5),
  bench9 and bench10 (back in the running at f16 KV: creep to 197K,
  EvalPlus both levels, smoke, blind 47.5, guided 57 on its third
  attempt after two memory kills), the thinking-off agent rows that
  looped (bench10), the two-slot row, bench20 (16 empties proven),
  bench22 (the thinking-budget block, 0.988/0.957, 16 forced; pending
  the owner's word on how it is shown), the projector load (bench16).
- [ ] `gemma26-mlx-4bit.md` — Gemma-4-26B-A4B MLX 4-bit
  (mlx-community), row `gemma26-mlx` (abandoned). bench2 and bench3
  (creep, EvalPlus 0.713 then re-scored 0.793 in bench20), the failed
  agent smoke and the retirement (2026-09-12,
  `docs/setups/kamaji/gemma-4-26b-a4b-mlx-retired.md`).
- [ ] `gemma12-unsloth-q4kxl.md` — Gemma-4-12B Q4_K_XL (unsloth), rows
  `gemma12-gguf-f16`, `gemma12-gguf-off`, `gemma12-gguf-4x`,
  `gemma12-gguf-2x`. bench1 and bench2 (MTP sweeps, q8_0 KV), bench4
  and bench9 (the KV pick, f16 no drafter, the 245K curve, EvalPlus
  thinking off), bench12 (two slots at 82K each, four slots), the
  guided row 37.5, research run 2 (the thinking-on ruling of
  2026-09-04 and the compaction ladder floor 23552 in research run 3).
- [ ] `gemma12-lmstudio-mlx-4bit.md` — Gemma-4-12B MLX 4-bit
  (lmstudio-community) on LM Studio, rows `gemma12-lmstudio-think`
  (retired), `gemma12-lmstudio-off` (abandoned). bench3, bench4 (the
  ceiling criterion the owner set), bench7 (three model-failed agent
  runs, the newline flood), research run 2 (two entries treated as one
  model, the retirement of the failing entry), the retirement of LM
  Studio on 2026-09-07 (`docs/setups/kamaji/lmstudio-retired.md`). The
  Mendel runs of this build show only on the retired page by rule;
  the generated block on this page still lists them, and the text
  says so.
- [ ] `bonsai-mlx-2bit.md` — Ternary-Bonsai-27B MLX 2-bit (prism-ml),
  rows `bonsai-mlx`, `bonsai-mlx-off`. bench1 and bench2 (the deflated
  score and the largest correction, the flat curve to 58K), bench5 to
  bench7 (the 60.5 row the owner had re-run from scratch, the retry
  penalty rule born here, the operator-stopped loop), bench10
  (thinking off: smoke pass, guided lost twice, no further
  thinking-off run), bench16 (dies near 47K on real text, window
  40960), bench20 (three empties recovered, server deaths on long
  generations, `--prompt-cache-size`).
- [ ] `bonsai-prism-q2g64.md` — Ternary-Bonsai-27B Q2_g64 (prism-ml)
  on the prism fork, rows `bonsai-fork-single`, `bonsai-fork-2x`,
  `bonsai-fork-f16`. bench3 and bench4 (the fork, the q4 KV bias file,
  the DSpark drafter, two slots), bench7 (guided high 31.5, the
  owner's re-run and abort), bench12 (f16 KV creep to 131K, the guided
  row 12.5), bench20 (four empties proven), bench22 (the fork has the
  reasoning-budget flag; its blocks are pending), the blocked Q2_0 and
  PQ2_0 layouts on brew llama.cpp.

### RTX 5060 Ti 16 GB (`docs/setups/arrietty/binaries/`)

- [ ] `gemma12-unsloth-ud-q4kxl.md` — Gemma-4-12B UD-Q4_K_XL (unsloth),
  rows `gemma12-q4kxl-off`, `gemma12-q4kxl-on`. bench17 (speed at three
  depths as the NVFP4 control, guided at thinking on model-failed, the
  818-times loop), bench19 (EvalPlus at both levels: 0.793/0.780 with
  34 empties at thinking on, every answered problem passed; 0.951/0.909
  at thinking off).
- [ ] `qwen38-unsloth-ud-iq3s.md` — Qwen3.8-27B UD-IQ3_S (unsloth), row
  `qwen38-iq3s-xhigh`. bench17 (the KV type measured, q8_0 against f16,
  the drafter arms, guided 79 on 7 of 8), bench19 (EvalPlus 0.957/0.921,
  three empties unproven).
- [ ] `qwen38-ista-iq3s-mtp.md` — Qwen3.8-27B IQ3_S-mtp (ISTA-DASLab),
  row `qwen38-ista-xhigh`. bench17 (added on the owner's word as the
  cross-machine pair, the drafter arms and the three watchdog crashes
  at 440 MiB free, guided 85 and blind 91 on a 61440 window), bench19
  (EvalPlus 0.945/0.909, seven empties unproven, two crashes on the
  drafter arm inside the run), bench21 (the thinking-budget blocks,
  pending or done per `hardware/arrietty/benchmarks/bench21/`).
- [ ] `qwen36-unsloth-ud-q4kxl.md` — Qwen3.6-35B-A3B UD-Q4_K_XL
  (unsloth), row `qwen36-q4kxl-on`. bench17 (the `--n-cpu-moe` ladder,
  four drafter arms, guided 48.5 with the pre-commit bypass), bench19
  (EvalPlus 0.945/0.902, six empties unproven, the host memory
  pressure).
- [ ] `qwen36-michaelw9999-nvfp4.md` — Qwen3.6-35B-A3B NVFP4
  (michaelw9999). No row. bench17 only: the file failed a tensor-count
  check at load and the owner chose the unsloth k-quant instead. A
  short page.
- [ ] `gemma26-catlilface-nvfp4q8.md` — Gemma-4-26B-A4B NVFP4Q8
  (catlilface), row `gemma26-nvfp4-on`. bench17 (the `--n-cpu-moe 7`
  ladder, 97K at 59 to 46 tok/s, guided 37.5 on 3 of 8 ended on a text
  loop), bench19 (EvalPlus 0.909/0.878, 14 empties unproven).

## After the pages

The coordinator runs `npm run docs:tables`, `npm run verify`,
`npm run docs:build` and `npm run docs:check`, reads every page once,
and merges the branch. Nothing on this list needs the Mac.
