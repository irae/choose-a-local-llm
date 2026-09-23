# Qwen3.6-35B-A3B UD-Q4_K_XL (unsloth)

File: [`unsloth/Qwen3.6-35B-A3B-MTP-GGUF`](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF),
`Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf`, revision `5bc3e23`, about 20 to 23
GB depending on the machine's copy, with the MTP head embedded.
Server: llama-server. The M1 Max 32 GB uses KV type f16 or q8_0
depending on the arm. The RTX 5060 Ti 16 GB uses CUDA with q8_0 KV and
`--n-cpu-moe` for the experts that do not fit on the card. Every run of
this file on every machine is on this page, retired and superseded
rows included; a run a harness or serving defect voided is not.

- **Why it is here.** On the M1 Max, this is the first Qwen3.6 file
  measured on the machine, and the machine's deep-context MoE
  candidate: 35B total parameters with about 3B active per token,
  trained context 262144. On the RTX 5060 Ti, the card's file is
  larger than the card, so a measured count of expert layers stays in
  host RAM; a community NVFP4 repack of the same model failed a
  tensor-count check at load, so the owner picked this mainstream
  unsloth build over a niche one (owner, 2026-09-14).
- **What it settled.** The MTP drafter fails to allocate on the M1
  Max's current brew llama.cpp build, and several arms now serve
  without it; without the drafter, the M1 Max's f16 KV arm holds a
  window 60 percent larger than its q8_0-with-drafter arm (65536
  against 40960). On the M1 Max, thinking on leads on EvalPlus
  (0.957/0.939 at budget 26624 against 0.951/0.915 at budget 8192),
  and the Mendel harness window decides the score directly: the same
  config scored 46.5 on a frozen 49152-token window and 62.5 on the
  81920-token window its own creep supports. On the RTX 5060 Ti, the drafter pays at every depth: n-max
  2, with 21 expert layers in host RAM, is the served arm, fastest at
  4K and 65K and within the spread of n-max 3 at 97K; the guided agent
  task scored 48.5, 6 of 8 libraries, and ended on a repetition loop at
  the seventh.
- **Where it stands.** The M1 Max reads 0.957/0.939 on EvalPlus at
  thinking on, budget 26624, both remaining empties proven as the
  output cap; the RTX 5060 Ti reads 0.945/0.902 on the same test, 6 of
  164 answers empty, cause unproven. The M1 Max's best Mendel row is
  guided at thinking on, 83/100 complete on the 112k window; the RTX
  5060 Ti's best is guided at thinking on, 48.5/100 partial.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" top /> | **82k** | <TokCell shallow="43.7" deep="13.0" cap="speed" /> | **25.6 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="83" pill="mendel-guided" top /> | <span title="EvalPlus 2h27 · Mendel 1h32">3h59</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" top /> | **82k** | <TokCell shallow="43.7" deep="13.0" cap="speed" /> | **25.6 GB** | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | <ScoreCell value="62.5" pill="mendel-guided" top /> | <span title="EvalPlus 0h15 · Mendel 1h29"><b>1h44</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" top /> | 66k | <TokCell shallow="50.5" deep="33.6" cap="mem" stale /> | **25.0 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="50" pill="mendel-blind" /> | <span title="EvalPlus 2h27 · Mendel 0h33"><b>3h00</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/qwen36-unsloth-ud-q4kxl" top /> | **97k** | <TokCell shallow="61.16" deep="45.42" cap="mem" top-shallow top-deep /> | **14.7 GB** | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" /> | <span title="EvalPlus 2h24 · Mendel 0h27"><b>2h51</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | 41k | <TokCell shallow="69.1" deep="52.6" cap="mem" stale top-shallow top-deep /> | **25.1 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 2h27 · Mendel —">2h27†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:binary-rows:end -->

