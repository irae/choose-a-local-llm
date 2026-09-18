# Run 24 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `budget_message` | `Thinking budget reached. Give the final answer now.` | runbook, Essentials |
| `THINKING_BUDGET_MARGIN` | 1.5 | runbook, planning value |
| `llama_server_prism` | pending | the fork, "The server" |
| `prism_fork_commit` | pending | the fork, "The server" |
| `budget_flags_present` | pending | "The server", step 5 |
| `bonsai2_27b_pq2_c_q8` | pending | `bonsai2-pq2-kvpick` |
| `bonsai2_27b_pq2_c_f16` | pending | `bonsai2-pq2-kvpick` |
| `bonsai2_27b_pq2_c` | pending | `bonsai2-pq2-kvpick` |
| `bonsai2_27b_pq2_kv` | pending | `bonsai2-pq2-kvpick` |
| `bonsai2_pq2_clean` | pending | `sweep-bonsai2-pq2` |
| `bonsai2_pq2_window` | pending | `bonsai2-pq2-smoke-xhigh` |
| `bonsai2_pq2_think_budget` | pending | `bonsai2-pq2-calibrate-think` |
| `bonsai2_pq2_answer_budget` | pending | `bonsai2-pq2-calibrate-think` |
| `bonsai2_pq2_max_tokens` | pending | `bonsai2-pq2-calibrate-think` |
| `bonsai2_27b_ptq1_c` | pending | `bonsai2-ptq1-kvpick` |
| `bonsai2_27b_ptq1_kv` | pending | `bonsai2-ptq1-kvpick` |
| `bonsai2_ptq1_clean` | pending | `sweep-bonsai2-ptq1` |
| `vram_start_mb` | pending | `nvidia-smi`, session start |
| `evalplus_python` | pending | pipx venv |

Planning estimate, not a result: about 34 MiB of KV per 1024 tokens at
q8_0, from the `qwen35` architecture. With weights of about 6.7 GiB,
the card may hold the whole trained window of 262144 tokens. The
ladder decides.

## Handing-over

The run has not started.
