# This machine — M1 Max, 32 GB

## Highlights

- **Wired limit: 24000 MB for unattended runs, 22000 MB when the machine is
  in use.** It resets on reboot. Re-run the sysctl before any model work.
- **Depth sweeps are complete** for every model and every runtime. The
  decode-vs-used-context table on the [comparison page](./comparison.md) is
  this project's main artifact.
- **Four models have fair quality scores.** Qwen3.8 at 0.982/0.939,
  Qwen3.6 at 0.939/0.921, Bonsai at 0.915/0.884, and Gemma-26B at
  0.713/0.701 (its thinking mode converges only ~72% of the time). Gemma-12B
  is still unscored.
- **Four runtimes are in play**, not one: llama-server, mlx_lm.server, LM
  Studio's engine, and the PrismML llama.cpp fork.
- **The law:** MLX barely slows down but OOMs hard; llama slows down faster
  but never OOMs inside its window.

## Setup

```bash
sudo sysctl iogpu.wired_limit_mb=24000
```

**This resets on reboot.** Re-run it before any model work. Set 22000
instead when you also use the machine — see
[the wired limit](#the-wired-limit-24000-unattended-22000-in-use).

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
- Swap arithmetic: the server's RSS is wired, the kernel wires ~2-3 GB more,
  and all apps share the rest of 32 GB. Whole-machine slowness means swap. A
  slow model on a healthy machine means depth physics. Tell them apart before
  acting, with `vm_stat`, `sysctl vm.swapusage`, or the memory probe.

## Runtimes on this machine

Four runtimes are in play. The method rules for them are in
[the methodology](../../methodology.md#runtimes).

- **llama-server** (llama.cpp, brew stable).
- **mlx_lm.server** (mlx-lm, brew).
- **LM Studio via the `lms` CLI** — the GUI-bundled runtime, driven
  CLI-only (`lms get/load/server`); the model store is shared with the
  app. Its engine supports the `gemma4_unified` model type that mlx-lm
  lacks, and implements its attention properly.
- **PrismML llama.cpp fork** — the only backend for ternary GGUFs
  (Q2_g64), q4-KV with calibration, and the DSpark drafter. Side-by-side
  install in `~/prism-llama/` (`prism-llama` alias; `install-latest.sh`
  overwrites with the newest build — one version only). Results are
  labeled with the fork build.

## What the depth sweeps have shown here

MLX runtimes barely creep but hit hard memory ceilings; llama runtimes
creep faster but never OOM inside their window. Speculative decoding
costs depth: the floor arrives shallower with a drafter, so measure
both. The two fastest depth curves measured are MoE on MLX. The KV
cache type can dominate everything else: on Gemma-4-12B, q8_0 KV falls
through the 8 tok/s floor by 16K used tokens while f16 is still at 13.0
tok/s at 131K, a 3.2x gap at 16K
([the KV cache pick](../../methodology/kv-cache-pick.md)).

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

As of 2026-08-29, after the slow-creep re-test.

- Best curves: Gemma-12B on llama-server with f16 KV reaches its own 245K
  window at 8.9 tok/s in 13.9 GB, and on LM Studio it is the flattest
  curve on the machine to a 131K memory ceiling; Gemma-26B MLX runs
  51→12.8 to a 70K ceiling in 20.0 GB; Qwen3.6 llama never floors inside
  96K; Qwen3.6 MLX holds 42 tok/s at 33K.
- Fair EvalPlus scores: Qwen3.8-mlx-medium **0.982/0.939**,
  Qwen3.6-llama-think **0.939/0.921**, Bonsai-mlx-f16 **0.915/0.884**,
  Gemma-26B-mlx-think **0.713/0.701** (46/164 empty — its thinking mode
  converges only ~72% of the time), Gemma-12B-mlx-off **0.909/0.872**
  (all 164 answered). Gemma-12B has no thinking-on score today, and its
  GGUF quant has not been scored on its own.
- Bonsai extras: the PrismML fork is installed at `~/prism-llama/`. Its
  desktop profile holds q4 KV at 9.8 GB flat with a ~30K floor, and serves
  2×48K slots at 9.8 tok/s each concurrently — 3×48K gives 7.6 each. The
  DSpark drafter is converted and measured; it helps only at shallow context,
  so it is not used for scoring.
- pi wiring today: qwen3.8-mlx at a 26K window, bonsai-mlx at 48K, qwen3.6
  llama at 96K, gemma-26b llama at 256K with q8. Pending decisions: the
  bonsai-prism entry, and the main-agent seat now that Gemma-26B's score
  (0.713/0.701, 28% empty) is in.
- Seat sketch: main and deep go to Gemma-26B MLX or Qwen3.6; hard problems
  go to Qwen3.8-MLX at 26K; all-day and swarm go to Bonsai. Gemma-12B holds
  the deepest window on llama-server; its LM Studio configuration is
  single-turn work only.

## Open work

- Gemma-12B on the GGUF quant: its own EvalPlus score, a thinking-on
  score, and an agentic run on llama-server. The bonsai-prism q4 A/B and
  a Bonsai thinking-off pass. Each block waits for a go-ahead.
- Ceiling brackets for the MLX configs that never floored.
- Aider tier 2, driven from another computer. Docker does not fit here.
- Watch list and owner context: `HANDOFF.md`, not committed.

## Why quality scores needed a correction

EvalPlus's default output cap was too small for a reasoning model: it cut
off mid-thought, and the truncated completion scored as a failure. That
capped every early score to a deflated lower bound. The fix is a budget
calibrated per model from measured reasoning length; every corrected score
went up. Superseded numbers under the old cap live on
[the historical page](./historical.md), never on a current page.

## The wired limit: 24000 unattended, 22000 in use

Measured on this machine (Qwen3.6-35B MLX, per-process `vmmap` tracking):

- **At ~24000 MB and above, the sysctl stops mattering.** Physical RAM
  binds first: free RAM runs to near zero before the process reaches the
  sysctl, and the crash point no longer responds to sysctl changes
  (25000 and 24000 give the same ceiling). This regime reaches the
  machine's true context maxima, but the near-zero free RAM is what
  locks up the keyboard and causes visual glitches. Use it only for
  unattended runs. **24000 is the standing value for those** — anything
  higher buys nothing.
- **Below ~24000 MB the sysctl gates cleanly.** The model process hits
  the limit, gets a Metal OOM, and dies or rejects the request — while
  macOS keeps gigabytes free and the machine stays responsive. **22000
  is the standing value when the machine is in use.** The cost is
  context depth: Qwen3.6-35B MLX caps near 13K instead of ~35K.
- Max-context numbers matter even though they cost usability: the
  laptop can run as a bare model server, driven by agents from another
  machine, with the minimal local system.

Every published number states the limit it was measured under, and only
24000 numbers appear on the current site pages. Superseded measurements
move to [the historical page](./historical.md).
