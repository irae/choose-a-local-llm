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


## `laya-portuguese`

`laya-multilingual` is the checkpoint under test; the other two are
comparison rows. Every row reports the second half of its cases, so the
shipped row and the fitted row cover the same cases. The fitted row
uses one scalar per question, fitted by NLL on the first half.

| set | question | checkpoint | cases | options | fitted | accuracy | majority class | Brier | ECE | temperature |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MASSIVE pt intent | `intent` | `english` | 1487 | 20 | no | 0.5575 | 0.0599 | 0.8589 | 0.4234 | 0.101 |
| MASSIVE pt intent | `intent` | `english` | 1487 | 20 | yes | 0.5575 | 0.0599 | 0.5934 | 0.0773 | 2.435 |
| MASSIVE pt intent | `intent` | `multilingual` | 1487 | 20 | no | 0.5568 | 0.0599 | 0.7142 | 0.2877 | 1.000 |
| MASSIVE pt intent | `intent` | `multilingual` | 1487 | 20 | yes | 0.5568 | 0.0599 | 0.6078 | 0.0821 | 2.692 |
| MASSIVE pt intent | `intent` | `typed-decisions` | 1487 | 20 | no | 0.5407 | 0.0599 | 0.8610 | 0.4211 | 0.101 |
| MASSIVE pt intent | `intent` | `typed-decisions` | 1487 | 20 | yes | 0.5407 | 0.0599 | 0.5818 | 0.0639 | 1.092 |
| SIB-200 topic | `topic` | `english` | 502 | 7 | no | 0.6454 | 0.2450 | 0.5648 | 0.2081 | 1.000 |
| SIB-200 topic | `topic` | `english` | 502 | 7 | yes | 0.6454 | 0.2450 | 0.5068 | 0.0631 | 2.148 |
| SIB-200 topic | `topic` | `multilingual` | 502 | 7 | no | 0.7550 | 0.2450 | 0.3885 | 0.1560 | 1.000 |
| SIB-200 topic | `topic` | `multilingual` | 502 | 7 | yes | 0.7550 | 0.2450 | 0.3520 | 0.0463 | 1.848 |
| SIB-200 topic | `topic` | `typed-decisions` | 502 | 7 | no | 0.6673 | 0.2450 | 0.4947 | 0.1080 | 1.000 |
| SIB-200 topic | `topic` | `typed-decisions` | 502 | 7 | yes | 0.6673 | 0.2450 | 0.4906 | 0.0729 | 1.207 |
| SMS spam | `is_spam` | `english` | 1000 | 2 | no | 0.6440 | 0.6190 | 0.5318 | 0.2273 | 1.983 |
| SMS spam | `is_spam` | `english` | 1000 | 2 | yes | 0.6440 | 0.6190 | 0.4120 | 0.0316 | 15.180 |
| SMS spam | `is_spam` | `multilingual` | 1000 | 2 | no | 0.5990 | 0.6190 | 0.7235 | 0.3596 | 1.000 |
| SMS spam | `is_spam` | `multilingual` | 1000 | 2 | yes | 0.5990 | 0.6190 | 0.4022 | 0.1179 | 15.960 |
| SMS spam | `is_spam` | `typed-decisions` | 1000 | 2 | no | 0.8630 | 0.6190 | 0.2552 | 0.1446 | 1.983 |
| SMS spam | `is_spam` | `typed-decisions` | 1000 | 2 | yes | 0.8630 | 0.6190 | 0.2112 | 0.0329 | 0.829 |
| B2W reviews | `sentiment` | `english` | 1000 | 3 | no | 0.6190 | 0.3410 | 0.5786 | 0.2322 | 1.760 |
| B2W reviews | `sentiment` | `english` | 1000 | 3 | yes | 0.6190 | 0.3410 | 0.4858 | 0.0725 | 4.020 |
| B2W reviews | `stars` | `english` | 1000 | 5 | no | 0.2760 | 0.3410 | 0.9353 | 0.3517 | 1.251 |
| B2W reviews | `stars` | `english` | 1000 | 5 | yes | 0.2760 | 0.3410 | 0.7633 | 0.1203 | 5.855 |
| B2W reviews | `sentiment` | `multilingual` | 1000 | 3 | no | 0.6800 | 0.3410 | 0.5336 | 0.2224 | 1.000 |
| B2W reviews | `sentiment` | `multilingual` | 1000 | 3 | yes | 0.6800 | 0.3410 | 0.4406 | 0.0294 | 2.902 |
| B2W reviews | `stars` | `multilingual` | 1000 | 5 | no | 0.2610 | 0.3410 | 1.1371 | 0.3987 | 1.000 |
| B2W reviews | `stars` | `multilingual` | 1000 | 5 | yes | 0.2610 | 0.3410 | 0.8166 | 0.0098 | 20.000 |
| B2W reviews | `sentiment` | `typed-decisions` | 1000 | 3 | no | 0.6480 | 0.3410 | 0.4654 | 0.0702 | 1.760 |
| B2W reviews | `sentiment` | `typed-decisions` | 1000 | 3 | yes | 0.6480 | 0.3410 | 0.4605 | 0.0520 | 2.095 |
| B2W reviews | `stars` | `typed-decisions` | 1000 | 5 | no | 0.3780 | 0.3410 | 0.7159 | 0.0979 | 1.251 |
| B2W reviews | `stars` | `typed-decisions` | 1000 | 5 | yes | 0.3780 | 0.3410 | 0.7072 | 0.0435 | 1.672 |

