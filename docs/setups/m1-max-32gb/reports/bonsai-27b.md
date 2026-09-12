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
  and the vendor's q4-KV calibration costs no quality (it beats plain
  MLX 2-bit's 0.915 / 0.884 / 97%).
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
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" top /> | **58k** | mem | <TokCell shallow="24.5" deep="17.3" stale top-shallow top-deep /> | **22.5 GB** | <ScoreCell value="0.915/0.884" sub="97% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" top /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" top /> | **33k** | speed | <TokCell shallow="14.8" deep="7.9" stale top-shallow top-deep /> | **9.6 GB** | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" top /> |

† from an earlier serving config or method; re-run pending.

Rows below 100 percent completeness. Completeness counts three measurements: tok/s, EvalPlus and Mendel.

| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" /> | **58k** | mem | <TokCell shallow="24.5" deep="17.3" stale top-shallow top-deep /> | 22.5 GB | <ScoreCell value="0.927/0.902" sub="100% completion" top /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" /> | **2x48k** | speed | <TokCell shallow="14.9" deep="7.8" stale top-shallow /> | **10.9 GB** | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" /> | **131k** | mem | <TokCell shallow="15.0" deep="9.7" stale top-shallow top-deep /> | **18.6 GB** | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" top /> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" />

Keep `--prompt-cache-size 2`: the default cache pool behaves like a memory leak.

```bash
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
  --prompt-cache-size 2 --port 8081
```

<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" />

The scored config. The bias file is generated, not downloadable, and `/tmp` is wiped on reboot; the corpus behind the scored file is unrecorded, so a regenerated file is a different calibration until the owner confirms the corpus. Regenerate with the vendor's `make_kv_bias.sh` into `~/.local/share/choose-a-local-llm/`; see [the benchmarks](../benchmarks/bonsai-27b.md).

```bash
LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server \
  -m ~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/<rev>/Ternary-Bonsai-27B-Q2_g64.gguf \
  --alias bonsai-prism \
  -ngl 999 -fa on -c 65536 --parallel 1 \
  --cache-type-k q4_0 --cache-type-v q4_0 \
  --kv-mean-center /tmp/Ternary-Bonsai-27B-kv-bias.gguf \
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
  --kv-mean-center /tmp/Ternary-Bonsai-27B-kv-bias.gguf \
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
score to 0.915/0.884/97%, the second-largest correction in the project. The
flawed cap had been hiding most of its ability. The deflated number is on
[the historical page](../historical.md). The 4-5 empty completions that
remain are a real model ceiling — they stay empty at the full budget — not
a harness artifact. The ternary claim holds up: 2-bit compression kept
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

**The MLX build with thinking off has no valid agent row.** On
2026-09-06 it passed the Mendel smoke at thinking off (14 calls, one
clean commit, 115 s) and then lost the guided run twice to the harness:
first a dead `gh` token and a login loop, then 85 identical shell calls
in a row against a missing file, zero commits in three hours, stopped
by the operator. Both rows are invalid in the guided CSV. A third
attempt is scheduled, with the runner's live loop stop in place, and
the blind test at thinking off with it.

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

| config | budget | pass@1 base | pass@1 plus | empty completions | completion |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" /> | 10240 | 0.927 | 0.890 | 4/164 (~2%) | 98% |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" /> | 10240 | 0.915 | 0.884 | 5/164 (~3%) | 97% |

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
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" /> | guided-v3.0 | 56k | **0** (raw 25) | 0/8/invalid | 186.9 | 1,969k | 27k | 0 | 105 | 0 | tool call |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

The full table and the rubric are on [the Mendel page](../benchmarks/mendel.md).

## Config 1 (MLX) — decode speed vs used context (slow creep, limit 24000)

| depth (used tokens) | decode tok/s |
|---|--:|
| 4K | 24.5 |
| 8K | 24.2 |
| 16K | 22.9 |
| 24K | 22.0 |
| 32K | 20.5 |
| 40K | 18.60 |
| 42K | 18.66 |
| 50K | 18.36 |
| 52K | 18.09 |
| 54K | 17.64 |
| 56K | 17.69 |
| **58K** | **17.27 — last stable** |
| ~60K | Metal OOM — ceiling ~58-60K |

(A transient 44-48K dip from an earlier pass is on
[the historical page](../historical.md); the watched re-test recovered
to ~18 tok/s past it.)

## Config 2 (fork scored) — depth: measured 2026-08-30

| depth (used tokens) | decode tok/s |
|---|--:|
| 4K | 14.79 |
| 8K | 13.22 |
| 16K | 10.77 |
| 24K | 9.08 |
| **33K** | **7.85 — crosses the 8 tok/s floor** |

9.6 GB RSS at the floor, no compression or swap in the watcher log.
Matches the plain-q4 proxy (~30K) and the 2×48K single-slot sweep
almost exactly — the bias and rotation flags do not move the floor.
Full plain-q4 variant tables (q8, DSpark drafter, 262K alloc) are in
[the benchmarks](../benchmarks/bonsai-27b.md).

## Config 3 (fork 2×48K) — single-slot depth (one slot decoding, other idle), measured 2026-08-30

| depth (used tokens) | slot-0 tok/s |
|---|--:|
| 4K | 14.94 |
| 8K | 13.15 |
| 16K | 10.65 |
| 24K | 9.10 |
| **33K** | **7.78 — crosses the 8 tok/s floor** |

10.9 GB RSS at the floor, no compression or swap. The idle second slot
costs almost nothing (floor matches config 2's single-slot floor and
the plain-q4 proxy). Both slots decoding at once — the worst case, not
the reported number — ran 9.8/9.9 tok/s each, aggregate 19.7 (from an
earlier pass, predates the bias flags).

## Config 5 (fork, f16 KV, no drafter) — slow creep, `-c 131072`, wired limit 25000, measured 2026-09-08

Fork revision `abbae72`, `LLAMA_ATTN_ROT_DISABLE=1`, one slot, 60 s
pause per step. The first request on the server was a 4096-token
warmup at 16.93 tok/s, discarded.

| depth (used tokens) | decode tok/s | wired |
|---|--:|--:|
| 4K | 14.95 | 18.3 GB |
| 8K | 16.25 | 18.3 GB |
| 16K | 15.62 | 18.3 GB |
| 25K | 15.07 | 18.3 GB |
| 33K | 14.45 | 18.3 GB |
| 41K | 13.92 | 18.3 GB |
| 49K | 13.40 | 18.3 GB |
| 66K | 12.50 | 18.3 GB |
| 82K | 11.45 | 18.6 GB |
| 98K | 10.76 | 18.6 GB |
| 115K | 10.24 | 18.2 GB |
| **131K** | **9.67 — the `-c` boundary, no floor found** | 18.2 GB |

Swap never grew; the delta went slightly negative as the sweep went
deeper. Against the q4_0 rows this is the same weights, the same fork
and the same machine, with the cache type the only change, and the
33K floor is gone.

---

Method: warmup before every measurement; identical prompts across models;
temp 0. Full raw numbers in
[the benchmarks](../benchmarks/bonsai-27b.md). Cross-model picks on
[the comparison page](../comparison.md).
