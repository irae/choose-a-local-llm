# Run 23 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `budget_message` | `Thinking budget reached. Give the final answer now.` | runbook, Essentials |
| `THINKING_BUDGET_MARGIN` | 1.5 | runbook, planning value |
| `oblit_q3km_c_q8` | pending | `qwen38-oblit-q3km-kvpick` |
| `oblit_q3km_c_f16` | pending | `qwen38-oblit-q3km-kvpick` |
| `oblit_q3km_c` | pending | `qwen38-oblit-q3km-kvpick`, the larger of the two |
| `oblit_q3km_kv` | pending | `qwen38-oblit-q3km-kvpick` |
| `oblit_q3km_clean` | pending | `sweep-qwen38-oblit-q3km` |
| `oblit_q3km_window` | pending | `qwen38-oblit-q3km-smoke-medium` |
| `oblit_q3km_think_budget` | pending | `qwen38-oblit-q3km-calibrate-think` |
| `oblit_q3km_answer_budget` | pending | `qwen38-oblit-q3km-calibrate-think` |
| `oblit_q3km_max_tokens` | pending | `qwen38-oblit-q3km-calibrate-think` |
| `vram_start_mb` | pending | `nvidia-smi`, session start |
| `evalplus_python` | pending | pipx venv |
| `llama_server` | pending | run 17 build |

Planning estimate, not a result: about 34 MiB of KV per 1024 tokens at
q8_0, computed from the model config (16 full-attention layers of 64, 4
KV heads, head dimension 256). The ladder replaces it.

## Handing-over

The run has not started.
