# Research run 1 — results

One section per test of `AGENT.md`, a table and its conditions each.
No verdicts.

## `harness`

The runner is
`hardware/arrietty/research/laya-decision-engine/laya-run.py`. It takes
a questions file, a JSONL data file, `--checkpoint`, `--device`,
`--batch`, `--out`, and an optional `--fit-temperature`. It writes
per-case answers with their probabilities to `--out` and prints only
the summary.

Done check: one `noul` question and one `choice` question over four
English cases, the `english` checkpoint, `--batch 1`.

| device | dtype | cold load s | p50 ms | p95 ms | questions/s | peak GPU MB (nvidia-smi) | peak GPU MB (torch) | peak RSS MB |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| cuda | bfloat16 | 16.05 | 11.7 | 12.2 | 170.0 | 3603 | 2351 | 3315 |
| cpu | float32 | 12.70 | 208.5 | 216.8 | 9.5 | 954 (idle desktop) | — | 3226 |

Both devices give the same answers to three decimals. Accuracy 0.75
over the eight question answers; the `choice` question 4/4, the `noul`
question 2/4.

Conditions. `laya` 0.3.4; checkpoint `convaiinnovations/laya` at
revision `1c5edc17`; torch 2.14.0+cu130; transformers 5.17.0; Python
3.12.14. RTX 5060 Ti 16 GB, compute capability 12.0, driver 610.57.04.
One call is one forward pass over both questions of one case. Three
warmup calls, then four measured calls; four calls are too few for a
p95, and `laya-cost` is the latency test. The CPU cell hides the GPU
with `CUDA_VISIBLE_DEVICES=""`. The nvidia-smi peak holds the desktop's
954 MB baseline; the torch peak is this process alone. Peak RSS holds
the CUDA context and the loaded weights.
