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

## 7. Score the GGUF quant, and revisit the q8 KV default for Gemma-12B

Two asks that came out of the same measurement. The reasoning matters
more than the asks, so it is written out.

### The measurement

Depth sweeps of Gemma-12B on llama-server, raw `/completion`, house
method, 25 s pause, watcher running, machine clean:

| used tokens | q8 KV + MTP | q8 KV, no MTP | **f16 KV, no MTP** |
| --- | --- | --- | --- |
| 4115 | 13.82 | 14.15 | **24.64** |
| 8235 | 8.74 | 10.64 | **24.05** |
| 16411 | 6.53 → floor | 7.12 → floor | **22.66** |
| 32819 | — | — | **20.58** |
| 49159 | — | — | **18.75** |
| 65551 | — | — | **17.42** |

The q8 columns confirm the published row exactly — 13.8 → 6.5, ceiling
16k, gated by speed. **That row is correct and not stale.**

Two levers were tested. Dropping the MTP drafter helps modestly
(+22% at 8K). Switching KV from q8 to f16 is the large one: it turns a
config that falls through the 8 tok/s floor by 16K into one still doing
17.4 tok/s at 65K.

### Ask 1 — the GGUF quant has never been scored

`models.json` gives the two GGUF Gemma-12B rows an EvalPlus of
0.909/0.872. That number was measured on
`lmstudio-community/gemma-4-12B-it-MLX-4bit` and copied across.

The copy policy is deliberate and sound: at temperature 0, configs
matching on model, thinking, quant and kv-quant should produce the same
answers. But **the quant axis does not match here.** MLX 4-bit and
unsloth Q4_K_XL are different quantisation schemes, not two spellings of
"4-bit". So the GGUF rows carry a score no GGUF run has produced.

**Ask: run EvalPlus on Gemma-12B, llama-server, thinking off.** It scores
the GGUF quant for the first time, and it either confirms the copy or
shows the two quants differ — which would matter well beyond this model,
since the same copy applies elsewhere.

Note on which KV to use for it: by `common-rules.md` rule 6, q8 is
"verified byte-identical to f16 at temperature 0", so the KV type should
not move the score. If that holds, run it on whichever config would
actually ship. If it does NOT hold, that is itself a finding worth
having.

### Ask 2 — the q8 default rests on a premise this model breaks

Rule 6 says q8 is the default because "the context it unlocks overrules
f16's **~1% speed edge**". On Gemma-12B the edge is not 1%. At 16K used
tokens f16 is **3.2x** faster, and q8 is below the usability floor while
f16 is not.

The rule already anticipates this — it carries a caveat to measure q8's
decode cost per model, citing Gemma-26B losing MTP acceptance. This is
that caveat firing far harder than the headline figure suggests.

The trade also inverts on this model. q8 is preferred for the context it
unlocks, but f16 KV at 262144 measured 15.8 GB wired, inside the 24000
limit — so f16 does not cost the context here. It costs about 2 GB of
headroom and buys a usable deep curve.

**Ask: decide whether Gemma-12B's published config moves to f16 KV**, and
whether rule 6's "~1%" needs re-wording to say the edge is model-
dependent and can be large. This run proposes nothing to the site.

### What is not yet measured

- **The chat path.** These are raw `/completion` numbers, comparable
  with every published row but not what pi uses. The chat path adds a
  system turn and the tool definitions to every request, so real use
  reaches a given depth sooner. A chat reading at the chosen config is
  queued.
- **LM Studio re-ramped.** Its table row (35.4 → 29.3 at 147K) was not
  re-measured today and is still the faster curve on paper. A fair
  head-to-head needs the llama chat number, because LM Studio's sweep
  must use chat — its raw completions endpoint is broken on this build.
