# This machine — M1 Max, 32 GB

## Highlights

- **Wired limit: 25000 MB, resets on reboot.** Re-run the sysctl before
  any model work. This machine is a model server, not a workstation,
  while it serves the models under test: a run drives free memory to
  near zero and the desktop stops responding. We do not consider a
  shared-use setting; drive the models from another machine.
- **Every model has a depth curve, a KV pick and an EvalPlus score.**
  The decode-vs-used-context table on the
  [comparison page](./comparison.md) is this project's main artifact.
- **Two local models finish the agent task.** Qwen3.8 on llama-server
  at f16 KV scores 80.5 of 100 blind at the model's own default level,
  on its ISTA 3-bit build served without a drafter; Gemma-26B scores
  47.5. Both complete.
- **The rule:** MLX barely slows down but OOMs hard; llama holds its
  speed deeper at f16 KV, and its ceiling is the largest `-c` that
  loads.

## Setup

```bash
sudo sysctl iogpu.wired_limit_mb=25000
```

**This resets on reboot.** Re-run it before any model work. See
[the wired limit](#the-wired-limit-25000).

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

Three runtimes are in play, and one is retired. The method rules for
them are in [the methodology](../../methodology.md#runtimes).

- **llama-server** (llama.cpp, brew stable).
- **mlx_lm.server** (mlx-lm, brew).
- **LM Studio via the `lms` CLI**: retired 2026-09-07. Its engine is
  the only one that loads the `gemma4_unified` model type, and it gave
  the fastest Gemma-12B curve here, but no agent run on it ever
  produced a commit and its context window cannot be pinned.
  [The full record](./lmstudio-retired.md).
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

As of 2026-09-11.

- Candidates for real coding use, by what the measurements support:
  Qwen3.8 on llama-server at f16 KV is the only local model that
  finishes the agent task at its own default level, on two rows: the
  4-bit build with its drafter at `-c 73728` scored 93, the ISTA 3-bit
  build without a drafter at `-c 163840` scored 80.5, one run each and
  not yet ordered; Gemma-26B on llama-server at f16 KV
  (`-c 212992`) is the deep-context candidate and the fastest of the
  large models; Bonsai is the cheapest in memory, the only one that
  serves two slots under 11 GB, and at f16 KV on the fork it has no
  speed floor to 131K; Gemma-12B holds the deepest window on
  llama-server and two 82K slots in 13.8 GB. Nothing here is a
  decision; none of these has been used for real work yet. Qwen3.6 is
  the fastest decoder at depth, 38.3 tok/s at 40K with f16 KV and no
  drafter on real text, and its q8_0 arm holds an 82K window at 13.0.
- Every GGUF row carries the largest `-c` that serves a real request of
  the size the work will send, and the KV type the pick chose: f16 on
  every model. On Qwen3.6 the q8_0 row stays for its window, more than
  twice the f16 arm's, at 2.8x the cost in speed at 33K.
- The drafter is measured per build, on real text at the server's
  sampling, never assumed. On the Qwen3.8 ISTA build it loses at every
  depth and is off. On Qwen3.6 q8_0 it reads above the creep at every
  depth and stays on. On the 4-bit Qwen3.8 it reads 11.8 shallow and
  8.6 at 65.5K with the drafter, under the ISTA build without one; its
  no-drafter arm is unread, so the row keeps the drafter for now.
- Bonsai extras: the PrismML fork is installed at `~/prism-llama/`. Its
  desktop profile holds q4 KV at 9.8 GB flat with a 33K floor, and serves
  2×48K slots at 9.8 tok/s each. The DSpark drafter helps only at
  shallow context, so it is not used for scoring.
- pi wiring, generated from the site data: qwen3.8-27b-ista llama at
  147456, qwen3.8-27b llama at 65536, qwen3.6-35b-a3b llama at 81920,
  gemma-4-26b-a4b llama at 212992, gemma-4-12b llama at 262144 and
  gemma-4-12b-2x at 81920, bonsai-prism-f16 at 131072, bonsai-mlx at
  57344, qwen3.8-mlx at 26624; `maxTokens` 8192 on every entry.

## Latest benchmark runs, 2026-09-08 to 2026-09-11

Every number here was measured at wired limit 25000, the standing
value. Raw evidence: `hardware/m1-max-32gb/benchmarks/bench12/` to
`bench14/` in the repo.

- Three GGUF drafter rows were read with `llama-benchy` on real code
  text at the server's own sampling, with draft acceptance beside
  every cell. A creep on a drafter row reads a ceiling, because its
  text lets the drafter accept every draft. Qwen3.6 q8_0 with its
  drafter reads 43.7 at 4K and 13.0 at 82K, above the creep; the
  Qwen3.6 f16 arm without its drafter 49.8 and 38.3 at 40K; the 4-bit
  Qwen3.8 with its drafter 11.8 and 8.6 at 65.5K, 40 percent under
  the creep. The 4-bit Qwen3.8 at effort xhigh scored 93 on the agent
  task, complete, the best local row; Qwen3.6 at thinking off scored
  50.5 blind.
- The three Qwen3.8 3-bit builds got their own EvalPlus scores at
  effort medium: ISTA 0.976 / 0.945 with one empty, AtomicChat 0.988 /
  0.927 with none. The 4-bit control, re-measured at 25000, serves
  `-c 73728` and creeps clean to 65578; re-run on the agent task at the
  8192 reserve it scored 76 and failed trap A, below its published 87
  at the old reserve. The ISTA build tied it at 76.5; AtomicChat ended
  on a repetition loop after three libraries.
- **Every one of those rows ran at effort medium, inherited from the
  control row and never chosen.** Medium is no longer run on Qwen3.8; a
  model's first run uses its own published default. The rows keep
  their numbers and get no re-run.
- The ISTA build was then measured at its default. A five-cell drafter
  sweep at two depths put no drafter ahead on speed every time, so the
  row is served without one: `-c 163840`, clean to 147478 at 8.30
  tok/s, speed-gated, zero swap. On the agent task at effort xhigh it
  scored 80.5, complete, in 109 minutes; at effort low 66, partial,
  in 163 minutes and more of the window. Both rows record temperature
  1.0 and top_p 0.95, the first rows on this machine with sampling
  recorded. Its EvalPlus at effort low reads 0.976 / 0.933 / 99%,
  level with its medium row on base; at xhigh 0.945 / 0.921 / 97%,
  with five completions that never converged inside a 30000-token cap.
  The level that wins the agent task loses the single-turn gate.
- Gemma-12B on two slots at f16 KV with no drafter holds 82K per slot
  in 13.8 GB, and no `-c` moves that: a larger allocation loads and
  stops on swap at the same depth. Judged by the creep, never by a
  short completion at load.
- The Bonsai fork at f16 KV has no speed floor inside `-c 131072`, 9.67
  tok/s there in 18.3 GB; at q4_0 KV it floors at 33K. Its guided
  agent row at f16 finished one library.
- Two scoring-tool gaps were found and filed, not fixed mid-run: the
  scorer reported trap A as passed while its own captured output said
  the repro threw, and the offline loop check diluted a five-call
  repetition that the live detector caught.

## Open work

- A second Mendel run of the two local leaders at effort xhigh, the
  4-bit and the ISTA Qwen3.8, to order them; the Qwen3.6 f16 arm
  without its drafter on the agent task. The 4-bit Qwen3.8 GGUF's own
  EvalPlus score.
- Qwen3.6 on the MLX server, blind and guided: it has no agent row at
  all.
- A thinking-on EvalPlus score for Gemma-12B. The Bonsai fork's
  EvalPlus at f16 KV.
- A Bonsai guided row at thinking off. The bonsai-prism q4 A/B.
- Aider tier 2, driven from another computer. Docker does not fit here.
- A benchmark user account that starves the media indexing daemon
  (below).

## Background services and free memory

During a run the GPU wires about 25 GB and the rest of the machine
lives in what is left. On 2026-09-06 the macOS media analysis daemon
(`mediaanalysisd` and its access helper) woke up during a Mendel run,
climbed to 70 to 94 percent CPU with growing memory, and pushed free
RAM from about 1.5 GB to under 100 MB in twenty seconds. The harness's
low-memory protection killed the server and the worker mid-run, and
a clean retry died the same way; free RAM kept falling with nothing
of ours running. Two attempts were lost. The daemon indexes the
user's Photos library, Live Text and Visual Look Up; killing it does
nothing, macOS respawns it, and disabling it needs System Integrity
Protection off, which is not an option here.

The fix is preparation, never coercion mid-run:

- **Proposed: a benchmark user account.** No Photos library, no iCloud
  account, Siri Suggestions off, Spotlight indexing excluded from the
  model and repo folders. The daemon exists in that user's session
  but has nothing to analyze. Runs happen as that user; the owner's
  account keeps its services.
- Until then, preflight should report the daemon as a `fix` line when
  it runs, and check a free-RAM floor before a block starts, because
  free RAM and not wired memory is what this event exhausted.
- A run killed this way keeps its worktree and branch until the
  coordinator scores what is there
  ([Mendel](../../methodology/mendel.md), "No cleanup mid-run").

## Why quality scores needed a correction

EvalPlus's default output cap was too small for a reasoning model: it cut
off mid-thought, and the truncated completion scored as a failure. That
capped every early score to a deflated lower bound. The fix is a budget
calibrated per model from measured reasoning length; every corrected score
went up. Superseded numbers under the old cap live on
[the historical page](./historical.md), never on a current page.

## The wired limit: 25000

**Settled 2026-09-08: 25000 stands.** On 2026-09-07 the value was set
back to 24000 after swap growth at 25000, and the same day's follow-up
showed where that growth came from: several sweeps stacked on one
long-lived server with no recovery gap. Every single-sweep creep on a
fresh server at 25000, on both KV types of the same model, came back
with zero swap growth, and two full benchmark runs then held 25000
with no panic, no lockup and no swap on any fresh-server creep. The
extra 1000 MB bought Qwen3.6 its 98304-token q8_0 window against 40960,
and the Qwen3.8 ISTA build its 163840 against 131072. Rows measured at
24000 before 2026-09-06 keep their numbers and say so in their config
notes until a re-measurement lands.

Measured on this machine (Qwen3.6-35B MLX, per-process `vmmap` tracking):

- **At about 24000 MB and above, the sysctl stops being the first
  limit.** Physical RAM binds first: free RAM runs to near zero before
  the process reaches the sysctl, and an MLX server's crash point moves
  little between 24000 and 25000. This regime reaches the machine's
  true context maxima, but the near-zero free RAM is what locks up the
  keyboard and causes visual glitches. A llama-server allocation does
  respond to the extra 1000 MB, which is where the larger windows above
  come from. **25000 is the standing value.**
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

Every published number states the limit it was measured under. A row
measured at 24000 stays on the current pages, labeled, until the same
config is re-measured at 25000; a row replaced by a re-measurement
moves to [the historical page](./historical.md).
