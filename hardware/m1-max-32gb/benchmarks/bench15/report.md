# Run 15 — report

The large form of the run's status line. See
`docs/methodology/status-lines.md`, "The site comparison, in full", for
the table rules. Wired 25000 on every block. The Qwen3.6 f16 arm
without its drafter measured and scored; two vision servers loaded
with their projector and read with benchy; the 4-bit Qwen3.8 scored
on EvalPlus at its own default level.

Speed and context:

| old/new | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory |
|---|---|--:|:--:|--:|--:|
| old (benchy, run 14) | Qwen3.6-35B-A3B, GGUF, no drafter, f16 KV | 41k | mem (inherited from the drafter arm) | 49.8 → 38.3 | 24.0 GB |
| new | Qwen3.6-35B-A3B, GGUF, no drafter, f16 KV | **66k** | **untested** | 50.5 → **33.6** | 25.0 GB |
| new | Qwen3.6-35B-A3B, GGUF, no drafter, f16 KV, projector loaded | 66k | mem | 48.8 → 33.1 (benchy) | 25.7 GB |
| new | Qwen3.6-35B-A3B, GGUF, drafter n-max 1, f16 KV, projector loaded | 66k | mem | 53.9 → 33.9 (benchy) | 25.6 GB |
| new | Gemma-4-26B-A4B, GGUF, no drafter, f16 KV, projector loaded, ubatch 2048 | 205k | mem | 53.1 → 19.2 (benchy) | 26.6 GB |

Quality:

| old/new | model | config scored | pass@1 base | pass@1 plus | completion | status |
|---|---|---|--:|--:|--:|---|
| old (bench13) | Qwen3.8-27B | ISTA IQ3_S-mtp, no drafter, f16 KV, effort xhigh, budget 30000 | 0.945 | 0.921 | 97% | 5 empty, 9h43 |
| new | Qwen3.8-27B | Q4_K_M bartowski, MTP n-max 3, f16 KV, effort xhigh, budget 30000 | **0.957** | **0.939** | 96% | 6 empty, all at the cap, 8h30 |

Mendel:

| old/new | test | model | serving | thinking | max ctx | score | libraries |
|---|---|---|---|---|--:|--:|---|
| old (bench14) | blind | Qwen3.6-35B-A3B, MTP n-max 3, q8_0 KV | llama-server | off | 82k | 50.5/100 | 8/8 |
| new | blind | Qwen3.6-35B-A3B, no drafter, f16 KV | llama-server | on | 66k | **50/100** | 8/8, critical, 2 compactions, 33 min |

Gates:

| gate | block | result | verdict |
|---|---|---|---|
| ladder, f16 no drafter | `qwen36-f16-ladder-creep` | `-c 65536` serves, list end | window 65536 |
| vision `-c`, first probe | `vision-ladder` | both served at the text `-c` | 65536 and 204800 |
| vision `-c`, one step up | `vision-ladder-up` | both fail the request out of memory | unchanged |
| drafter arm with the projector | `vision-drafter-shallow` | Qwen3.6 n-max 1 works, 2 and 3 OOM; Gemma-26B none | n-max 1; none |
| EvalPlus budget at xhigh | `bartowski-evalplus-xhigh` | 2 of 10 calibration problems at the cap | budget 30000 |

## What the run established

- **The 4-bit Qwen3.8 at its own default is complete and leads.**
  EvalPlus 0.957 / 0.939 at xhigh, above the ISTA build's 0.945 /
  0.921 at the same level, with 93 on the agent task: the highest
  composite of any local row, and the first 4-bit row with its own
  EvalPlus score.
- **The cap is the whole xhigh gap.** All six empties ran to the
  30000-token budget; the same shape as the ISTA row's five. The
  served score reads the budget this machine can wait for, not the
  model's ceiling.
- **Dropping the drafter buys Qwen3.6 f16 a 60 percent larger
  window.** `-c 65536` serves and creeps clean to 65578 at 33.6
  tok/s with no ceiling found; the drafter arm loads only 40960. On
  the agent task the arm scored 50 at thinking on, level with the
  q8_0 arm at thinking off and below its 63 at thinking on: the
  smaller window compacted twice.
- **Vision fits, at the text `-c`, for 7005 tokens a page.** Both
  Qwen3.6 f16 and Gemma-26B serve a page image at their full text
  `-c` and fail one step up. A 1400-pixel page costs 7005 prompt
  tokens on both. Decode with the projector loaded matches the text
  rows within 3 percent at every benchy depth.
- **The Qwen3.6 drafter works beside the projector at n-max 1**,
  against the model card, and reads faster than no drafter at every
  depth on real text at 78 to 94 percent acceptance; n-max 2 and
  above run out of memory. Gemma-26B has no room for any drafter
  beside its projector at 204800 and needs `--ubatch-size 2048` to
  prefill an image.
- **Wired memory reads above the 25000 limit with a projector
  loaded**, 25.7 GB on Qwen3.6 and 26.6 GB on Gemma-26B, with no
  swap growth on any benchy arm.

## What the run cost

Seven blocks, about nineteen hours of GPU time, none retried. The
calibration client was killed four times by the runner session's own
memory guard during the xhigh calibration and resumed each time from
its own file with nothing lost; the server never fell. The runner
sent no block-close messages for the first three blocks and caught
up on request; the reporting rule is now in `AGENTS.md`. Three
runbook gaps on the coordinator's side: `textutil` cannot write PDF
on that machine (QuickLook thumbnails the RTF instead), the benchy
example showed comma-joined depths where the tool wants spaces, and
the watcher's silence window was left at 600 s for an xhigh EvalPlus
block until corrected to 2700.