Conditions. `laya` 0.3.4, checkpoint revision `1c5edc17`, CUDA,
bfloat16, `--batch 16`. Accuracy is argmax against the label; the
majority class column is the largest label share of the same cases;
Brier is the multiclass sum, 0 to 2; ECE has 15 bins over the
probability of the predicted option. `as shipped` is the checkpoint's
own temperature: `laya` and `laya-typed-decisions` carry fitted values
(and 0.101 for a `choice` with 11 or more options), `laya-multilingual`
carries 1.0 for every question type, so its shipped row is the raw
model.

The sets, all public:

| set | source | licence | cases used | how they were taken | labels |
| --- | --- | --- | --- | --- | --- |
| MASSIVE pt intent | `mteb/amazon_massive_intent`, config `pt`, revision `940fd47a` | as the MASSIVE corpus ships it (CC BY 4.0) | 2,974, the whole test split | every case, no sampling | 59 intents, 20 options per case |
| SIB-200 topic | `Davlan/sib200`, config `por_Latn`, revision from the hub on 2026-09-21 | CC BY-SA 4.0 | 1,004, every row of the three splits | all rows, shuffled with seed 0 | 7 topics |
| SMS spam | `dbarbedillo/SMS_Spam_Multilingual_Collection_Dataset`, column `text_pt` | GPL | 2,000 of 5,572 | seed 0, stratified by label | ham, spam |
| B2W reviews | `americanas-tech/b2w-reviews01` at commit `4639429e`, the source the Hugging Face card points at | CC BY 4.0 | 2,000 of 129,098 | seed 0, stratified by polarity | 3 polarities and 5 star levels |

Two things about the data, so no row is read as more than it is. The
Portuguese of the SMS spam set is a machine translation of the English
SMS Spam Collection, not text a Portuguese speaker wrote. The B2W
`stars` question is the same review as its `sentiment` question, asked
as a 5-level `score`; the two rows are not independent.

The config name for Portuguese in `mteb/amazon_massive_intent` is `pt`,
not `pt-PT`. MASSIVE's own locale for it is `pt-PT`.

The fitted temperature for `stars` on `laya-multilingual` is 20.000,
the top of the search range, so the fit wanted a flatter distribution
than the search allowed. Its ECE of 0.0098 is the value at the bound,
not a converged fit.

## `laya-loop-gate`

The test needs the session log of a loop occurrence. It searched the
repository and `~/.local/share/choose-a-local-llm/evidence/`, which is
the whole search area the runbook names.

