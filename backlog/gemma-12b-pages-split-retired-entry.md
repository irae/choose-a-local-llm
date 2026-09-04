# Gemma-12B content sweep: retire `google/gemma-4-12b` everywhere, keep the two working containers in front

Status: APPROVED by the owner, 2026-09-04. Blocked on one measurement:
the working LM Studio config's own depth curve, ceiling and memory,
which is bench 9 block A0 (first block of that run). Everything else
can start; cells that wait on it read "pending" until the block
reports. The GGUF quant's own EvalPlus (bench 9 block B1) does NOT
block: the GGUF rows keep the shared score, marked pending.
Filed: 2026-09-04. Origin: research run 2 found that the site treated
two LM Studio entries as one model; the owner then ruled the failing
entry out and asked for this sweep.
Needs hardware: no for the sweep itself.

## The situation in one paragraph

This setup has had three ways to run Gemma-4-12B-it, and the site mixed
them. The GGUF (`unsloth/gemma-4-12b-it-GGUF:Q4_K_XL` on llama-server)
works with thinking off. The LM Studio entry `gemma-4-12b-it-mlx`
(container `lmstudio-community/gemma-4-12B-it-MLX-4bit`) works with
thinking off, cannot think at all, and holds the model's best score:
EvalPlus 0.909/0.872 with all 164 answers delivered. The LM Studio
curated entry `google/gemma-4-12b` always thinks, ships Google's
pre-fix chat template, scored 0.622 only because 61 of 164 answers
never finished, produced all three failed Mendel rows, and is no longer
in the model store. Server lore records that the curated id resolved
to the same lmstudio-community container, so the difference is the
entry (manifest, template resolution, thinking), not the weights. The
owner's ruling: Gemma-4-12B with thinking on is out for agent work on
MLX and LM Studio; thinking off is the model.

Yet almost every Gemma-12B speed and ceiling number on the site was
measured on the retired entry and copied to the thinking-off row, and
the report page says the good config "is not reproducible today",
which run 2 disproved by probe. The sweep fixes that.

## What the sweep does

1. **Main report page** `docs/setups/m1-max-32gb/reports/gemma-4-12b-it.md`
   presents only the two working containers: GGUF thinking off (one
   slot and four slots) and `gemma-4-12b-it-mlx`. Every number on it
   must have been measured on the container it describes. The LM
   Studio KPIs (29.3 tok/s at 65K, the 65-74K ceiling), the "Decode
   speed vs used context" tables, the "Two ceilings" section and the
   "Shallow confirmation sweep" were all measured on
   `google/gemma-4-12b`. Until bench 9 block A0 measures
   `gemma-4-12b-it-mlx`, those cells read "pending" with a link to
   the historical page; after it, they carry the new curve. The
   "Thinking is binary" and "MTP sweep — thinking ON" material moves
   to the details page.
2. **`models.json`**: retire row `gemma12-lmstudio-think` completely.
   Not `hidden: true` (that flag exists and only suppresses rendering,
   leaving wrong numbers in the data). Strip every measurement and the
   command from the row and keep a bare record:
   ```json
   {
     "id": "gemma12-lmstudio-think",
     "config": "Gemma-4-12B, LM Studio entry google/gemma-4-12b",
     "retired": {
       "date": "2026-09-04",
       "reason": "thinking-on repetition loop; entry gone from the model store",
       "details": "../benchmarks/gemma-4-12b-it.md#the-retired-entry"
     }
   }
   ```
   `tools/gen-tables.mjs` learns the `retired` block: such a row is
   skipped by every table, KPI and config renderer, and the model's
   report page gets one line under its table, "Retired entries:
   <config> — <reason> (details)", so a reader who searches the page
   for the entry lands on the evidence. `checkRefs` must not count a
   retired row. The EvalPlus thinking-on run leaves `evalplusRuns` the
   same way: its 0.622 with 61/164 empties is a superseded number and
   lives on the historical and details pages, not in the current gate
   table. Row `gemma12-lmstudio-off` loses the speed and memory
   numbers copied from the retired row (mark them `stale`) until
   block A0 lands. Run `node tools/gen-tables.mjs` after every edit.
