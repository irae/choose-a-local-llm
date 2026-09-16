# Ternary Bonsai-27B on M1 Max 32 GB

Backends: mlx-lm, prism-llama fork · [Ternary-Bonsai-27B on Hugging Face](https://huggingface.co/prism-ml/Ternary-Bonsai-27B-mlx-2bit) ([GGUF](https://huggingface.co/prism-ml/Ternary-Bonsai-27B-gguf))

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>24.5 tok/s</b><span>decode at 4K, MLX 2-bit</span></div>
  <div class="kpi"><b>58K</b><span>deepest healthy step, MLX, 17.3 tok/s</span></div>
  <div class="kpi"><b>0.927 / 0.890</b><span>EvalPlus base / plus, fork q4_0+bias</span><small>98% completion</small></div>
  <div class="kpi"><b>2×48K</b><span>two fork slots, 10.9 GB at the floor</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmarked 2026-08-25 on mlx-lm 0.31.3; quality and fork figures updated 2026-08-30 (prism fork build prism-b10660).

## Highlights

- **27B-class quality from 8 GB of weights** — EvalPlus 0.927 / 0.890 / 98%,
  and the vendor's q4-KV calibration costs no quality. Plain MLX 2-bit
  reads 0.933 / 0.902 / 99% after a re-run of its empty problems, so
  the two builds sit within one problem of each other.
- **The flattest speed curve of any model here** (MLX): −23% from 4K to
  49K, never hits the speed floor; the limit is memory (~58-60K).
- **The only multi-agent setup that leaves the machine free**: 2×48K
  fork slots, 10.0 GB shallow and 10.9 GB at the floor — but window is
  not usable depth: the fork's speed floor is ~30K used tokens.
- **The fork's floor was the cache type, not the weights.** At q4_0 KV
  the scored config crosses the 8 tok/s floor at 33K used tokens. At
  f16 KV with no drafter the same fork holds 15.0 tok/s at 4K and 9.67
  at 131K, the `-c` boundary itself, with wired flat at 18.3 GB and
  zero swap growth; no floor was found. Its one agent row at f16,
  guided at thinking high, scored 12.5 capped from 36 raw, one of
  eight libraries, at a 127K peak context. Its EvalPlus score is
  pending.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" top /> | **40k** | mem | <TokCell shallow="24.5" deep="17.3" stale top-shallow top-deep /> | **22.5 GB** | <ScoreCell value="0.933/0.902" sub="99% completion" top /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" top /> | <span title="EvalPlus 19h24 · Mendel 5h00">24h24</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" top /> | **33k** | speed | <TokCell shallow="14.7" deep="7.8" top-shallow top-deep /> | **9.6 GB** | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 9h55 · Mendel 5h00">14h55</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" /> | **40k** | mem | <TokCell shallow="24.5" deep="17.3" stale top-shallow top-deep /> | **22.5 GB** | <ScoreCell value="0.927/0.902" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h46 · Mendel 3h07">3h53</span> |

† from an earlier serving config or method; re-run pending.

Rows below 100 percent completeness. Completeness counts three measurements: tok/s, EvalPlus and Mendel.

| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" top /> | **2x48k** | speed | <TokCell shallow="14.9" deep="7.8" stale top-shallow top-deep /> | **10.9 GB** | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 9h55 · Mendel —">9h55†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" top /> | **131k** | mem | <TokCell shallow="15.0" deep="9.7" stale top-shallow top-deep /> | **18.6 GB** | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" top /> | <span title="EvalPlus — · Mendel 3h15">3h15†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" />

Keep `--prompt-cache-size 2`: the default cache pool behaves like a memory leak. A real-text read of this server on 2026-09-13 ran with llama-benchy twice and both times the generation thread died on a Metal OOM at the deep cell, at 56320 and then at 52224, with the prompt fill stalled near 47K; the process stayed alive and silent. The ceiling on this machine sits near 47K, not the 58K the 2026-08-29 creep reached, so the harness window is 40960 by the MLX rule and the speed cells keep the creep's numbers with the dagger: no benchy cell survived, because llama-benchy writes its result once at the end of a run.

```bash
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
  --prompt-cache-size 2 --port 8081
```

<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" />

The scored config. The bias file is generated, not downloadable. The file behind the EvalPlus score and the 2026-08-30 sweeps was made with an unrecorded corpus and was lost with `/tmp` on a reboot before 2026-09-04; the file served since bench 11 (2026-09-06) was regenerated with the vendor's `make_kv_bias.sh` and its built-in corpus and lives at `~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf`. The Mendel guided row and every later reading ran on that file; see [the benchmarks](../benchmarks/bonsai-27b.md).

```bash
LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server \
  -m ~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/<rev>/Ternary-Bonsai-27B-Q2_g64.gguf \
  --alias bonsai-prism \
  -ngl 999 -fa on -c 65536 --parallel 1 \
  --cache-type-k q4_0 --cache-type-v q4_0 \
  --kv-mean-center ~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf \
  --jinja --port 8081
```

<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" />

Extra body per request: `{"chat_template_kwargs":{"enable_thinking":false}}`. Curve shared with the thinking-on row: same server, same weights.

```bash
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
  --prompt-cache-size 2 --port 8081
```

<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" />

```bash
LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server \
  -m ~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/<rev>/Ternary-Bonsai-27B-Q2_g64.gguf \
  --alias bonsai-prism-2x \
  -ngl 999 -fa on -c 98304 --parallel 2 \
  --cache-type-k q4_0 --cache-type-v q4_0 \
  --kv-mean-center ~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf \
  --jinja --port 8081
```

<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" />

pi id `bonsai-prism-f16`. Measured 2026-09-08 at wired limit 25000, fork revision `abbae72`. The fork at f16 KV has no speed floor inside `-c 131072`: 15.0 tok/s at 4K and 9.67 at 131K, the `-c` boundary itself, with wired flat at 18.3 GB and zero swap growth. The q4_0 KV rows floor at 33K, so the cache type was the floor, not the weights. No larger `-c` was tried. EvalPlus is pending: the f16 cache does not carry the calibrated q4 row's score. Mendel guided at thinking high: 12.5/100 capped from 36 raw, one of eight libraries, 376 tool calls and 74 tool errors at a 127K peak context.

```bash
LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server \
  -m ~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/<rev>/Ternary-Bonsai-27B-Q2_g64.gguf \
  --alias bonsai-prism-f16 \
  -ngl 999 -fa on -c 131072 --parallel 1 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

**Window is not usable depth** on the fork at a quantized cache. It
allocates huge windows in little memory (the full 262K trained window
fits in 17.1 GB with q8 KV) and never OOMs inside them, but at q4_0 KV
decode crosses the 8 tok/s floor at 33K used tokens. At f16 KV the
floor is gone: the creep at `-c 131072` ran clean to the boundary at
9.67 tok/s, in 18.3 GB, and no larger `-c` has been tried. MLX is
fastest at every depth it reaches and memory-limited at ~58K. For one
agent that needs depth, the fork at f16 KV now holds more than twice
the MLX window at a lower speed; the MLX 2-bit row is the faster arm to 58K;
the fork's q4_0 rows, one slot and two, are the light desktop and the multi-agent
slots.

**The f16 fork has one agent row, and it is a poor one.** Guided at
thinking high on a 131072 window, reserve 8192, it scored 36 raw and
12.5 capped: one of eight libraries in 195 minutes, 376 tool calls and
74 tool errors, one commit that dropped a package another file still
required. The depth was there, at a 127K peak context, and the model
did not use it. Its EvalPlus score is pending; the calibrated q4 row's
score does not carry to a different cache type.

**The quality number was wrong at first, and the correction was the biggest
of any model.** Ternary Bonsai is PrismML's quality-oriented compression of
Qwen3.6-27B, and they claim 95% of full-precision performance. An early pass
scored it far too low, with a token budget that was too small. Calibrating
the budget (10240) and regenerating all 55 truncated completions moved the
score to 0.933/0.902/99%, the second-largest correction in the project. The
flawed cap had been hiding most of its ability. The deflated number is on
[the historical page](../historical.md). The empty completions that remain, two on MLX
and four on the fork, are the output cap: a re-run of each one found
every answer still coming when the budget ran out. The ternary claim holds up: 2-bit compression kept
near-27B-class quality, and the vendor's q4-KV calibration then held it
again (0.927/0.890/98%, slightly above MLX 2-bit).

**Two serving profiles, and they trade against each other.** MLX is fastest
at every depth it reaches, but memory grows with the session and hard-OOMs
by ~58-60K. The fork stays at ~10 GB flat with a ~30K speed floor, so the
Mac stays usable while the agent runs. For one agent that needs depth, MLX
wins on both axes; the fork's niches are multi-agent slots and a light
desktop.

**The DSpark drafter is not worth it past shallow context.** It is
output-lossless and lifts shallow decode (19.1/21.5 py/js at n-max 2,
69/84% acceptance), but it lowers the floor at every draft depth tried and
adds 4-5 GB. Shallow-context serving only. The drafter file must be
converted locally with `gguf-dspark-to-dflash`; the published Q4_1 sidecar
and the plain Q2_0 GGUF are legacy layouts that do not load on current fork
builds.

**The MLX build with thinking off scores 0 on the agent task.** On
2026-09-06 it passed the Mendel smoke at thinking off (14 calls, one
clean commit, 115 s) and then lost the guided run twice. The first
attempt is invalid: a dead `gh` token and a login loop on the harness.
The second is model-failed: 85 identical shell calls in a row against
a missing file, zero commits in three hours, stopped by the operator.
The current live loop stop ends that run within minutes; this run set
that rule and the timeout rules. No further thinking-off run is
planned (owner, 2026-09-14).

**PrismML's own published figures need their serving stack.** They report
100K at ~15 GB, and 262K with 4-bit KV. The 4-bit KV path is llama.cpp-only,
so the fork is where the bigger context lives.

**Blocked: GGUF Q2_0 on brew llama.cpp.** The file is on disk, 6.7 GB,
byte-verified. The current brew build (10621) predates the final Q2_0
tensor layout and refuses to load it. Parked until the next stable release,
which would unlock mainline llama-server slots. When starting it, pin the
file: `--hf-file Ternary-Bonsai-27B-Q2_0.gguf` — the `:Q2_0` tag wrongly
matches the PQ2_0 variant.

1-bit variants were dropped from scope and deleted.

## Which to pick

| need | config | tok/s (used depth) | gated by |
|---|---|--:|---|
| **Depth + speed, one agent** | MLX 2-bit, thinking on | 24.5 shallow; 17.27 at 58K | mem: OOM ~58-60K |
| **Max depth, one agent** | fork, f16 KV, no drafter | 15.0 shallow; 9.67 at 131K | mem: no floor inside `-c 131072` |
| **Light desktop, one agent** | fork, q4_0 KV + bias, one slot | 14.8 shallow, 7.9 at 33K | speed: floor 33K used |
| **Two agents** | fork, q4_0 KV + bias, 2×48K | 14.94 shallow, 7.78 at 33K, one slot decoding | speed: slot floor 33K used |

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" />](../benchmarks/bonsai-27b.md) | 10240 | <ScoreCell value="0.933/0.902" sub="99% completion" top /> | 2 budget | <TokCell shallow="24.5" deep="17.3" /> | 19h24 |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" />](../benchmarks/bonsai-27b.md) | 10240 | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | 4 budget | <TokCell shallow="14.7" deep="7.8" /> | 9h55 |
<!-- gen:model-evalplus:end -->

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" /> | blind-v1.0 | 56k | **37.5** (raw 58) | 3/8/partial | 101.8 | 887k | 28k | 0 | 53 | 3 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" /> | blind-v1.1 | 56k | **37.5** (raw 55) | 3/8/partial | 300.0 | 3,555k | 52k | 0 | 135 | 4 | thinking |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" /> | blind-v1.1 | 64k | **12.5** (raw 60.5) | 1/8/done | 43.1 | 1,718k | 51k | 0 | 76 | 2 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" /> | guided-v2.1 | 56k | **37.5** (raw 69) | 3/8/partial | 230.3 | 2,142k | 51k | 0 | 94 | 3 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" /> | guided-v3.0 | 64k | **31.5** | 3/8/partial | 300.0 | 0k | 63k | 10 | 343 | 3 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" /> | guided-v3.0 | 56k | **12.5** (raw 59) | 1/8/partial | 300.0 | 3,619k | 46k | 0 | 122 | 1 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" /> | guided-v3.0 | 128k | **12.5** | 1/8/partial | 194.7 | 21,049k | 127k | 1 | 376 | 2 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" /> | guided-v3.0 | 56k | **0** (raw 27) | 0/8/invalid | 83.5 | 48k | 5k | 0 | 10 | 0 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" /> | guided-v3.0 | 56k | **0** (raw 25) | 0/8/model-failed | 186.9 | 1,969k | 27k | 0 | 105 | 0 | tool call |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

The full table and the rubric are on [the Mendel page](../../../benchmarks/mendel.md).

## Decode speed vs used context

<ModelSpec base="Ternary-Bonsai-27B" hide="quant,server,publisher,drafter,kv,effort" />

One row per configuration, the shape of
[the comparison table](../comparison.md#decode-speed-vs-used-context).
Slow creeps: MLX 2026-08-29 at wired limit 24000, the fork q4_0 rows
2026-08-30 at 24000, the fork f16 row 2026-09-08 at 25000.

| config | @ 4K | @ 16K | @ 33K | @ 49K | @ 58K | @ 131K | capped by |
|---|--:|--:|--:|--:|--:|--:|---|
| **MLX 2-bit, unquantized KV** | **24.5** | **22.9** | **20.5** | **18.4** | **17.3** | | mem — Metal OOM near 60K on the creep; a real-text read dies near 47K, so the harness window is 40960 |
| fork, q4_0 KV + bias, one slot | 14.8 | 10.8 | 7.9 | | | | speed — under the floor at 33K used tokens |
| fork, q4_0 KV + bias, 2×48K, one slot decoding | 14.9 | 10.7 | 7.8 | | | | speed — the same floor; both slots decoding read 9.8 and 9.9 each |
| fork, f16 KV, no drafter, `-c 131072` | 15.0 | 15.6 | 14.5 | 13.4 | | 9.7 | mem — the `-c` boundary itself; no floor found, wired flat at 18.3 GB |

Every full curve, one row per step, is on
[the benchmarks page](../benchmarks/bonsai-27b.md).

---

Method: warmup before every measurement; identical prompts across models;
temp 0. Full raw numbers in
[the benchmarks](../benchmarks/bonsai-27b.md). Cross-model picks on
[the comparison page](../comparison.md).
