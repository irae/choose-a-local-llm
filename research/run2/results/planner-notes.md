# Notes for the coordinator and planner

Requests from research run 2. A research run does not change published
pages or schedule scored benchmarks, so these are handed over.

## 1. Add a completion-rate column wherever EvalPlus is rendered

**Owner instruction, 2026-09-04.** Every place an EvalPlus score appears
should carry the completion rate beside it: the main comparison table,
the per-model report tables, and any KPI tile.

Why: a score can be low because the answers were wrong, or because there
were no answers. Those are different failures with different fixes, and
the current rendering cannot tell them apart. Measured example — the
Gemma-12B thinking-on row scores 0.622 not because its answers are poor
but because 37% of them are missing; of the ones it delivered, 99.0% pass
(`gemma12-thinking-score.md`).

Measured from the raw result files in `benchmarks/bench*/results/`, so
these are recomputable rather than transcribed:

| Row | EvalPlus | answered | completion | pass rate on answers |
| --- | --- | --- | --- | --- |
| Qwen3.8-27B, effort medium | 0.982 / 0.939 | 164/164 | **100.0%** | 98.2% |
| Qwen3.6-35B-A3B | 0.939 / 0.921 | 159/164 | 97.0% | 96.9% |
| Bonsai-27B, fork | 0.927 / 0.890 | 160/164 | 97.6% | 95.0% |
| Gemma-12B, thinking off | 0.909 / 0.872 | 164/164 | **100.0%** | 90.9% |
| Gemma-12B, MLX thinking on | 0.622 / 0.610 | 103/164 | **62.8%** | **99.0%** |

The rate is `(164 - empty solutions) / 164`, counted from each run's
`*_temp_0.0.raw.jsonl`. Where `models.json` already records an `empty`
field it agrees exactly, so the existing data supports the column with no
re-running.

`gemma-4-26b-a4b` records 46/164 empty, a 72% completion rate, and was
not recomputed here because it is outside this run's scope.

**Related, for future runs:** EvalPlus raw files keep only `task_id` and
`solution`. When a solution is empty there is nothing left to say why —
a repetition loop and a plain output-budget truncation look identical.
Keeping the raw response, or the stop reason, would make empties
diagnosable instead of merely countable.

## 2. Queue a GGUF Gemma-12B Mendel run

All three Gemma-4-12B Mendel rows ran on LM Studio, which the owner ruled
out for thinking-on agentic work. There is no scored GGUF Gemma-12B agent
row at all. Detail and the supporting replay evidence in
`gemma12-verdict.md`.

Note the constraint discovered afterwards: **LM Studio's current engine
always thinks**, and the report already says the thinking-off MLX config
is "not reproducible today". So a thinking-off Mendel run has to be GGUF
on llama-server, not LM Studio.

## 3. Terminology

Use the community words: **repetition loop**, **degeneration**,
**tool-call loop**. Not "collapse", which already means training on
synthetic data. Four files still carry the old word and are listed in
`terminology.md`.

## 4. Two published configs that need attention

- **The Bonsai fork config points at a missing file.**
  `--kv-mean-center /tmp/Ternary-Bonsai-27B-kv-bias.gguf` — `/tmp` is
  cleared on reboot and the file is gone. It is generated, not
  downloadable. Detail in `bonsai-kv-bias-missing.md`.
- **Gemma-12B GGUF rows may be stale for speed reasons unrelated to the
  template.** Row 3 claims a 16k ceiling gated by speed, while this run
  served 262144 with 13.6 GB wired. Row 4 already carries the
  "re-run pending" dagger. See `context-ramp.md` and `kv-speed.md`.

## 5. Two LM Studio Gemma entries, treated as one model

Highest-attention item, at the owner's request. Full detail in
`two-gemma-entries.md`. In one line: the best Gemma-12B score and the
three failed Mendel rows come from **different LM Studio entries**, and
the report's claim that the good one is irreproducible has been
disproved by probe.

## 6. A depth sweep was invalidated by a resident LM Studio, and how

Recorded as a method warning. A first depth sweep of GGUF Gemma-12B read
13.83, 8.80 and 6.60 tok/s and looked like a clean confirmation of the
published row. The memory watcher showed **free memory at 55 MB with
active decompression**, and `ps` showed **LM Studio still resident** —
`lms server stop` and `lms unload --all` had run, but the app itself had
not been quit, so its Electron and GPU helpers were still on the machine.

`docs/methodology/checklist.md` step 3 already says to quit the app with
`osascript -e 'quit app "LM Studio"'` and confirm the menu bar item is
gone. That step was skipped here. The sweep was discarded and re-run
after quitting the app, which returned free memory from 55 MB to 6.2 GB.

Worth considering for the checklist: the probe script that leaves the app
resident is the same shape any future LM Studio work will take, so a
"quit the app" step belongs at the END of an LM Studio probe as well as
before a llama.cpp run.
