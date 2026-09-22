# Gemma-4-12B MLX 4-bit (lmstudio-community)

File: [`lmstudio-community/gemma-4-12B-it-MLX-4bit`](https://huggingface.co/lmstudio-community/gemma-4-12B-it-MLX-4bit),
about 6.3 GB in LM Studio's own model cache. That cache carries no
revision reference; the machine cannot pin the exact upstream commit.
Server: LM Studio (`lms`). Every run of this file on every machine is on
this page, retired and abandoned rows included; a run a harness or
serving defect voided is not.

- **Why it is here.** It was the only way to serve Gemma-4-12B as MLX
  weights with more than one slot on this machine, so it entered the
  comparison at all.
- **What it settled.** LM Studio is retired here. The model store held
  two registered entries under one label: `gemma-4-12b-it-mlx`, thinking
  off and unable to turn on, and `google/gemma-4-12b`, thinking on and
  always on, gone from the model store since 2026-09-04. Every agent run
  on this file ran the thinking-on entry, and every one of them failed
  with zero commits. Context length could not be pinned on either
  entry: every documented override path was ignored.
- **Where it stands.** Abandoned for agent work. The thinking-off entry
  scored 0.909/0.872 on EvalPlus with no empty answer, but it never ran
  the agent task; the thinking-on entry ran the agent task three times
  and failed all three.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-lmstudio-mlx-4bit" /> 💀 | ***131k*** | ****34.19*** → ***23.23***, mem* | ***17.2 GB*** | <ScoreCell value="0.909/0.872" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 1h33 · Mendel —">1h33†</span> |

💀 LM Studio is retired here: three agent runs, zero commits, a window that cannot be pinned. [Why it is not a candidate](../setups/kamaji/lmstudio-retired.md).

Retired entry (M1 Max 32 GB): Gemma-4-12B, LM Studio entry google/gemma-4-12b — thinking-on repetition loop; entry gone from the model store ([details](../setups/kamaji/lmstudio-retired.md)).
<!-- gen:binary-rows:end -->

<!-- gen:binary-best-preset:start -->
No server preset: this file is not served by a llama.cpp build.
<!-- gen:binary-best-preset:end -->

† from an earlier serving config or method; re-run pending.

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-lmstudio-mlx-4bit" />](../setups/kamaji/benchmarks/gemma-4-12b-it.md) | none | 30000 | <ScoreCell value="0.909/0.872" sub="100% completion" top /> | none | — | <TokCell shallow="34.19" deep="23.23" /> | 1h33 |
<!-- gen:binary-evalplus:end -->

The thinking-off row (`gemma-4-12b-it-mlx`) has no empty answer. The
thinking-on entry (`google/gemma-4-12b`, retired) scored 0.622/0.610 at
63% completion, 61 of 164 empty; of the 103 problems it answered, 102
passed, so the empties are a completion failure, not a quality drop
(`docs/setups/kamaji/benchmarks/gemma-4-12b-it.md`, "the retired
entry"). That row does not appear in the generated block above because
it ran a retired entry.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="high" hardware="m1-max-32gb" page="/binaries/gemma12-lmstudio-mlx-4bit" /> | blind-v1.1 | 144k | **0** (raw 30.5) | 0/8/model-failed | 49.5 | 218k | 28k | 0 | 15 | 0 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="high" hardware="m1-max-32gb" page="/binaries/gemma12-lmstudio-mlx-4bit" /> | guided-v3.0 | 160k | **0** (raw 30) | 0/8/model-failed | 46.0 | 306k | 30k | 0 | 21 | 0 |  |
| <ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/gemma12-lmstudio-mlx-4bit" /> | guided-v3.0 | 160k | **0** (raw 29.5) | 0/8/model-failed | 99.0 | 1,971k | 45k | 3 | 130 | 0 | tool call |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

Every Mendel run of this file ran the thinking-on entry
(`google/gemma-4-12b`), which is retired and excluded from the site's
Mendel tables by rule; the generated block above is expected to be
empty or to omit these rows. The three runs, in full, are on
[the LM Studio page](../setups/kamaji/lmstudio-retired.md): blind at high, 30.5/100,
0 of 8 libraries, 0 commits, a newline flood in the thinking channel
after the first real edit attempt; guided at high, 30/100, 0 of 8, 0
commits, the same flood; guided at low, 29.5/100, 0 of 8, 0 commits, a
100-call loop on an invalid `ls` flag before the same flood. All three
collapse the same way regardless of the requested thinking level,
because thinking cannot be turned off on this entry.

## Speed and context

Measured on the M1 Max 32 GB, the only machine that served this file.

<ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| depth sweep, old criterion | 2026-08-29/30 | `google/gemma-4-12b`, auto-fit context | 170K reported by the engine's auto-fit; 37 tok/s shallow, 31 deep; superseded, the auto-fit ceiling was an engine artifact, not a real memory or speed limit |
| depth sweep, new criterion | 2026-08-30 | same entry, ceiling = onset of memory compression/swap | last clean step 65,094 tokens at 29.29 tok/s; auto-fit context stayed 158,464 (marked with an asterisk as an estimate, not a measured limit) |
| single-context v2, watched | 2026-08-29 | `lms load google/gemma-4-12b -c 158464 --parallel 4 --gpu max -y` | last clean step 49,087 tokens at 30.53 tok/s; heavy compression onset between 49K and 74K; sustained compression and swap from 98K on, still serving at 22.77 tok/s at 158K |
| two-context alternating, watched | 2026-08-29 | same load, two contexts | compression onset near 49.9K tokens per context; last clean step about 33K per context |
| real text, shallow probe | 2026-08-30/31 | `gemma-4-12b-it-mlx` | 35.4 tok/s shallow (replaces an earlier unverified 37), 8.1 GB RSS (replaces 8.8 GB) |
| forensic ceiling readings | 2026-08-29 | `lms load` at various `-c` values | every override path ignored; auto-fit always lands at 158,464 tokens under the 24000 MB wired limit; `--estimate-only` reports 8.83 GB for a request the engine's own math prices at about 29 GB, so it cannot be used as a fit check |

`gemma-4-12b-it-mlx` reads the fastest Gemma-4-12B curve measured on
this machine: 34.19 tok/s at 4,115 used tokens and 23.23 at 131,098, in
17.2 GB, against the GGUF configuration's 24.64 and 8.86 at 245,810
(both 2026-09-04, chat path, wired limit 24000). The full
account is on [the LM Studio page](../setups/kamaji/lmstudio-retired.md) and
[the Gemma-12B archive page](../setups/kamaji/benchmarks/gemma-4-12b-it.md#the-retired-entry).

## Server presets

<!-- gen:binary-presets:start -->
No server preset: this file is not served by a llama.cpp build.
<!-- gen:binary-presets:end -->

## Log

- 2026-08-29 — First EvalPlus run of this file, thinking off, model key
  `gemma-4-12b-it-mlx`: 0.909/0.872, no empty answer, 100% answered.
  `hardware/kamaji/benchmarks/bench3/`.
- 2026-08-29 — A 16-problem A/B against `google/gemma-4-12b` confirmed
  the thinking-off score is genuine, not thinking that happened to
  finish fast. `hardware/kamaji/benchmarks/bench3/`.
- 2026-08-29 — LM Studio forensics: context length is not controllable
  for this model on any documented path; auto-fit always lands at
  158,464 tokens under the 24000 MB wired limit; `--parallel` is
  honored; `--estimate-only` cannot be trusted as a fit check.
  `hardware/kamaji/benchmarks/bench4/lmstudio-forensics.md`.
- 2026-08-29/30 — Depth sweeps under the old auto-fit ceiling criterion,
  later superseded. `hardware/kamaji/benchmarks/bench4/`.
- 2026-08-30 — The owner set the current LM Studio ceiling criterion:
  onset of memory compression or swap in the watcher log, tok/s from
  the last clean step before it. Gemma-12B ceiling: onset between 65K
  and 74K tokens, 29.29 tok/s at 65,094. `hardware/kamaji/benchmarks/bench4/`.
- 2026-08-30/31 — Shallow probe re-run and corrected: 35.4 tok/s
  (replaces an unverified 37), 8.1 GB RSS (replaces 8.8 GB). EvalPlus
  thinking-on paused at 98 of 164, resumed in the next run.
  `hardware/kamaji/benchmarks/bench5/`.
- 2026-09-03 — Three Mendel agent runs on `google/gemma-4-12b`, thinking
  on: blind high 30.5/100, guided high 30/100, guided low 29.5/100. All
  three ended zero commits, on a newline flood in the thinking channel
  after the first real edit attempt, or on a tool-call loop before it.
  `hardware/kamaji/benchmarks/bench7/`.
- 2026-09-04 — Research run found the site had conflated two different
  registered entries under one label: `gemma-4-12b-it-mlx` (thinking
  off, the good EvalPlus score) and `google/gemma-4-12b` (thinking on,
  all three Mendel rows, the 0.622/0.610 EvalPlus row). A thinking probe
  on `gemma-4-12b-it-mlx` confirmed thinking off is reproducible with no
  kwarg and with either `enable_thinking` value.
  `hardware/kamaji/research/run2/`.
- 2026-09-04 — Owner decision: Gemma-4-12B on MLX or LM Studio is ruled
  out for thinking-on agentic work. GGUF Gemma-12B stays in scope.
  `hardware/kamaji/research/run2/results/gemma12-verdict.md`.
- 2026-09-04 — `google/gemma-4-12b` retired: it always thinks, ships
  Google's pre-fix chat template (replaced upstream on 2026-07-15), and
  is gone from the model store. Its Mendel rows show only on the LM
  Studio page by rule. `docs/setups/kamaji/benchmarks/gemma-4-12b-it.md#the-retired-entry`.
- 2026-09-07 — LM Studio retired as a candidate runtime on this
  machine: no agent run ever converted its speed advantage into
  finished work, and its context window could not be pinned.
  `docs/setups/kamaji/lmstudio-retired.md`.
