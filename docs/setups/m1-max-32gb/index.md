# This machine — M1 Max, 32 GB

## Highlights

- **Wired limit: 24000 MB.** It resets on reboot. Re-run the sysctl
  before any model work.
- **This machine is a model server, not a workstation, while it serves
  the models under test.** At the sizes we evaluate, a run drives free
  memory to near zero and the desktop stops responding. We do not
  consider a shared-use setting. Drive the models from another machine.
- **Every model has a depth curve, a KV pick and an EvalPlus score.**
  Qwen3.8 0.982/0.939/100%, Gemma-26B 0.976/0.945/100% and Gemma-12B
  0.976/0.939/100% thinking off, Qwen3.6 0.951/0.915/100% thinking off,
  Bonsai 0.927/0.890/98%. The decode-vs-used-context table on the
  [comparison page](./comparison.md) is this project's main artifact.
- **Two local models finish the agent task.** Qwen3.8 on llama-server at
  f16 KV scores 87 of 100 blind, Gemma-26B 47.5, both complete.
- **Four runtimes are in play**, not one: llama-server, mlx_lm.server, LM
  Studio's engine, and the PrismML llama.cpp fork.
- **The rule:** MLX barely slows down but OOMs hard; llama holds its
  speed deeper at f16 KV, and its ceiling is the largest `-c` that
  loads.

## Setup

```bash
sudo sysctl iogpu.wired_limit_mb=24000
```

