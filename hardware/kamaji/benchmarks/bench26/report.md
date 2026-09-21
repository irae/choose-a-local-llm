# Run 26 — report

The ternary 27B of the second generation on the Mac, 2026-09-19 to
2026-09-21, paused twice by the owner. Two GGUF packings measured to
their clean depth, one EvalPlus score, one smoke, and the MLX pack of
the same model brought from "no route" to a measured speed curve.

The blind agent row of this run was cancelled by the owner and its
evidence removed. It is not pending; it is gone.

## The two GGUF packings

Both served by the PrismML llama.cpp fork, release
`prism-b10685-7dffb15`, Metal build, f16 KV, `-c 262144`, wired limit
25000. The stock binary does not serve either file.

| depth | PTQ1_0 | PQ2_0 |
|--:|--:|--:|
| 4114 | 17.86 | 17.05 |
| 24602 | 16.05 | 12.26 |
| 40982 | 14.71 | 9.50 |
| 65578 | 13.05 | 7.91 |
| 163858 | 9.07 | — |

**The dense packing wins on this machine at every depth, and the gap
widens with depth.** PQ2_0 falls under the 8 tok/s floor between 40982
and 65578; PTQ1_0 is still at 9.07 tok/s at 163858, where it stopped on
swap growth, not on speed. Clean depth 163858 against 40982. The card
reads these two files the other way round: there PQ2_0 is the faster
file. The packing that wins is a property of the machine, not of the
file.

## Quality

EvalPlus on PTQ1_0 at effort xhigh, thinking budget 16056 (the
calibration's longest converged reasoning, 10704, times 1.5; answer
budget 2048, `max_tokens` 18104): **0.988 / 0.939**, no empty answer, 7
forced, 337 minutes of run and 145.9 of calibration. The card scored
the same file at 0.970 / 0.939 under a budget of 30000. The four forced
answers that failed fail again at the 30000 cap, as loops, so the
budget lost no answer.

The smoke passed: the model commits the fixture and does not loop.

## The MLX pack: four routes refused it

The pack is `prism-ml/Ternary-Bonsai-2-27B-mlx-2bit` at `3f926b4`,
8,595,477,990 bytes. Four routes were tried and recorded with their
exact errors:

| route | result |
|---|---|
| stock `mlx_lm.server` 0.31.3 | `Model type prism_hadamard_qwen35 not supported` |
| the pack's own `artifact.py` | `Unsupported packed model schema`; it accepts schema 1, the pack is schema 2 |
| Apple's newest `mlx-lm` | no module for the type |
| LM Studio 0.4.24+1 | `Unrecognized video processor`; the pack carries no `video_preprocessor_config.json` |

The publisher's own demo script loads the pack and answers correctly,
but the publisher ships no MLX server for it. So the run built one:
`tools/sweeps/bonsai2-mlx-server.py`, a thin server around the
publisher's loader and `mlx_vlm.stream_generate`, at the publisher's
pinned versions. It verifies the pack's runtime files against the
publisher's hash manifest, keeps no prompt cache, and changes nothing
on the machine. **A row measured through it is served by it, not by a
stock server**, and the site row says so.

A third-party route (`mlx-vlm` built from main) also worked and was
withdrawn by the owner, with its environment, logs and numbers deleted.
None of its numbers is a result.

## What MLX gives, and what it costs

| depth | MLX 2-bit | PQ2_0 | PTQ1_0 |
|--:|--:|--:|--:|
| 4K | **21.47** | 17.05 | 17.86 |
| 24K | 12.13 | 12.26 | 16.05 |
| 33K | 10.45 | 11.20 | 15.28 |
| 41K | 8.12 (swap) | 9.50 | 14.71 |
| clean depth | 32818 | 40982 | 163858 |

**MLX is the fastest at 4K and the first to run out of memory.** It
leads by 20 percent at the shallow cell, falls behind PQ2_0 by 24K and
behind PTQ1_0 everywhere, and its clean depth is a fifth of the dense
GGUF packing's. Its window is 28672. Part of the deep cost is the
missing prompt cache: every step of the sweep pays the full prefill.

No EvalPlus and no agent row ran on the MLX pack. This run measured its
speed only.

## Limits

The MLX numbers come from a server written in this repository. It is
honest about what it wraps, and the pack's runtime is hash-checked
against the publisher's manifest, but it is not a released product and
no second implementation confirms its timings. Treat the MLX column as
a reading of this pack through this tool.