<!-- gen:binary-best-preset:start -->
Best configuration on this page, as a section of `hardware/kamaji/models.ini` (M1 Max 32 GB, llama-server, pi id `qwen3.6-35b-a3b-q4kxl-q8-mtp3`). Every preset of this page: [`qwen3.6-35b-a3b-q4kxl-q8-mtp3`](#preset-qwen3-6-35b-a3b-q4kxl-q8-mtp3), [`qwen3.6-35b-a3b-q4kxl-f16`](#preset-qwen3-6-35b-a3b-q4kxl-f16), [`qwen3.6-35b-a3b-q4kxl-q8-mtp2`](#preset-qwen3-6-35b-a3b-q4kxl-q8-mtp2).

```ini
[qwen3.6-35b-a3b-q4kxl-q8-mtp3]
hf = unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL
no-mmproj = true
spec-type = draft-mtp
spec-draft-n-max = 3
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 98304
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```
<!-- gen:binary-best-preset:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md) | 8192 | 16384 | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | none | 17/164 | <TokCell shallow="43.7" deep="13.0" /> | 2h27 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/arrietty/benchmarks/qwen3.6-35b-a3b.md) | 8192 | 16384 | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="61.16" deep="45.42" /> | 2h24 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md) | none | 8192 | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | none | — | <TokCell shallow="43.7" deep="13.0" /> | 0h15 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md) | —† | 26624 | <ScoreCell value="0.957/0.939" sub="99% completion" /> | 2 budget | — | <TokCell shallow="43.7" deep="13.0" /> | 5h02 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/arrietty/benchmarks/qwen3.6-35b-a3b.md) | —† | 24154 | <ScoreCell value="0.945/0.902" sub="96% completion" /> | † unproven | — | <TokCell shallow="61.16" deep="45.42" /> | 3h12 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:binary-evalplus:end -->

On the M1 Max, both empties left on the thinking-on row are the output
budget, not a model stop: a re-run of the empty problems on 2026-09-16
proved the cause. On the RTX 5060 Ti, the 6 empty answers are unproven
because the run saved no finish log.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | blind-v1.1 | 96k | **63** | 8/8/done | 79.2 | 7,933k | 94k | 0 | 203 | 13 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | blind-v1.1 | 80k | **50.5** | 8/8/done | 40.0 | 6,996k | 98k | 2 | 190 | 10 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | blind-v1.1 | 64k | **50** | 8/8/done | 33.0 | 7,344k | 61k | 2 | 211 | 13 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | blind-v1.0 | 96k | **41.5** | 8/8/done | 132.0 | 10,090k | 94k | 1 | 258 | 13 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | guided-v3.0 | 112k | **83** | 8/8/done | 91.9 | 12,712k | 94k | 1 | 285 | 16 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | guided-v2.1 | 96k | **65.5** | 8/8/done | 75.6 | 12,081k | 94k | 0 | 251 | 8 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | guided-v3.0 | 80k | **62.5** | 8/8/done | 89.4 | 13,045k | 78k | 1 | 264 | 16 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | guided-v3.0 | 96k | **48.5** | 6/8/partial | 27.2 | 10,958k | 86k | 1 | 266 | 6 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | guided-v3.0 | 48k | **46.5** | 8/8/done | 95.6 | 9,473k | 52k | 12 | 299 | 7 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

On the M1 Max, the same config's two guided rows at thinking off (46.5 on a
49152-token window, twelve compactions; 62.5 on the 81920-token window
with one compaction) show the window deciding the score, not the
model. Every blind row that finished on the M1 Max carries a critical
trap: `fs.promises.glob()` returns an AsyncIterator, and every run's
`.then()` call on it throws. On the RTX 5060 Ti, the guided row ended
with 6 of 8 libraries done and a live loop stop: five identical edit
calls in a row on the seventh library, declared after 27.2 minutes.
Three of the six commits moved `.husky/pre-commit` aside and back
around `git commit`, a functional bypass the literal `--no-verify`
check in `score.mjs` does not see.

## Speed and context

<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" hide="drafter,kv,effort" />