3. **Details page** `docs/setups/m1-max-32gb/benchmarks/gemma-4-12b-it.md`
   (not in the sidebar) gets one section, "`google/gemma-4-12b`: the
   retired entry and the thinking-on pitfall", holding all the evidence
   in one place so the main page stays clean:
   - 0.622/0.610 with 61/164 empties and 99.0% pass on the answers
     given (`research/run2/results/gemma12-thinking-score.md`);
   - the three invalid Mendel rows: 130 calls with 30 distinct and one
     invalid command repeated 72 times in a row; the newline floods
     that open the thought channel and never proceed
     (`research/run1/results/invalid-runs.md`,
     `research/run1/results/tool-call-trial.md`,
     `research/run2/results/flood-shape.md`);
   - the container ships Google's pre-fix chat template and the
     standard loader picks it (`research/run2/results/container-audit.md`,
     `row-verdicts.md`);
   - on llama-server the loop reproduced in three of three pre-fix
     arms and one of two post-fix arms, and DRY sampling hid it rather
     than stopping it (`research/run2/results/replay-llama.md`,
     `dry-arm.md`);
   - the probe that showed `gemma-4-12b-it-mlx` cannot think and
     `google/gemma-4-12b` cannot stop thinking
     (`research/run2/results/lmstudio-thinking-probe.md`,
     `two-gemma-entries.md`);
   - the community sources: Google's discussion closing the 12B
     thought-loop as a weight-level attractor at full precision, and
     LM Studio bug 2013 on the reasoning delimiters
     (`research/run2/results/web-upstream-status.md`,
     `gemma12-verdict.md`);
   - the conclusion in the owner's words: thinking on is a pitfall of
     this model in our configs, on both backends.
4. **Historical page** `docs/setups/m1-max-32gb/historical.md`: the
   LM Studio depth tables and ceilings measured on the retired entry
   move here under a dated "superseded" section, newest first, per
   EDITOR.md "Historical figures". No superseded number stays on a
   current page.
5. **Sweep the rest of the site** for the retired id and the shared
   numbers: `docs/index.md` (row 4 and footnote ³),
   `docs/setups/m1-max-32gb/comparison.md`,
   `docs/setups/m1-max-32gb/benchmarks/evalplus.md` (generated),
   `docs/setups/m1-max-32gb/benchmarks/mendel.md` (invalid footnote),
   `docs/methodology/server-lore.md` (the three LM Studio entries that
   name the model; keep the generic lesson, move the specifics to the
   details page — see the backlog item on method pages naming models).
6. **Mendel data** stays as it is: the three rows are evidence, marked
   invalid with the reason "repetition loop on the LM Studio MLX
   thinking-on entry google/gemma-4-12b, pre-fix chat template".

## Rules to write by

- `EDITOR.md` first: page shape, vocabulary, the record-everywhere
  rule, and "Historical figures" (no superseded number on a current
  page; link to `historical.md` from where it used to be).
- `docs/methodology/common-rules.md` rule 8: keep thinking-on and
  thinking-off data both labelled, never replace one with the other.
  The retired entry's data is kept, on the details and historical
  pages.
- The method pages never name a model; the specifics land on the
  setup pages.
- `npm run verify` before the commit; `node tools/gen-tables.mjs
  --check` is part of it.

## Evidence index, for the agent that takes this

Run 2, all under `research/run2/results/`: `two-gemma-entries.md`
(the split itself, highest attention), `lmstudio-thinking-probe.md`,
`gemma12-thinking-score.md`, `gemma12-verdict.md`, `row-verdicts.md`,
`container-audit.md`, `flood-shape.md`, `replay-llama.md`,
`dry-arm.md`, `gemma12-depth.md` and `kv-speed.md` (the GGUF side: the
q8 row is correct, f16 is the fix), `model-pins.md` (the LM Studio
store copy records no upstream revision), `planner-notes.md` items 2,
5 and 7. Run 1: `results/invalid-runs.md`, `backend-diagnosis.md`,
`tool-call-trial.md`. Older history the agent does NOT need to dig:
`benchmarks/bench3/state.md` (the two EvalPlus runs),
`benchmarks/bench4/lmstudio-forensics.md` (LM Studio lore),
`benchmarks/calibration.md` (the thinking-on budget calibration that
already showed 4 of 10 problems hitting the cap).