| # | occurrence (`loop-signatures.md`) | session log found | where it was searched |
| --- | --- | --- | --- |
| 1 | `.taprc` tool call, 85 repeats | no | repo, evidence archive |
| 2 | `gh auth login` prompt, 8 repeats | no | repo, evidence archive |
| 3 | eslint-plugin thinking loop | no | repo, evidence archive |
| 4 | `enableColor` catchphrase | no | repo, evidence archive |
| 5 | same catchphrase, guided v3.0 | no | repo, evidence archive |
| 6 | `DSML` syntax leak in thinking | no | repo, evidence archive |
| 7 | newline flood, three floods | no | repo, evidence archive |
| 8 | "Wait, I will do glob first" text cycle | no | repo, evidence archive |
| 9 | `ls -F_r` / `ls -R_r`, 100 repeats | no | repo, evidence archive |
| 10 | `ls -F_r`, 72 repeats | no | repo, evidence archive |
| 11 | `bash {"command": 4}`, 37 repeats | no | repo, evidence archive |
| 12 | path typo `ls`, many repeats | no | repo, evidence archive |
| 13 | not a loop, kept as a caveat | no | repo, evidence archive |

Zero of thirteen found, so the test closes with no gate measurement.

What is in the two places, and why none of it is a session log:

- The evidence archive starts at `run17` and holds 242 server and
  `benchy` logs and four JSON files. It has no session or events log of
  any kind. The occurrences are older than `run17`, which
  `loop-signatures.md` says itself.
- `benchmarks/mendel/results.json` and `results-guided.json` hold the
  scoring records of 47 runs: model, serving, scores, defects,
  telemetry. The `.taprc` and `enableColor` strings are in the defect
  texts, not in a transcript. There are no turns in these files.
- `tests/fixtures/` holds nine real but trimmed excerpts, 2 to 120
  lines each, copied on 2026-09-05. They are the test data of
  `loop-check.py`, not the sessions.
- `hardware/kamaji/research/run4/results/corpus-mendel-js.txt` is a
  JavaScript source corpus, not turns.

For a later run: the gate needs turn-level text. Nothing in the two
places carries it today, so the test can only run after a Mendel run
archives its `<slug>-events.jsonl` or its session log.

## `laya-pass-gate`

One `noul` question, "This solution passes the hidden tests.", over the
task prompt and the model's solution. The label is the plus-tests
result of the same task. Both rows of a pair report the second half of
the kept cases, the half the fitted run reports.

The pairs found, all fast mode, all under `hardware/*/benchmarks/`:

| model row | sample file | cases | pass rate |
| --- | --- | --- | --- |
| `fast-bonsai2-pq2-f16-xhigh` | `hardware/arrietty/benchmarks/bench28/results/fast-bonsai2-pq2-f16-xhigh/humaneval/bonsai2-27b-pq2-f16_openai_temp_0.0.jsonl` | 164 | 0.9451 |
| `fast-bonsai2-pq2-xhigh` | `hardware/arrietty/benchmarks/bench28/results/fast-bonsai2-pq2-xhigh/humaneval/bonsai2-27b-pq2_openai_temp_0.0.jsonl` | 164 | 0.9451 |
| `fast-bonsai2-ptq1-f16-orca-xhigh` | `hardware/arrietty/benchmarks/bench28/results/fast-bonsai2-ptq1-f16-orca-xhigh/humaneval/bonsai2-27b-ptq1-f16-orca_openai_temp_0.0.jsonl` | 164 | 0.9512 |
| `fast-bonsai2-ptq1-f16-xhigh` | `hardware/arrietty/benchmarks/bench28/results/fast-bonsai2-ptq1-f16-xhigh/humaneval/bonsai2-27b-ptq1-f16_openai_temp_0.0.jsonl` | 164 | 0.9451 |
| `fast-bonsai2-ptq1-xhigh` | `hardware/arrietty/benchmarks/bench28/results/fast-bonsai2-ptq1-xhigh/humaneval/bonsai2-27b-ptq1_openai_temp_0.0.jsonl` | 164 | 0.9512 |
| `fast-gemma12-nvfp4-on` | `hardware/arrietty/benchmarks/bench28/results/fast-gemma12-nvfp4-on/humaneval/gemma-4-12b-nvfp4_openai_temp_0.0.jsonl` | 164 | 0.9512 |
| `fast-gemma12-q4kxl-on` | `hardware/arrietty/benchmarks/bench28/results/fast-gemma12-q4kxl-on/humaneval/gemma-4-12b-q4kxl_openai_temp_0.0.jsonl` | 164 | 0.9634 |
| `fast-gemma26-nvfp4-on` | `hardware/arrietty/benchmarks/bench28/results/fast-gemma26-nvfp4-on/humaneval/gemma-4-26b-a4b-nvfp4_openai_temp_0.0.jsonl` | 164 | 0.9512 |
| `fast-qwen38-iq3s-xhigh` | `hardware/arrietty/benchmarks/bench28/results/fast-qwen38-iq3s-xhigh/humaneval/qwen3.8-27b-iq3s_openai_temp_0.0.jsonl` | 164 | 0.9268 |