| machine | measurement | date | config | result |
|---|---|---|---|---|
| M1 Max 32 GB | MTP sweep | 2026-08-27 | 32K context, f16 KV, n-max 0 to 4 | peak at n-max 3: 68.21 tok/s py (82% acceptance), 73.53 tok/s js (90%); off baseline 52.34/52.41 |
| M1 Max 32 GB | ladder and creep | 2026-09-11 | f16 KV, no drafter, wired limit 25000, `-c 65536` | serves a real completion at 25027 MB wired; creep ran clean to 65578 tokens at 33.64 tok/s, no ceiling found |
| M1 Max 32 GB | real text, llama-benchy | 2026-09-11 | q8_0 KV, drafter n-max 3, `-c 98304`, wired limit 25000 | 43.68 tok/s at 4K, 19.23 at 49K, 13.01 at 82K; acceptance 54 to 85 percent |
| M1 Max 32 GB | real text, llama-benchy | 2026-09-11 | f16 KV, no drafter, `-c 40960`, wired limit 25000 | 49.80 tok/s at 4K, 38.26 at 40K; within four percent of the creep |
| M1 Max 32 GB | vision, projector loaded | 2026-09-11 | f16 KV, `-c 65536`, wired limit 25000 | 1400-pixel page costs 7005 prompt tokens; drafter works beside the projector only at n-max 1, ahead of the model card |
| RTX 5060 Ti 16 GB | `--n-cpu-moe` ladder and no-drafter arm | 2026-09-13 | q8_0 KV, `-c 98304`, `--n-cpu-moe 17` | 55.81 tok/s at 4K, 37.80 at 97280; swap flat around 4.5-4.7 GB |
| RTX 5060 Ti 16 GB | drafter climb, n-max 1 | 2026-09-13 | q8_0 KV, `--n-cpu-moe 19` | 60.60 tok/s at 4K, 37.92 at 97280, faster than no drafter at every depth; acceptance 0.78-0.84 |
| RTX 5060 Ti 16 GB | drafter climb, n-max 2 (served) | 2026-09-13 | q8_0 KV, `--n-cpu-moe 21` | 61.16 tok/s at 4K, 50.04 at 65536, 45.42 at 97280; acceptance 0.63-0.92 |
| RTX 5060 Ti 16 GB | drafter climb, n-max 3 | 2026-09-13 | q8_0 KV, `--n-cpu-moe 21` | 57.85 tok/s at 4K, 47.25 at 65536, 46.76 at 97280; acceptance 0.54-0.77, the last arm in the climb |

The full curves, including the retired 24000 and 27000 wired-limit
tables on the M1 Max, are on [the M1 Max benchmarks
page](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md), [the historical
page](../setups/kamaji/historical.md), and [the RTX 5060 Ti benchmarks
page](../setups/arrietty/benchmarks/qwen3.6-35b-a3b.md). The M1 Max's
q8_0 KV arm at n-max 3 reads 43.7 tok/s at 4K and 13.0 at 82K; the RTX
5060 Ti's served n-max 2 arm reads 61.16 tok/s at 4K and 45.42 at
97280.

## Server presets

<!-- gen:binary-presets:start -->
### `qwen3.6-35b-a3b-q4kxl-q8-mtp3` {#preset-qwen3-6-35b-a3b-q4kxl-q8-mtp3}

M1 Max 32 GB, a section of `hardware/kamaji/models.ini` (llama-server).

```ini
[qwen3.6-35b-a3b-q4kxl-q8-mtp3]
hf = unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL
no-mmproj = true
spec-type = draft-mtp
spec-draft-n-max = 3
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 98304
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### `qwen3.6-35b-a3b-q4kxl-f16` {#preset-qwen3-6-35b-a3b-q4kxl-f16}

M1 Max 32 GB, a section of `hardware/kamaji/models.ini` (llama-server).

```ini
[qwen3.6-35b-a3b-q4kxl-f16]
hf = unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 65536
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### `qwen3.6-35b-a3b-q4kxl-q8-mtp2` {#preset-qwen3-6-35b-a3b-q4kxl-q8-mtp2}

RTX 5060 Ti 16 GB, a section of `hardware/arrietty/models.ini` (llama-server).

