# Run 27 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `budget_message` | `Thinking budget reached. Give the final answer now.` | runbook, Essentials |
| `adapter_sha256` | `f1669534803d340a496015f5c45125f3437b4d13ec764f40e34488ce83967f42` | coordinator, verified 2026-09-18 |
| `adapter_size` | 9682464 | coordinator, verified 2026-09-18 |
| `llama_server_prism` | `prism-b10685-7dffb15`, commit `7dffb158d` | run 24, already installed |
| `orca_c` | pending | `orca-ptq1-f16-ladder`, planning value 139264 |
| `orca_clean` | pending | `sweep-orca-ptq1-f16` |
| `orca_window` | pending | the agent row |
| `vram_start_mb` | pending | `nvidia-smi`, session start |

The unablated arm of the same file and cache, from run 24, to read
against: `-c 139264`, window 135168, 42.1 / 37.3 / 30.1 / 22.4 tok/s at
4096 / 24576 / 65536 / 138240, blind agent row 82 with a CRITICAL trap
A and 17 chore-typed commits, peak context 127141 with one compaction.

## Handing-over

The run has not started.
