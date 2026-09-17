# Run 24 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `budget_message` | `Thinking budget reached. Give the final answer now.` | runbook, Essentials |
| `THINKING_BUDGET_MARGIN` | 1.5 | runbook, planning value |
| `vram_cap_mb` | 13811 | owner, 2026-09-17, 2.5 GB free of 16311 MiB |
| `serving_c` | 65536 | owner, 2026-09-17, fixed |
| `oblit_q4km_ngl` | pending | `qwen38-oblit-q4km-offload-ladder` |
| `oblit_q4km_clean` | pending | `sweep-qwen38-oblit-q4km` |
| `oblit_q4km_window` | pending | `qwen38-oblit-q4km-smoke-medium` |
| `oblit_q4km_think_budget` | pending | `qwen38-oblit-q4km-calibrate-think` |
| `oblit_q4km_answer_budget` | pending | `qwen38-oblit-q4km-calibrate-think` |
| `oblit_q4km_max_tokens` | pending | `qwen38-oblit-q4km-calibrate-think` |
| `runwatch_silence` | pending | runner, raised for a slow offload server |
| `vram_start_mb` | pending | `nvidia-smi`, session start |
| `evalplus_python` | pending | pipx venv |
| `llama_server` | pending | run 17 build |

Planning estimate, not a result: 16040 MiB of weights, 2176 MiB of KV
at 65536 tokens at q8_0, about 200 MiB of linear-attention state, about
600 MiB of compute buffers, against the cap of 13811 MiB, which gives
`-ngl 43` of 64 as the first load of the ladder.

## Why this run exists

Run 23 aborts at its context gate when no cache type holds 32768
tokens on the Q3_K_M build. Copy its two ladder values and its abort
line here in `machine-setup`. The run has not started.

## Handing-over

The run has not started.
