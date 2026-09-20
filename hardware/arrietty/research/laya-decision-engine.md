# Laya: a typed decision engine beside the local LLM

Status: draft 2026-09-20, scheduled as the only item of research run 1.
Starts only after benchmark run 28 closes (owner, 2026-09-20). Needs
hardware: yes, the RTX machine, about half a day; GPU memory under
2 GB, so the limit is the rule of one job on the GPU, not the fit.
Origin: the owner's interest in <https://github.com/NandhaKishorM/laya>.

## What Laya is

Not a generative model. An encoder with RL-trained heads that answers
typed questions about a text in one forward pass: `choice` (one label
of a list), `score` (an ordinal level) and `noul` (a calibrated
P(true)). It writes no text, so no EvalPlus, no Mendel, no agent row,
and no server with an OpenAI API. It is another category, and every
test here is new (owner, 2026-09-20).

| checkpoint | encoder | parameters | context | file |
|---|---|---|---|---|
| `convaiinnovations/laya` | ModernBERT-large | 421M | 512 | not read |
| `convaiinnovations/laya-multilingual` | mmBERT-base | 322M | 1,024 | 644 MB safetensors |
| `convaiinnovations/laya-typed-decisions` | ModernBERT-large | 421M | 1,024 | not read |

Apache 2.0. `pip install laya`, version 0.3.4 of 2026-09-20, Python
3.8 to 3.12. The machine has Python 3.14, so the environment is
`uv venv --python 3.12`. The package is days old: pin the version and
the three Hugging Face revisions in the results, and read the package
source before trusting a number from it. The call is
`Router(preload=True).predict(state, questions)`, in-process.

## What the authors claim

Source: `BENCHMARKS.md` in their repository, read 2026-09-20; all on a
Tesla T4. The notebook is `notebooks/laya_benchmark_colab.ipynb`.

- Latency p50, `laya-multilingual`: 32.8 ms for 1 question, 72.3 ms
  for 10, 337.4 ms for 50. `laya`: 39.5, 158.6, 771.3. CPU: 193 to
  464 ms.
- ECE as shipped 0.466 (`laya`) and 0.314 (`laya-multilingual`); 0.081
  and 0.106 after one fitted temperature per question type and option
  count. Both checkpoints ship over-confident, by their own words.
- typed-decisions, 2,000 decisions: 0.766 for the fine-tuned
  checkpoint on that benchmark's own training split; the two base
  checkpoints 0.361 and 0.342, below the majority class at 0.461.
- Held out: jailbreak guardrails 0.708 to 0.762, toxicity 0.530,
  model routing 0.639, 0.123 and 0.659.
- Portuguese, MASSIVE intent: 0.470 (`laya`) and 0.450
  (`laya-multilingual`); ECE 0.512 and 0.342.
- Their limits: under about 20 options per `choice`; `score` is the
  weakest primitive (SST-5 0.372); `laya` collapses outside English
  and stays confident.

## What carries over from the benchmark method

The worktree and run branch, the kit shape (`AGENT.md`, `state.md`,
`results.md`, `results/`), the wakeup every 1200 seconds, the status
lines, the scoped memory watcher, commit as results land, the evidence
archive, and "a runner measures, a coordinator decides". What does not
apply: thinking level and budget, `max_tokens`, serving `-c`, harness
window, quant choice, the OpenAI clients. The harness is one new Python
script in the run kit.

## The tests

Each test writes a table and its conditions. No test asks for a
verdict.

- `laya-cost`. Cold load time, peak GPU memory and peak RSS, and p50
  and p95 latency at 1, 5, 10 and 50 questions per call, per
  checkpoint, on CUDA and on CPU with the GPU hidden. The CPU cells
  answer whether Laya can sit beside a coding server that holds the
  whole GPU. Compare with the T4 numbers above.
- `laya-claims`. The authors' own benchmarks, run with their notebook
  unchanged where it runs, per checkpoint: the six application themes
  (email spam, phishing, guardrails, moderation, RAG relevance, support
  triage), AG News, DAIR Emotion, the Portuguese MASSIVE cells, XNLI,
  and the ECE pair as shipped and after their temperature fit. Table:
  our score beside the published one, and our latency beside the T4
  latency, for every cell. This is the main test: their published
  numbers are the baseline, and the speed comparison is ours.
- `laya-loop-gate`. The project's own labelled data: the loop
  occurrences of `../../kamaji/research/loop-signatures.md`, with
  their session logs, against windows of healthy turns from the same
  logs. One `noul` question per window ("the agent repeats the same
  action with no progress"). Table: P(true) per window, Brier, ECE,
  and the hit and false-alarm counts at 0.5 and at the fitted
  temperature. The two cases `loop-check.py` reads wrong (the healthy
  catchphrase runs, the newline flood) are rows of their own. The
  1,024-token context sets the window size; record it. Not checked:
  which of those session logs still exist. The evidence archive starts
  at run 17 and the occurrences are older; the test first counts the
  logs it can find, and the table carries only those.
- `laya-pass-gate`. The EvalPlus samples and `*_eval_results.json`
  files already under `hardware/*/benchmarks/`, fast mode:
  task prompt plus the model's solution, one `noul` question ("this
  solution passes the hidden tests"), against the real pass or fail.
  Table: Brier and ECE per model row, and the accuracy of a gate at
  0.5 against the base rate. Solutions over the context are counted
  and left out.

- `laya-portuguese`. Portuguese is a first-class target (owner,
  2026-09-20), so `laya-multilingual` is the checkpoint that matters
  and the other two are the comparison. Public Portuguese sets only:
  the MASSIVE `pt-PT` intent split in full (the authors publish 0.470
  and 0.450), and whatever labelled Portuguese sets for spam, topic
  and sentiment the run finds with an open licence; each set found is
  named with its source, licence and size before it is used. XNLI has
  no Portuguese split. Table: accuracy, Brier and ECE per set and per
  checkpoint, as shipped and with a fitted temperature.

The two project tests run on all three checkpoints, as shipped and with
temperatures fitted on a held-out half.

## The harness is generic; a user's tests are not in the repo

Owner decision, 2026-09-20. The repo holds one generic runner: it
takes a questions file (`choice`, `score` and `noul` questions with
their options), a data folder, an optional labels file and a
checkpoint, and writes per-case answers and the summary table (count,
accuracy, Brier, ECE, latency). The public tests above are questions
files committed in the run kit. A user's own questions, data paths,
labels and results live under `~/.config/choose-a-local-llm/` and are
never committed, copied into a run kit, or named in a report. The
runner prints only the summary table to the terminal; per-case output
goes to a file beside the user's data.

## Decided by the owner, 2026-09-20

- No fine-tuning. The base checkpoints are measured as shipped, and
  with the authors' temperature fit.
- The authors' benchmarks are a fine test set; the tests use whatever
  public or project data exists.

## Open decisions for the owner

- The Mac. MPS support is not checked. A `laya-cost` on the Mac is a
  separate item under `../../kamaji/research/`.
- The site has no page type for this category. Nothing is published
  from this run without a decision on that.
