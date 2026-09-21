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

## `laya-cost`, CUDA

Cold load, a new process each time, the files in the page cache, three
repeats:

| checkpoint | cold load s, three repeats | mean s |
| --- | --- | --- |
| `english` | 13.04, 13.27, 13.32 | 13.21 |
| `multilingual` | 13.01, 13.14, 13.18 | 13.11 |
| `typed-decisions` | 12.98, 13.07, 13.24 | 13.10 |

Latency, 20 warmup calls and 200 measured calls per cell. One call is
one forward pass over all the questions of one state.

| checkpoint | state | q/call | p50 ms | p95 ms | questions/s | peak GPU MB (torch) | peak GPU MB (nvidia-smi) | peak RSS MB | authors' T4 p50 ms |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `english` | en | 1 | 12.68 | 12.92 | 79 | 2356 | 3667 | 3301 | 39.5 |
| `english` | en | 5 | 39.91 | 40.21 | 125 | 2378 | 3719 | 3304 | — |
| `english` | en | 10 | 78.52 | 78.80 | 127 | 2432 | 3779 | 3301 | 158.6 |
| `english` | en | 50 | 440.86 | 441.12 | 113 | 2814 | 4203 | 3301 | 771.3 |
| `english` | pt | 1 | 14.33 | 14.54 | 70 | 2360 | 3681 | 3301 | 39.5 |
| `english` | pt | 5 | 45.66 | 46.01 | 109 | 2388 | 3723 | 3300 | — |
| `english` | pt | 10 | 92.87 | 93.20 | 108 | 2439 | 3771 | 3300 | 158.6 |
| `english` | pt | 50 | 517.34 | 517.60 | 97 | 2906 | 4299 | 3300 | 771.3 |
| `multilingual` | en | 1 | 8.29 | 9.03 | 118 | 1531 | 2675 | 4472 | 32.8 |
| `multilingual` | en | 5 | 17.06 | 17.27 | 293 | 1562 | 2709 | 4476 | — |
| `multilingual` | en | 10 | 31.35 | 31.65 | 319 | 1596 | 2757 | 4472 | 72.3 |
| `multilingual` | en | 50 | 201.13 | 201.51 | 248 | 1856 | 3279 | 4478 | 337.4 |
| `multilingual` | pt | 1 | 8.64 | 9.93 | 114 | 1531 | 2675 | 4474 | 32.8 |
| `multilingual` | pt | 5 | 15.83 | 16.07 | 315 | 1556 | 2689 | 4475 | — |
| `multilingual` | pt | 10 | 28.15 | 28.50 | 355 | 1589 | 2721 | 4472 | 72.3 |
| `multilingual` | pt | 50 | 180.79 | 181.19 | 276 | 1825 | 3231 | 4475 | 337.4 |
| `typed-decisions` | en | 1 | 12.63 | 12.86 | 79 | 2356 | 3667 | 3300 | — |
| `typed-decisions` | en | 5 | 39.91 | 40.19 | 125 | 2378 | 3719 | 3301 | — |
| `typed-decisions` | en | 10 | 78.80 | 79.35 | 127 | 2432 | 3779 | 3300 | — |
| `typed-decisions` | en | 50 | 441.00 | 441.23 | 113 | 2814 | 4203 | 3300 | — |
| `typed-decisions` | pt | 1 | 14.32 | 14.51 | 70 | 2360 | 3681 | 3301 | — |
| `typed-decisions` | pt | 5 | 45.65 | 45.98 | 109 | 2388 | 3723 | 3300 | — |
| `typed-decisions` | pt | 10 | 92.85 | 93.11 | 108 | 2439 | 3771 | 3300 | — |
| `typed-decisions` | pt | 50 | 517.40 | 517.67 | 97 | 2906 | 4299 | 3300 | — |

Conditions. RTX 5060 Ti 16 GB, driver 610.57.04, bfloat16 on the GPU,
the package's default for every checkpoint. `laya` 0.3.4, checkpoint
revision `1c5edc17`, torch 2.14.0+cu130, Python 3.12.14. The two fixed
states are `results/laya-cost/state-en.txt` and `state-pt.txt`: 220 and
270 tokens on the ModernBERT tokenizer, 219 and 198 tokens on the
mmBERT tokenizer. The questions are `results/laya-cost/questions-*.json`,
the first 1, 5, 10 and 50 of one pool of 50, in a fixed order that
repeats `noul`, `choice` and `score`. The `nvidia-smi` peak holds the
desktop's 954 MB baseline; the torch peak is this process alone. The
T4 column is the authors' `BENCHMARKS.md`, which publishes 1, 10 and 50
questions per call for `laya` and `laya-multilingual` only. The authors
do not say which state they used, so the comparison is of the same
question counts, not of the same text.

