# Research run 1 (RTX machine): a typed decision engine

Ready to start when the owner says benchmark run 28 is closed,
2026-09-20. One item, about half a day.

You are the executor, on `arrietty`. Read this file and `index.md`,
then `../laya-decision-engine.md`, whole, when the item starts. Write
all prose in ASD-STE100 Simplified Technical English, and pass that
rule to every sub-agent.

## Wakeup

`ScheduleWakeup` every 1200 seconds from the first action to the end
of the run, also while a background task runs, with the short status
line at every wakeup (`docs/methodology/checklist.md`, step 7).

## Order

- `harness`
- `laya-cost`
- `laya-claims`
- `laya-portuguese`
- `laya-loop-gate`
- `laya-pass-gate`
- `retry-sweep`

## Essentials

- `state.md` holds what earlier sessions of this run did. Resume where
  its handing-over section says.
- **FIRST ACTION:** be in the worktree
  `../choose-a-local-llm-research1`, on branch `laya-research`. It
  exists. Verify with `pwd`, `git branch --show-current` and
  `git worktree list`. Every command of this run happens there.
- **Branches, exactly.** This work is not on `master` and does not go
  there (owner, 2026-09-20). You work on `laya-research` and only
  there. Never check out `master`, never merge `master` or a run
  branch into this one, never merge this one anywhere, and **never
  push anything**. The coordinator is on the same machine and reads
  your commits from the local branch.
- Then `docs/methodology/checklist.md` and
  `docs/methodology/status-lines.md`, whole, once per session. Where
  the checklist says to create a run worktree, push or report a merge,
  this file wins. `tools/preflight.sh` first; every line `ok` before
  the item starts. Never sudo, never reboot.
- **The GPU must be empty before you start.** `nvidia-smi` shows no
  compute process and `pgrep -fl llama-server` is empty. If not, stop
  and ask; do not kill anything. One job on the GPU at a time.
- **Private folder.** `tools/preflight.sh` reads
  `~/.config/choose-a-local-llm/machine.md`. You never open, list or
  read any other path under `~/.config/choose-a-local-llm/`, and you
  never run the harness against a folder this file does not name.
  This file names none outside the worktree.
- **This run may install and download**, with no further approval: a
  `uv venv --python 3.12` under the worktree's `scratchpad/`, `laya`
  pinned to `0.3.4` with its dependencies, the three checkpoints of
  the item, the authors' repository, and the public datasets the
  tests name. Record every version, revision and dataset commit in
  `state.md`. Nothing is trained: no fine-tuning, no notebook cell
  that updates weights. The authors' temperature fit is allowed; it
  fits a scalar on held-out outputs.
- **Research publishes no number.** No site edit, no `models.json`
  edit, no `docs/` edit.
- Start `benchmarks/run-watch.sh` as the checklist says, with
  `RUNWATCH_MEM_LOG=~/.local/share/choose-a-local-llm/research1-mem.log`.
  Peak GPU memory comes from `nvidia-smi --query-gpu=memory.used`
  sampled every second by the harness, and from
  `torch.cuda.max_memory_allocated()`; record both.
- **A runner measures.** Every test ends in a table and its
  conditions. Write no verdict, no pick and no recommendation.
- A failure you can repeat with no human action is retried at once,
  inside its test. `retry-sweep` holds only what needed a human.
- Commit on `laya-research` as results land. Every stop-and-ask goes
  to the coordinator session with the condition and your candidate
  answer. Never a bare `git stash`.
- Archive evidence before the session closes:
  `tools/archive-evidence.sh hardware/arrietty/research/run1/results research1`.

## `harness`

Read the `laya` package source first (`Router`, `predict`, the
checkpoint routing, the temperature fit). Write what differs from the
item's description into `state.md`. The router picks a checkpoint by
language; every test here names its checkpoint, so find the way to
force one, and if there is none, load the checkpoint directly and
record how.