| model row | checkpoint | cases kept | left out | pass rate | fitted | gate accuracy at 0.5 | share called pass | Brier | ECE | temperature |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `fast-bonsai2-pq2-f16-xhigh` | `english` | 135 | 29 | 0.8971 | no | 0.8382 | 0.8824 | 0.1345 | 0.1530 | 1.983 |
| `fast-bonsai2-pq2-f16-xhigh` | `english` | 135 | 29 | 0.8971 | yes | 0.8382 | 0.8824 | 0.1142 | 0.0673 | 0.893 |
| `fast-bonsai2-pq2-f16-xhigh` | `multilingual` | 156 | 8 | 0.8974 | no | 0.8974 | 1.0000 | 0.0994 | 0.0815 | 1.000 |
| `fast-bonsai2-pq2-f16-xhigh` | `multilingual` | 156 | 8 | 0.8974 | yes | 0.8974 | 1.0000 | 0.1026 | 0.1026 | 0.050 |
| `fast-bonsai2-pq2-f16-xhigh` | `typed-decisions` | 162 | 2 | 0.9012 | no | 0.8272 | 0.8765 | 0.1947 | 0.2322 | 1.983 |
| `fast-bonsai2-pq2-f16-xhigh` | `typed-decisions` | 162 | 2 | 0.9012 | yes | 0.8272 | 0.8765 | 0.1446 | 0.1120 | 0.275 |
| `fast-bonsai2-pq2-xhigh` | `english` | 134 | 30 | 0.9104 | no | 0.7463 | 0.8060 | 0.1585 | 0.0844 | 1.983 |
| `fast-bonsai2-pq2-xhigh` | `english` | 134 | 30 | 0.9104 | yes | 0.7463 | 0.8060 | 0.1610 | 0.0975 | 0.988 |
| `fast-bonsai2-pq2-xhigh` | `multilingual` | 154 | 10 | 0.9091 | no | 0.8831 | 0.9740 | 0.0975 | 0.0797 | 1.000 |
| `fast-bonsai2-pq2-xhigh` | `multilingual` | 154 | 10 | 0.9091 | yes | 0.8831 | 0.9740 | 0.0988 | 0.0820 | 0.871 |
| `fast-bonsai2-pq2-xhigh` | `typed-decisions` | 163 | 1 | 0.9146 | no | 0.7683 | 0.8049 | 0.1947 | 0.1817 | 1.983 |
| `fast-bonsai2-pq2-xhigh` | `typed-decisions` | 163 | 1 | 0.9146 | yes | 0.7683 | 0.8049 | 0.1506 | 0.0813 | 0.353 |
| `fast-bonsai2-ptq1-f16-orca-xhigh` | `english` | 137 | 27 | 0.9130 | no | 0.8261 | 0.8261 | 0.1366 | 0.1165 | 1.983 |
| `fast-bonsai2-ptq1-f16-orca-xhigh` | `english` | 137 | 27 | 0.9130 | yes | 0.8261 | 0.8261 | 0.1237 | 0.0803 | 0.829 |
| `fast-bonsai2-ptq1-f16-orca-xhigh` | `multilingual` | 156 | 8 | 0.9103 | no | 0.9103 | 1.0000 | 0.0932 | 0.0992 | 1.000 |
| `fast-bonsai2-ptq1-f16-orca-xhigh` | `multilingual` | 156 | 8 | 0.9103 | yes | 0.9103 | 1.0000 | 0.0919 | 0.0963 | 0.454 |
| `fast-bonsai2-ptq1-f16-orca-xhigh` | `typed-decisions` | 163 | 1 | 0.9146 | no | 0.8293 | 0.8659 | 0.1862 | 0.2296 | 1.983 |
| `fast-bonsai2-ptq1-f16-orca-xhigh` | `typed-decisions` | 163 | 1 | 0.9146 | yes | 0.8293 | 0.8659 | 0.1320 | 0.0984 | 0.255 |
| `fast-bonsai2-ptq1-f16-xhigh` | `english` | 134 | 30 | 0.9104 | no | 0.7910 | 0.8209 | 0.1383 | 0.1116 | 1.983 |
| `fast-bonsai2-ptq1-f16-xhigh` | `english` | 134 | 30 | 0.9104 | yes | 0.7910 | 0.8209 | 0.1303 | 0.0910 | 0.871 |
| `fast-bonsai2-ptq1-f16-xhigh` | `multilingual` | 154 | 10 | 0.8961 | no | 0.8961 | 1.0000 | 0.1012 | 0.0989 | 1.000 |
| `fast-bonsai2-ptq1-f16-xhigh` | `multilingual` | 154 | 10 | 0.8961 | yes | 0.8961 | 1.0000 | 0.1039 | 0.1039 | 0.050 |
| `fast-bonsai2-ptq1-f16-xhigh` | `typed-decisions` | 162 | 2 | 0.9012 | no | 0.8025 | 0.8519 | 0.1918 | 0.2404 | 1.983 |
| `fast-bonsai2-ptq1-f16-xhigh` | `typed-decisions` | 162 | 2 | 0.9012 | yes | 0.8025 | 0.8519 | 0.1356 | 0.1105 | 0.353 |
| `fast-bonsai2-ptq1-xhigh` | `english` | 134 | 30 | 0.9104 | no | 0.7463 | 0.8060 | 0.1558 | 0.1267 | 1.983 |
| `fast-bonsai2-ptq1-xhigh` | `english` | 134 | 30 | 0.9104 | yes | 0.7463 | 0.8060 | 0.1596 | 0.1218 | 0.916 |
| `fast-bonsai2-ptq1-xhigh` | `multilingual` | 157 | 7 | 0.9114 | no | 0.9114 | 1.0000 | 0.0905 | 0.0893 | 1.000 |
| `fast-bonsai2-ptq1-xhigh` | `multilingual` | 157 | 7 | 0.9114 | yes | 0.9114 | 1.0000 | 0.0909 | 0.0947 | 0.678 |
| `fast-bonsai2-ptq1-xhigh` | `typed-decisions` | 161 | 3 | 0.9136 | no | 0.8148 | 0.8519 | 0.1916 | 0.2214 | 1.983 |
| `fast-bonsai2-ptq1-xhigh` | `typed-decisions` | 161 | 3 | 0.9136 | yes | 0.8148 | 0.8519 | 0.1420 | 0.0663 | 0.454 |
| `fast-gemma12-nvfp4-on` | `english` | 102 | 62 | 0.9412 | no | 0.9412 | 0.9216 | 0.1127 | 0.2329 | 1.983 |
| `fast-gemma12-nvfp4-on` | `english` | 102 | 62 | 0.9412 | yes | 0.9412 | 0.9216 | 0.0648 | 0.1270 | 0.808 |
| `fast-gemma12-nvfp4-on` | `multilingual` | 153 | 11 | 0.9221 | no | 0.9221 | 1.0000 | 0.0792 | 0.0859 | 1.000 |
| `fast-gemma12-nvfp4-on` | `multilingual` | 153 | 11 | 0.9221 | yes | 0.9221 | 1.0000 | 0.0779 | 0.0779 | 0.050 |
| `fast-gemma12-nvfp4-on` | `typed-decisions` | 161 | 3 | 0.9136 | no | 0.8272 | 0.8889 | 0.1851 | 0.2502 | 1.983 |
| `fast-gemma12-nvfp4-on` | `typed-decisions` | 161 | 3 | 0.9136 | yes | 0.8272 | 0.8889 | 0.1213 | 0.1075 | 0.194 |
| `fast-gemma12-q4kxl-on` | `english` | 95 | 69 | 0.9583 | no | 0.8333 | 0.8750 | 0.1252 | 0.1336 | 1.983 |
| `fast-gemma12-q4kxl-on` | `english` | 95 | 69 | 0.9583 | yes | 0.8333 | 0.8750 | 0.1213 | 0.1236 | 0.695 |
| `fast-gemma12-q4kxl-on` | `multilingual` | 155 | 9 | 0.9615 | no | 0.9487 | 0.9872 | 0.0422 | 0.0301 | 1.000 |
| `fast-gemma12-q4kxl-on` | `multilingual` | 155 | 9 | 0.9615 | yes | 0.9487 | 0.9872 | 0.0419 | 0.0330 | 0.850 |
| `fast-gemma12-q4kxl-on` | `typed-decisions` | 160 | 4 | 0.9500 | no | 0.8500 | 0.8750 | 0.1765 | 0.2783 | 1.983 |
| `fast-gemma12-q4kxl-on` | `typed-decisions` | 160 | 4 | 0.9500 | yes | 0.8500 | 0.8750 | 0.1014 | 0.0742 | 0.231 |
| `fast-gemma26-nvfp4-on` | `english` | 95 | 69 | 0.9583 | no | 0.9375 | 0.9375 | 0.1046 | 0.2059 | 1.983 |
| `fast-gemma26-nvfp4-on` | `english` | 95 | 69 | 0.9583 | yes | 0.9375 | 0.9375 | 0.0667 | 0.1245 | 0.769 |
| `fast-gemma26-nvfp4-on` | `multilingual` | 149 | 15 | 0.9200 | no | 0.9200 | 1.0000 | 0.0782 | 0.0743 | 1.000 |
| `fast-gemma26-nvfp4-on` | `multilingual` | 149 | 15 | 0.9200 | yes | 0.9200 | 1.0000 | 0.0792 | 0.0741 | 0.769 |
| `fast-gemma26-nvfp4-on` | `typed-decisions` | 158 | 6 | 0.9367 | no | 0.8734 | 0.9114 | 0.1743 | 0.2686 | 1.983 |
| `fast-gemma26-nvfp4-on` | `typed-decisions` | 158 | 6 | 0.9367 | yes | 0.8734 | 0.9114 | 0.0992 | 0.0967 | 0.312 |
| `fast-qwen38-iq3s-xhigh` | `english` | 131 | 33 | 0.8788 | no | 0.7727 | 0.8333 | 0.1615 | 0.1030 | 1.983 |
| `fast-qwen38-iq3s-xhigh` | `english` | 131 | 33 | 0.8788 | yes | 0.7727 | 0.8333 | 0.1554 | 0.1160 | 1.177 |
| `fast-qwen38-iq3s-xhigh` | `multilingual` | 159 | 5 | 0.8875 | no | 0.8875 | 1.0000 | 0.1081 | 0.0901 | 1.000 |
| `fast-qwen38-iq3s-xhigh` | `multilingual` | 159 | 5 | 0.8875 | yes | 0.8875 | 1.0000 | 0.1090 | 0.0962 | 0.916 |
| `fast-qwen38-iq3s-xhigh` | `typed-decisions` | 163 | 1 | 0.8902 | no | 0.7927 | 0.8537 | 0.2012 | 0.2196 | 1.983 |
| `fast-qwen38-iq3s-xhigh` | `typed-decisions` | 163 | 1 | 0.8902 | yes | 0.7927 | 0.8537 | 0.1636 | 0.1155 | 0.320 |

Conditions. `laya` 0.3.4, checkpoint revision `1c5edc17`, CUDA,
bfloat16, `--batch 8`, `--skip-over-context`. Every pair is bench 28,
the only fast-mode EvalPlus rows in the repository; all nine are
HumanEval+, 164 tasks each. The task prompts come from
`evalplus/humanevalplus`, matched by `task_id`; no task was missing.
A case whose state does not fit the checkpoint context is counted in
"left out" and takes no part in any number of its row. That is why
`laya` keeps about 134 of 164 cases at 512 tokens, while the two
1,024-token checkpoints keep 149 to 163.

"Share called pass" is the share of kept cases the gate answers with
P(true) at or over 0.5. The pass rate beside it is the share that
really passes, so the two columns together say whether a row's accuracy
comes from a decision or from one constant answer.

Two notes on the fit. The fitted scalar runs into the ends of the
search range on some rows: 0.050, the bottom, on two
`laya-multilingual` rows, and 20.000 is not reached here. A value at a
bound is the value at the bound, not a converged fit. And the labels
are heavily one-sided: the pass rates run from 0.879 to 0.963, so the
second half of a row holds about 8 to 20 failing solutions. Every
number in this table rests on that many negatives.
