# Run 16 — report

The large form of the run's status line. See
`docs/methodology/status-lines.md`, "The site comparison, in full", for
the table rules. Wired 25000 on every block. Every row of the
homepage whose speed was not a real-text reading was read with
`llama-benchy` at two or three depths; the drafter rows climbed the
draft depth from no drafter up; the Qwen3.6 MLX build met the agent
task; the Gemma-26B MLX build failed its smoke and is retired. The
owner ended the run after the homepage cells (2026-09-13); the blocks
that never ran stay in the runbook as the plan they were.

Speed and context, the served arm of every row read:

| old/new | Config | Ctx | Cap | tok/s (shallow → deep) |
|---|---|--:|:--:|--:|
| old (creep) | Qwen3.8-27B AtomicChat AD-IQ3_S, drafter n-max 3 | 104k | mem | 15.8 → 10.3 |
| new (benchy) | Qwen3.8-27B AtomicChat AD-IQ3_S, **no drafter** | 104k | mem | 14.3 → 9.6 |
| old (benchy, run 14) | Qwen3.8-27B bartowski Q4_K_M, drafter n-max 3 | 72k | mem | 11.8 → 8.6 |
| new (benchy) | Qwen3.8-27B bartowski Q4_K_M, **no drafter** | 72k | mem | 12.4 → 9.7 |
| old (creep) | Qwen3.8-27B ISTA IQ3_S-mtp, no drafter | 147k | speed | 14.1 → 8.3 |
| new (benchy) | same | 147k | speed | 14.1 → 8.1 |
| old (creep) | Gemma-4-26B-A4B GGUF, drafter n-max 2 | 197k | mem | 60.3 → 17.3 |
| new (benchy) | same, n-max 2 stays | 197k | mem | 60.1 → 19.1 |
| old (creep) | Gemma-4-12B GGUF f16, no drafter | 245k | mem | 24.64 → 8.86 |
| new (benchy) | same | 245k | mem | 25.0 → 9.2 |
| old (creep) | Qwen3.6-35B-A3B MLX 4-bit | 41k | mem | 55.1 → 37.4 |
| new (benchy) | same, at the 36864 window | 37k | mem | 54.5 → 39.1 |
| old (creep) | Gemma-4-26B-A4B MLX 4-bit | 70k | mem | 51 → 12.8 |
| new (benchy) | same, at the 65536 window, retired | 66k | mem | 49.3 → 23.4 |
| old (creep) | Qwen3.8-27B MLX 4-bit | 28k | mem | 17 → 15.3 |
| new (benchy) | same, at the 24576 window | 25k | mem | 17.3 → 14.8 |
| old (creep) | Ternary-Bonsai-27B prism fork, q4_0 KV with bias | 33k | speed | 14.8 → 7.9 |
| new (benchy) | same | 33k | speed | 14.7 → 7.8 |
| old (creep) | Ternary-Bonsai-27B MLX 2-bit | 58k | mem | 24.5 → 17.3 |
| new | same: no benchy cell survived, window 40960 by the MLX rule | 40k | mem | 24.5† → 17.3† |

Draft-depth climbs, real text, the served arm in bold:

| build | no drafter | n-max 1 | n-max 2 | n-max 3 |
|---|--:|--:|--:|--:|
| Qwen3.8-27B AtomicChat, 4K / 98K | **14.3 / 9.6** | 12.2 / 8.8 | not read | 8.1 / 7.4 |
| Qwen3.8-27B bartowski, 4K / 65K | **12.4 / 9.7** | 10.7 / 8.3 | not read | 11.8 / 8.6 |
| Gemma-4-26B-A4B GGUF, 4K / 98K / 197K | 54.2 / 28.7 / 19.2 | 58.2 / 27.5 / 16.4 | **60.1 / 28.2 / 19.1** | 50.8 / 25.7 / 22.3 |

Mendel:

| old/new | test | model | serving | thinking | window | score | libraries |
|---|---|---|---|---|--:|--:|---|
| new | blind | Qwen3.6-35B-A3B MLX 4-bit | mlx_lm.server | on | 36864 | 25/100, first row, a foreign stash popped from the shared stack | 2/8 |
| new | blind | Qwen3.6-35B-A3B MLX 4-bit | mlx_lm.server | on | 36864 | **37.5/100**, re-run without penalty, raw 51.5 | 3/8, model nudge budget spent |
| new | smoke | Gemma-4-26B-A4B MLX 4-bit | mlx_lm.server | high | 65536 | fail: a tool call truncated mid-generation, zero commits | build retired |

Gates:

| gate | block | result | verdict |
|---|---|---|---|
| Qwen3.6 MLX window | `sweep-qwen36-mlx` | the deep cell at 39936 died above the window | 36864 stands, the smoke passed there |
| Gemma-26B MLX window | `sweep-gemma26-mlx` | both cells served | 65536 stands |
| first Qwen3.6 MLX agent row | `qwen36-mlx-mendel-blind-on` | a `git stash pop` took an older run's stash from the shared stack | benchmark fault, re-run without penalty; `git stash clear` before every agent run is now a rule |
| Gemma-26B climb | `arms-gemma26` | n-max 2 beat n-max 1 at every depth | the climb rule now goes on after a mixed arm when the next arm wins everywhere |
| prism fork bias file | `sweep-bonsai-fork-single` | the runbook and the site pointed at a `/tmp` path; the file has lived under the persistent directory since bench 11 | nothing of a run goes under `/tmp` is now a rule |
| Bonsai MLX deep cell | `sweep-bonsai-mlx` | died at 56320 and again at 52224, the fill stalled near 47K | ceiling near 47K, window 40960, cells stay daggered |

## What the run established

- **The MTP drafter loses on the dense Qwen3.8 builds on real text
  and pays on the Gemma-26B MoE.** AtomicChat and bartowski read
  faster with no drafter at every depth and at every draft depth
  read; the AtomicChat row at n-max 3 sat under the 8 tok/s floor at
  98K and clears it without the drafter. Gemma-26B keeps n-max 2, the
  fastest arm at 4K and level with no drafter at depth.
- **A no-drafter row reads the same by creep and by benchy**, within
  four percent on ISTA, Gemma-12B, Qwen3.8 MLX and the prism fork.
  The dagger rule was right to mark them and cheap to clear.
- **The MLX servers hold their speed at depth better than the creeps
  said.** Qwen3.6 MLX reads 39.1 at 35840 and Gemma-26B MLX 23.4 at
  65536, against creep cells of 37.4 and 12.8 near their ceilings.
  The Gemma-26B creep had alternated between 13 and 24 tok/s from
  60K up; the fast state is the one benchy found.
- **The MLX 5 percent window rule held once and failed once.**
  Qwen3.6 MLX served its smoke and two agent rows at 36864 with no
  death. Bonsai MLX died twice under its 53248 window, with the fill
  stalled near 47K: the 2026-08-29 creep's 58K was not a ceiling this
  machine serves today, and the window is now 40960.
- **The Qwen3.6 MLX build scores 37.5 on the agent task, capped at 3
  of 8**, on a 36864 window with one compaction, level with the
  Bonsai MLX and AtomicChat partials and far under the GGUF q8_0 row's
  63 on an 82K window. The window is the difference the runtime
  makes.
- **The Gemma-26B MLX build is retired**: its smoke ended on a tool
  call the server truncated mid-generation, with no OOM and no death,
  while the GGUF build of the same model completes the task. Its
  EvalPlus at thinking on had already read 28 percent empty.

## What the run cost

Eighteen blocks over about thirty hours, ending on the owner's word
with ten planned blocks unrun. Four coordinator faults, each now a
rule: a dead benchy cell above a window was written as a reason to
step the window down; a recoverable dead cell went to the end-of-run
sweep and the agent row that depended on it ran a day on a stale
cell; the climb rule stopped one arm early after a mixed result; the
runbook pointed at a bias file under `/tmp`. One benchmark fault, the
shared stash stack, cost a re-run. One runner finding for the server
lore: a dead MLX generation thread leaves the process alive, so a
process monitor alone misses it, and `llama-benchy` loses every cell
of a call when one dies.