Write one script,
`hardware/arrietty/research/laya-decision-engine/laya-run.py`. Inputs:
a questions file (JSON: a list of `choice`, `score` or `noul`
questions with their options), a data file (JSONL, one `state` text
per line, with an optional `label` per question), `--checkpoint`,
`--device cuda|cpu`, `--batch`, `--out`. Outputs: per-case answers
with probabilities to `--out`, and to the terminal only the summary:
cases, accuracy, Brier, ECE (15 bins), p50 and p95 latency, peak GPU
memory, peak RSS. An optional `--fit-temperature` fits on the first
half of the data and reports on the second half. The script knows
nothing about any dataset; each test below is a questions file and a
data file under `results/<test>/`.

Done: the script answers one `noul` and one `choice` question on CUDA
and on CPU (`CUDA_VISIBLE_DEVICES=""`), and the two summaries are in
`results.md`.

## `laya-cost`

Fixed: the three checkpoints at the recorded revisions, `laya` 0.3.4,
the package's default dtype on each device (record it). Derived: none.

Per checkpoint and per device: cold load time (new process, files in
the page cache, three repeats), then latency at 1, 5, 10 and 50
questions per call, 20 warmup calls and 200 measured calls per cell,
on one fixed English state and one fixed Portuguese state of about
200 tokens each, saved in `results/laya-cost/`.

Done: in `results.md`, one table per device with checkpoint, questions
per call, p50, p95, questions per second, peak GPU memory, peak RSS,
and beside each p50 the authors' T4 p50 from the item.

## `laya-claims`

Run the authors' notebook code from their repository at a recorded
commit, as a script, unchanged except for paths and device. Sets: the
six application themes, AG News, DAIR Emotion, XNLI, the Portuguese
MASSIVE cells, and the ECE pair as shipped and after their fit. If a
set of theirs is not public, write that in the table and go on.

Done: one table, one row per set and checkpoint: our score, the
published score, the difference, our ms per question, the sample
count. Conditions under the table.

## `laya-portuguese`

`laya-multilingual` is the checkpoint under test; the other two are
comparison rows. MASSIVE `pt-PT`, the full test split, 20 options as
the authors set them. Then search for labelled Portuguese sets for
spam, topic and sentiment with an open licence; before using one,
write its name, source, licence, size and label list in `state.md`.
Use at most three, and at most 2,000 cases of each, sampled with seed
0 and stratified by label. Every set runs as shipped and with
`--fit-temperature`.

Done: one table: set, checkpoint, cases, options, accuracy, majority
class rate, Brier, ECE, fitted or not.

## `laya-loop-gate`

Read `hardware/kamaji/research/loop-signatures.md`. For each
occurrence in its table, look for the session log in the repo and
under `~/.local/share/choose-a-local-llm/evidence/`. First table: the
occurrences, found or not found, with the path. Go on with the found
ones only; with fewer than three found, write that and close the test.

From each found log cut windows of consecutive turns that fit the
checkpoint's context (count tokens with its tokenizer; record the
window size): every window inside the loop span is a positive, and
the same number of windows from outside the span, taken at even
spacing, are negatives. One `noul` question: "The agent repeats the
same action and makes no progress." All three checkpoints, as shipped
and fitted.

Done: one table per checkpoint: occurrence, kind of loop, windows,
mean P(true) on positives and on negatives, hits and false alarms at
0.5; then Brier and ECE over all windows. The occurrences that
`loop-check.py` reads wrong are rows like the others, marked.

## `laya-pass-gate`

Inputs: every fast-mode HumanEval+ sample file with its
`*_eval_results.json` under `hardware/*/benchmarks/`. List the pairs
found in `state.md` first. State: the task prompt and the model's
solution. One `noul` question: "This solution passes the hidden
tests." Label: the plus-tests result. Cases over the checkpoint's
context are counted and left out. All three checkpoints, as shipped
and fitted.

Done: one table: model row, cases kept, cases left out, pass rate,
accuracy of the gate at 0.5, Brier, ECE.

## `retry-sweep`

Only what needed a human: a refused permission, a login, an owner
decision. List each with its condition in `state.md` and ask once.

## After the run

Update `state.md` with a handing-over section: what ran, versions and
revisions, machine state left behind, evidence archived. Message the
coordinator session with the last commit id. The coordinator reads
the tables and writes the outcome.
