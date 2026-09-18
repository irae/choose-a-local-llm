# Run 26 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `llama_server_prism` | `prism-b10685-7dffb15`, commit `7dffb158d` | run 24, already installed |
| `bonsai2_pq2_f16_c` | pending | `bonsai2-pq2-f16-kvpick`, planning value 122880 |
| `bonsai2_pq2_f16_clean` | pending | `sweep-bonsai2-pq2-f16` |
| `bonsai2_pq2_f16_window` | pending | the blind block, clean rounded down to 4096 |
| `bonsai2_pq2_f16_blind` | pending | the blind block |
| `vram_start_mb` | pending | `nvidia-smi`, session start |

The q8_0 arm of the same file, from run 24, to read against: `-c`
212992, window 208896, 46.0 / 38.2 / 28.2 / 14.5 tok/s, blind 59.5 with
a peak context of 192679 tokens and no compaction.

## Handing-over

The run has not started.
