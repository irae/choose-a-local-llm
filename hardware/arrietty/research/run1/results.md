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
