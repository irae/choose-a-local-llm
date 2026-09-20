# M1 Max 32 GB

## Machine

- Apple M1 Max, 32 GB of unified memory, macOS.
- Wired limit 25000 MB: `sudo sysctl iogpu.wired_limit_mb=25000`. It
  resets on reboot. See [the wired limit](#the-wired-limit-25000).
- During a run the machine only serves models: free memory falls near
  zero and the desktop stops responding. Drive it from another
  machine.
- Servers listen on port 8081. Port 8080 is the DB admin UI.
- Harness: pi (`~/.pi/agent/models.json`). Aliases equal the pi model
  ids.
- Machine file for runs: `~/.config/choose-a-local-llm/machine.md`.
- The per-process firewall blocks network access for new binaries.
  Check it first when a new process hangs
  ([checklist](../../methodology/checklist.md)).
- Docker does not fit beside a loaded model.

## Runtimes

- **llama-server**: llama.cpp, brew stable.
- **mlx_lm.server**: mlx-lm, brew.
- **PrismML llama.cpp fork**: `~/prism-llama/`. The only backend for
  ternary GGUFs (Q2_g64), q4 KV with calibration and the DSpark
  drafter.
- **LM Studio**: retired 2026-09-07 ([record](./lmstudio-retired.md)).

## Measured facts

- Quantized KV on llama-server costs 2 to 4 µs per cached token; f16
  costs 0.2 to 0.3. Gemma-4-26B-A4B at 32K: 6.3 tok/s at q8_0, 45.9 at
  f16. Research: `hardware/kamaji/research/kv-quant-on-m1.md`.
- Gemma-4-12B: q8_0 KV falls under 8 tok/s by 16K; f16 reads 13.0
  tok/s at 131K ([KV cache pick](../../methodology/kv-cache-pick.md)).
- MLX curves stay flat and end on a hard memory ceiling. llama-server
  curves fall faster and do not run out of memory inside `-c`.
- The published `-c` of every GGUF model runs out of memory at load.
  Each row carries the largest `-c` that serves a real request.
- 2026-09-06: `mediaanalysisd` pushed free RAM under 100 MB in 20
  seconds during a Mendel run and ended two attempts.

## Models

| model | files | reports |
|---|---|---|
| Qwen3.8-27B | `bartowski/Qwen3.8-27B-GGUF:Q4_K_M`; `mlx-community/Qwen3.8-27B-4bit` | [report](./reports/qwen3.8-27b.md), [benchmarks](./benchmarks/qwen3.8-27b.md) |
| Qwen3.6-35B-A3B (MoE) | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`; `mlx-community/Qwen3.6-35B-A3B-4bit` | [report](./reports/qwen3.6-35b-a3b.md), [benchmarks](./benchmarks/qwen3.6-35b-a3b.md) |
| Gemma-4-26B-A4B (MoE) | `unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL` + MTP draft; `mlx-community/gemma-4-26b-a4b-it-4bit` | [report](./reports/gemma-4-26b-a4b.md), [benchmarks](./benchmarks/gemma-4-26b-a4b.md) |
| Ternary Bonsai-2-27B | `prism-ml/Ternary-Bonsai-2-27B-gguf:PTQ1_0` + `PQ2_0` (prism fork only) | [report](./reports/bonsai-2-27b.md), [benchmarks](./benchmarks/bonsai-2-27b.md) |
| Ternary Bonsai-27B | `prism-ml/Ternary-Bonsai-27B-mlx-2bit`; GGUF `Q2_g64` + `PQ2_0` + converted dflash drafter (prism fork only) | [report](./reports/bonsai-27b.md), [benchmarks](./benchmarks/bonsai-27b.md) |
| Gemma-4-12B-it | `unsloth/gemma-4-12b-it-GGUF:Q4_K_XL`; `lmstudio-community/gemma-4-12B-it-MLX-4bit` (LM Studio engine only) | [report](./reports/gemma-4-12b-it.md), [benchmarks](./benchmarks/gemma-4-12b-it.md) |

- Thinking: Gemma 4, `enable_thinking`, default off. Qwen3.6 and
  Bonsai, binary, default on. Qwen3.8, effort `low`, `medium` or
  `xhigh`; medium is not run.
- 1-bit Bonsai is out of scope.

## The wired limit: 25000

- 25000 is the standing value since 2026-09-08. Single sweeps on a
  fresh server at 25000 showed zero swap growth.
- At 24000 and above, physical RAM binds before the sysctl. At 25000
  llama-server gains window: Qwen3.6 q8_0 98304 against 40960, the
  Qwen3.8 ISTA build 163840 against 131072.
- Below about 24000 the sysctl gates cleanly and costs depth:
  Qwen3.6-35B MLX caps near 13K at 22000.
- Rows measured at 24000 say so in their config notes. Retired values:
  [historical](./historical.md).

## EvalPlus budget

- Scores before the calibrated budget used EvalPlus's default output
  cap and were too low. Since 2026-09-19 every scored run is fast mode
  (thinking budget 8192, output 16384); scores from the calibrated
  budgets in between carry a † until their fast-mode run lands. Old
  numbers: [historical](./historical.md).