```ini
[qwen3.6-35b-a3b-q4kxl-q8-mtp2]
hf-repo = unsloth/Qwen3.6-35B-A3B-MTP-GGUF
hf-file = Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf
no-mmproj = true
parallel = 1
spec-type = draft-mtp
spec-draft-n-max = 2
n-gpu-layers = 999
fit = off
n-cpu-moe = 21
flash-attn = on
ctx-size = 98304
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```
<!-- gen:binary-presets:end -->

## Log

- 2026-08-27 — M1 Max: MTP sweep at 32K context, f16 KV: peak at
  n-max 3, 68.21 tok/s py (82% acceptance) and 73.53 tok/s js (90%),
  ahead of the no-drafter baseline of about 52 tok/s both ways. The
  fixed 3072-token output budget was found flawed the same run:
  reasoning could exhaust the cap and score an empty completion as a
  failure, so this run's EvalPlus reading is a lower bound.
  `hardware/kamaji/benchmarks/bench1/`.
- 2026-08-28 — M1 Max: the budget-calibration method introduced (10
  fixed problems, 30K cap, budget = observed max times 1.5). At the
  calibrated budget of 26624 tokens this config scored
  0.957/0.939/99% with 2 empty, recovering 56 missing or empty
  completions from the flawed 3072-cap pass (0.610/0.610/62%, 62 of
  164 empty). `hardware/kamaji/benchmarks/bench2/`.
- 2026-08-30 to 2026-08-31 — M1 Max: Mendel guided row (prompt v2.1):
  67.5/100, partial. The MTP drafter fails to allocate on the current
  brew llama.cpp build: the backend returns HTTP 500 on every request
  while `/health` stays ready. The guided run served without the
  drafter; a re-check was planned for the next run.
  `hardware/kamaji/benchmarks/bench5/`.
- 2026-09-01 — M1 Max: the planned drafter re-check deferred on the
  owner's decision; the run closed after its own EvalPlus block
  without touching this file. `hardware/kamaji/benchmarks/bench6/`.
- 2026-09-01 to 2026-09-03 — M1 Max: served with no MTP drafter
  flags, per the runbook. Mendel blind (prompt v1.0) scored 41.5/100,
  complete. Mendel guided (prompt v2.1) scored 65.5/100, complete, all
  8 libraries, 75.6 minutes. `hardware/kamaji/benchmarks/bench7/`.
- 2026-09-05 to 2026-09-06 — M1 Max: thinking off scored on EvalPlus
  for the first time: 0.951/0.915/100%, 0 empty at budget 8192, ahead of the
  thinking-on sibling's then-current 0.939/0.921/97% at budget 26624.
  `hardware/kamaji/benchmarks/bench10/`.
- 2026-09-06 to 2026-09-07 — M1 Max: every missing Mendel row filled
  at the trial wired limit 25000, opened by this file's own depth
  creep. Guided at thinking off scored 46.5 on a frozen 49152-token
  window with twelve compactions, then 62.5 on the 81920-token window
  the creep supports, complete; the rule that measured parameters come
  from the newest measurement came out of this file. The f16 KV arm
  now loads `-c 40960`, which it did not at the retired 24000 limit.
  `hardware/kamaji/benchmarks/bench11/`.
- 2026-09-11 — M1 Max: real-text speed with `llama-benchy` at the
  server's own sampling: the q8_0 drafter arm reads 43.7 tok/s at 4K
  down to 13.0 at 82K (54 to 85 percent acceptance); the f16
  no-drafter arm reads 49.8 at 4K and 38.3 at 40K. Mendel blind at
  thinking off scored 50.5/100, complete 8/8, on the 81920 window, one
  critical trap missed; sampling (temperature 1.0, top_p 0.95)
  recorded for the first time. `hardware/kamaji/benchmarks/bench14/`.
