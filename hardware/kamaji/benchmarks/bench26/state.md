# Run 26 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `budget_message` | `Thinking budget reached. Give the final answer now.` | runbook, Essentials |
| `THINKING_BUDGET_MARGIN` | 1.5 | runbook, planning value |
| `wired_limit` | pending | `sysctl -n iogpu.wired_limit_mb`, must read 25000 |
| `llama_server_prism` | pending | the fork, Metal build |
| `prism_fork_commit` | pending | the fork |
| `budget_flags_present` | pending | the server check |
| `bonsai2_27b_pq2_mac_c` | pending | `bonsai2-pq2-ladder-mac` |
| `bonsai2_27b_ptq1_mac_c` | pending | `bonsai2-ptq1-ladder-mac` |
| `bonsai2_pq2_mac_clean` | pending | `sweep-bonsai2-pq2-mac` |
| `bonsai2_ptq1_mac_clean` | pending | `sweep-bonsai2-ptq1-mac` |
| `served_pack` | pending | the coordinator, at the second sweep's close |

The card's rows to read against, from `bench24`: PQ2_0 at q8_0 serves
`-c 212992` and reads 46.0 tok/s at 4K and 14.5 at 212K; at f16 it
serves 122880 and reads 46.3 and 25.1. PTQ1_0 at q8_0 serves 245760 and
reads 41.7 and 12.8. EvalPlus on PQ2_0 at a 25209 budget: 0.982/0.939,
no empty, 7 forced. Blind agent row: 59.5, peak context 192679 of a
208896 window, no compaction.

## Handing-over

The run has not started.
