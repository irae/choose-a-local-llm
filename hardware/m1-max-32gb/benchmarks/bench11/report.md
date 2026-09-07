# Run 11 — report

The large form of the run's status line. See
`docs/methodology/status-lines.md`, "The site comparison, in full", for
the table rules. Every row of this run ran at
`iogpu.wired_limit_mb=25000`, a trial value the owner set for this run
only; the site's current pages still carry 24000 numbers until the
owner sets the standing value.

Speed and context:

| old/new | Config | Max ctx | Gated by | tok/s (shallow → deep) | Limit |
|---|---|--:|:--:|--:|--:|
| old | Qwen3.6-35B-A3B, GGUF, MTP q8_0, 1 slot | 8k clean at `-c 49152` | mem | 36.4 → 43.8 | 24000 |
| new | Qwen3.6-35B-A3B, GGUF, MTP q8_0, 1 slot | **82k clean at `-c 98304`** | **speed** | **36.5 → 9.24** | 25000 |
| old | Qwen3.6-35B-A3B, GGUF, MTP f16 | does not load | — | — | 24000 |
| new | Qwen3.6-35B-A3B, GGUF, MTP f16 | **loads at `-c 40960`**, no ceiling found | window | 69.3 warmup | 25000 |
| old | Qwen3.6-35B-A3B, MLX 4-bit | 37k | mem | — | 24000 |
| new | Qwen3.6-35B-A3B, MLX 4-bit | **41k** | **mem (thread death)** | **37.4 at 41k** | 25000 |

Mendel:

| old/new | test | model | serving | score | libraries |
|---|---|---|---|--:|---|
| new | guided, off | qwen3.6-35b-a3b GGUF q8_0, window 81920 | llama-server | **62.5/100** | 8/8 |
| old | guided, off | qwen3.6-35b-a3b GGUF q8_0, window 49152 | llama-server | 46.5/100 | 8/8 |
| new | guided, on | gemma-4-26b-a4b GGUF f16 `-c 212992` | llama-server | **57/100** | 7/8 |
| new | guided, high | bonsai-prism fork q4 KV `-c 65536` | prism fork | **31.5/100** | 3/8, wall clock |
| new | guided, off | gemma-4-26b-a4b GGUF f16 | llama-server | 25/100 (raw 44) | 2/8, invalid |
| new | blind, off | gemma-4-26b-a4b GGUF f16 | llama-server | 12.5/100 (raw 21) | 1/8, invalid |
| new | blind, off | gemma-4-12b GGUF f16 `-c 262144` | llama-server | 0/100 (raw 2) | 0/8, invalid |

Gates:

| gate | model | config | result | verdict |
|---|---|---|---|---|
| clean depth ≥ 46K at ≥ 8 tok/s | qwen3.6-35b-a3b | GGUF q8_0, `-c 98304` | 81958 at 9.24 tok/s | pass, the Mendel pair ran |
| pi entry exists | qwen3.6-35b-a3b MLX | mlx_lm.server | no entry | blocks 6 and 7 skipped |
| mendel smoke | qwen3.6-35b-a3b | GGUF q8_0, off | pass | on to the Mendel pair |

## What the run established

- **The harness window decides the score, not only the model.** The
  same model, the same config and the same prompt scored 46.5 on a
  49152-token window and 62.5 on the 81920-token window its own creep
  supports. The first row compacted twelve times; the second did not
  need to. Every measured parameter now comes from the newest
  measurement at run time (`docs/methodology/common-rules.md`, rule
  10), because this run froze a window its own first block had
  already outdated.
- **Qwen3.6 GGUF is not an 8K model.** Run 9 measured 8K clean depth
  at the only `-c` that loaded under the old limit. At 25000 the same
  build serves `-c 98304` and creeps to 81958 tokens before the speed
  floor. The ceiling is sharp: 98304 serves a real completion and
  100864 loads but fails the first one.
- **Thinking off is where Gemma-26B breaks.** Both thinking-off rows,
  guided and blind, ended on five identical edit calls. Its
  thinking-on guided row completed 7 of 8 the same night. The live
  loop stop caught both in under half an hour each; before this run
  they would have burned a night.
- **Gemma-12B GGUF cannot drive the agent task.** 24 of 28 edit calls
  carried the same malformed tool shape, the model never adapted, and
  the run ended with zero commits. This is a tool-schema failure, not
  a loop of the kind the stop rule catches.
- **A background macOS service can end a run.** The media analysis
  daemon drove free memory from 1.5 GB to under 100 MB while the
  server held 25 GB wired, and the harness killed two attempts of two
  different blocks. Nothing on the GPU side prevents it
  (`docs/setups/m1-max-32gb/index.md`, "Background services and free
  memory").
- **The wall clock cap was not a stop.** Block 8 ran 469 minutes
  because the abort at 300 minutes never settled the turn. The runner
  now kills pi five minutes after an ignored abort and ends the run as
  `wall_clock`.

## What the run cost

Two attempts of block 5 and one of block 9 were killed by the memory
incident; one of them held 8 of 8 commits and its branch was deleted
before scoring, so that work is gone. Blocks 6 and 7 did not run for
a missing harness entry the runner was not allowed to create. Block 10
overflows to run 12. The rules that came out of all three are in
`AGENTS.md`, `docs/methodology/mendel.md` and
`docs/methodology/checklist.md`.