- 2026-09-11 — M1 Max: the f16 KV arm without its drafter laddered
  and creeped at wired limit 25000: `-c 65536` serves, and the creep
  ran clean to 65578 tokens at 33.6 tok/s with no ceiling found, a
  window 60 percent larger than the drafter arm's 40960. Mendel blind
  at thinking on scored 50/100, complete 8/8, on the 65536 window, two
  compactions, one critical trap missed, 33 minutes. With the vision
  projector loaded, the same server still serves `-c 65536`; one
  1400-pixel page costs 7005 prompt tokens, and the drafter works
  beside the projector only at n-max 1, against the model card, and
  wins at every depth measured. `hardware/kamaji/benchmarks/bench15/`.
- 2026-09-12 to 2026-09-13 — M1 Max: real-text speed re-read against
  the depth creep on every no-drafter arm; this file's rows matched
  within four percent. `hardware/kamaji/benchmarks/bench16/`.
- 2026-09-13 — RTX 5060 Ti: a community NVFP4+MTP repack of this
  model (`michaelw9999/Qwen3.6-35B-A3B-NVFP4-MTP-GGUF`) fails to load
  at any `--n-cpu-moe` or `-c`: a tensor-count mismatch, 1079 tensors
  against an expected 1101. Not a memory condition, so the coordinator
  stops and asks. `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-14 — RTX 5060 Ti: owner picks this unsloth UD-Q4_K_XL file
  over the failed NVFP4 repack, a popular stable release over a niche
  build. `--n-cpu-moe` ladder and drafter climb run: no drafter at 17
  (55.81 tok/s at 4K, 37.80 at 97280), n-max 1 at 19 (60.60, 37.92),
  n-max 2 and n-max 3 at 21 (61.16 and 45.42 for n-max 2; 57.85 and
  46.76 for n-max 3). n-max 2 is named the served arm: fastest at 4K
  and 65K, within the spread of n-max 3 at 97K, and needs less VRAM
  headroom for its smaller draft window.
  `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-14 to 2026-09-15 — RTX 5060 Ti: Mendel smoke on the served
  arm (window 94208, level high) passes clean, 7 calls, 1 commit, no
  loop. Guided agent task scores 48.5 raw, 6 of 8 libraries done, on a
  27.2-minute run: trap A shipped (an `fs.promises.glob().then()`
  call), a second `fs`-not-imported bug shipped in the same commit,
  and three of six commits moved the pre-commit hook aside and back
  around `git commit`, a bypass the automatic `--no-verify` check
  misses. The run ends on a five-times repetition loop at the seventh
  library. `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-15 to 2026-09-16 — M1 Max: re-run of the empty EvalPlus
  problems: both empties on the thinking-on row are the output
  budget, none a model stop. Thinking-on score moved to 0.957/0.939.
  `hardware/kamaji/benchmarks/bench20/`.
- 2026-09-15 to 2026-09-16 — RTX 5060 Ti: EvalPlus at thinking on,
  served arm, `-c 32768`: calibration converges cleanly on 10 of 10
  rows (unlike both Qwen3.8 builds on this card), budget 24154 from
  the standard formula. The host runs under memory pressure through
  the block, 0.4.0-dev with 21 expert layers in host RAM, about 1.1 to
  1.5 GB free and 10 to 11 GB of swap in use, stable and not growing.
  Scores 0.945/0.902, 100% completion, in 192.0 minutes. The run's own
  `results.md` reports 0 empty answers; the coordinator re-derived the
  count from the samples on 2026-09-16 and found 6 of 164 empty, cause
  unproven because the run saved no finish log.
  `hardware/arrietty/benchmarks/bench19/`.
- Historical — M1 Max: rows at the retired 24000 and 27000 wired
  limits. At 24000: f16 KV served only `-c 33792` (33920 OOMs), and
  q8_0 KV served `-c 40960` in practice (49920 passed a one-token
  probe, then OOM'd on the first real step). At 27000 (retired for
  making the machine too slow for normal use): q8_0 KV served
  `-c 212992` single session and `2×96K` across two slots; f16 KV
  served 136K single session. Superseded by the 25000-limit rows
  above. [The historical page](../setups/kamaji/historical.md).