**This resets on reboot.** Re-run it before any model work. See
[the wired limit](#the-wired-limit-24000).

- Servers always listen on port 8081. Port 8080 is the DB admin UI. LM Studio
  serves on 1234.
- Harness: pi (`~/.pi/agent/models.json`). Pick a server by copy-pasting the
  command block from its report page. Aliases equal the pi model ids.
- The machine file for runs is `~/.config/choose-a-local-llm/machine.md`
  (apps to handle, thresholds, ports, paths). The published values:
  balloon skipped above 25 GB free; wired recovery waited for after any
  server above about 15 GB RSS; idle free memory has read 12415 MB and
  25219 MB with the same apps not running.
- `lms` lives at `~/.cache/lm-studio/bin/lms`, not on `PATH`.
- The per-process firewall silently blocks new binaries' network
  access. Suspect it first for any fresh-process hang (Node.js usually
  passes; Python often does not). See the cold-start sequence in
  [the checklist](../../methodology/checklist.md).
- Docker does not fit beside a loaded model here. Aider polyglot runs
  are driven from another computer against this machine's server.
- Swap arithmetic: the server's RSS is wired, the kernel wires 2 to 3 GB
  more, and all apps share the rest of 32 GB. Whole-machine slowness
  means swap. A slow model on a healthy machine means depth physics.
  Tell them apart before acting, with `vm_stat`, `sysctl vm.swapusage`,
  or the memory probe.

## Runtimes on this machine

Four runtimes are in play. The method rules for them are in
[the methodology](../../methodology.md#runtimes).

- **llama-server** (llama.cpp, brew stable).
- **mlx_lm.server** (mlx-lm, brew).
- **LM Studio via the `lms` CLI**: the GUI-bundled runtime, driven
  CLI-only (`lms get/load/server`); the model store is shared with the
  app. Its engine supports the `gemma4_unified` model type that mlx-lm
  lacks, and implements its attention properly.
- **PrismML llama.cpp fork**: the only backend for ternary GGUFs
  (Q2_g64), q4-KV with calibration, and the DSpark drafter. Side-by-side
  install in `~/prism-llama/` (`prism-llama` alias; `install-latest.sh`
  overwrites with the newest build, one version only). Results are
  labeled with the fork build.

## What the depth sweeps have shown here

MLX runtimes barely creep but hit hard memory ceilings; llama runtimes
creep faster but never OOM inside their window. Speculative decoding
costs depth: the floor arrives shallower with a drafter, so measure
both. The KV cache type can dominate everything else: on Gemma-4-12B,
q8_0 KV falls through the 8 tok/s floor by 16K used tokens while f16 is
still at 13.0 tok/s at 131K, a 3.2x gap at 16K
([the KV cache pick](../../methodology/kv-cache-pick.md)). A published
`-c` is not a window: on every GGUF model the published value OOMs at
load, and the row carries the largest `-c` that serves a real
completion.

### KV cache quantization on this chip

On llama-server, a quantized KV cache costs about 2 to 4 microseconds
per cached token here, against 0.2 to 0.3 for f16, on every model
measured. The penalty therefore grows with depth: Gemma-4-26B-A4B runs
6.3 tok/s at 32K with q8_0 against 45.9 with f16, at almost the same
wired memory. The cause is not the M1. Apple gives this GPU family every
instruction the Metal backend asks for, and MLX runs a quantized cache
on the same chip for a few percent. It is llama.cpp's decode-time
attention kernel, which unpacks each cached value inline and reaches
about 3% of this machine's memory bandwidth where f16 reaches 51%. The
research is in `hardware/m1-max-32gb/research/kv-quant-on-m1.md`.

## Models under test

| model | files | reports |
|---|---|---|
| Qwen3.6-35B-A3B (MoE) | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`; `mlx-community/Qwen3.6-35B-A3B-4bit` | [report](./reports/qwen3.6-35b-a3b.md), [benchmarks](./benchmarks/qwen3.6-35b-a3b.md) |
| Gemma-4-26B-A4B (MoE) | `unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL` + MTP draft; `mlx-community/gemma-4-26b-a4b-it-4bit` | [report](./reports/gemma-4-26b-a4b.md), [benchmarks](./benchmarks/gemma-4-26b-a4b.md) |
| Qwen3.8-27B | `bartowski/Qwen3.8-27B-GGUF:Q4_K_M`; `mlx-community/Qwen3.8-27B-4bit` | [report](./reports/qwen3.8-27b.md), [benchmarks](./benchmarks/qwen3.8-27b.md) |
| Ternary Bonsai-27B | `prism-ml/Ternary-Bonsai-27B-mlx-2bit`; GGUF `Q2_g64` + `PQ2_0` + converted dflash drafter (prism fork only) | [report](./reports/bonsai-27b.md), [benchmarks](./benchmarks/bonsai-27b.md) |
| Gemma-4-12B-it | `unsloth/gemma-4-12b-it-GGUF:Q4_K_XL`; `lmstudio-community/gemma-4-12B-it-MLX-4bit` (LM Studio engine only) | [report](./reports/gemma-4-12b-it.md), [benchmarks](./benchmarks/gemma-4-12b-it.md) |

Thinking controls differ by family. Gemma 4 uses a binary `enable_thinking`,
default off. The Qwen3.6 family, including Bonsai, is binary and defaults on.
Qwen3.8 uses graded effort: `low`, `medium`, `xhigh`. 1-bit Bonsai is out of
scope.

## Current state

As of 2026-09-06.

- Seats: hard problems and agent work go to Qwen3.8 on llama-server at
  f16 KV (`-c 49152`); the secondary and deep seat is Gemma-26B on
  llama-server at f16 KV (`-c 212992`, thinking off for single-turn
  work); all-day and swarm go to Bonsai; Gemma-12B holds the deepest
  window on llama-server, and its LM Studio configuration is single-turn
  work only. Qwen3.6 is the fastest shallow decoder, but its clean depth
  is 8K at the only `-c` that loads.
- Every GGUF row carries the largest `-c` that loads under the 24000
  limit, measured with a real completion, and the KV type the pick
  chose: f16 on Qwen3.8, Gemma-26B and Gemma-12B, q8_0 on Qwen3.6
  because f16 does not load.
- Bonsai extras: the PrismML fork is installed at `~/prism-llama/`. Its
  desktop profile holds q4 KV at 9.8 GB flat with a 30K floor, and serves
  2×48K slots at 9.8 tok/s each. The DSpark drafter helps only at
  shallow context, so it is not used for scoring.
- pi wiring: qwen3.8 llama at a 49152 window, qwen3.6 llama at 49152,
  gemma-26b llama at 212992, bonsai-mlx at 48K, qwen3.8-mlx at 26K;
  `maxTokens` 8192 on every entry.

## Open work

- Mendel at thinking off for Gemma-26B, guided and blind, and guided at
  thinking on. The Qwen3.8 GGUF quant's own EvalPlus score. A
  thinking-on score for Gemma-12B.
- A Bonsai guided row at thinking off, after the runner gets a live
  loop alarm. The bonsai-prism q4 A/B.
- Aider tier 2, driven from another computer. Docker does not fit here.

## Why quality scores needed a correction

EvalPlus's default output cap was too small for a reasoning model: it cut
off mid-thought, and the truncated completion scored as a failure. That
capped every early score to a deflated lower bound. The fix is a budget
calibrated per model from measured reasoning length; every corrected score
went up. Superseded numbers under the old cap live on
[the historical page](./historical.md), never on a current page.

## The wired limit: 24000

Measured on this machine (Qwen3.6-35B MLX, per-process `vmmap` tracking):

- **At about 24000 MB and above, the sysctl stops mattering.** Physical
  RAM binds first: free RAM runs to near zero before the process reaches
  the sysctl, and the crash point no longer responds to sysctl changes
  (25000 and 24000 give the same ceiling). This regime reaches the
  machine's true context maxima, but the near-zero free RAM is what
  locks up the keyboard and causes visual glitches. **24000 is the
  standing value**; anything higher buys nothing.
- **Below about 24000 MB the sysctl gates cleanly.** The model process
  hits the limit, gets a Metal OOM, and dies or rejects the request,
  while macOS keeps gigabytes free and the machine stays responsive.
  The cost is context depth: Qwen3.6-35B MLX caps near 13K at 22000
  instead of about 35K. That trade is not one we make. The lower
  shared-use value is retired; see
  [the historical page](./historical.md).
- Max-context numbers are the point: the laptop runs as a bare model
  server, driven by agents from another machine, with the minimal
  local system.

Every published number states the limit it was measured under, and only
24000 numbers appear on the current site pages. Superseded measurements
move to [the historical page](./historical.md).
