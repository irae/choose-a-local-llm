# Goal 3 — the tool-call rules trial

Status: baseline measured, models chosen, trial NOT yet run. The A/B
needs the machine and the cold-start sequence. Everything below comes
from the session logs already on disk.

## The runbook's premise for model 1 does not hold

`AGENT.md` says: "First: `bonsai-prism` — its ~100-call `ls` loop on a
typo'd path inspired the rules."

`bonsai-prism` has no loop. Its session log shows a longest identical
run of **1** and a most-repeated call of **2**. It never repeated
anything.

The loop belongs to a different row. `prism-ml/Ternary-Bonsai-27B-mlx-2bit`
at low, guided, repeated the same `ls` **30 times in a row** on a path it
had typed wrong itself
(`mendel-bench-guided-prism-ml-Ternary-Bonsai-2bit-low`, missing
`27B-mlx-`). That matches the description in
`benchmarks/bench7/state.md` exactly.

The two are easy to confuse and they are not the same row:

* `bonsai-prism` — llama-server, GGUF, provider `llama`
* `prism-ml/Ternary-Bonsai-27B-mlx-2bit` — mlx_lm.server, provider `mlx`

Same model family, different runtime and quant. The runbook attributed
the MLX row's behaviour to the llama row.

## Measured loop and error record, all local rows with a session log

| Run | tool calls | distinct | longest identical run | worst repeated call |
| --- | --- | --- | --- | --- |
| gemma-4-12b low guided | 130 | 30 | **72** | `bash ls -F_r` (88 total) |
| Ternary-Bonsai-mlx low guided | 122 | 79 | **30** | `bash ls <typo'd path>` |
| qwen3.6-35b high guided | 285 | 263 | 1 | `git status --short` (6) |
| qwen3.6-35b high blind | 203 | 198 | 2 | a `read` (2) |
| bonsai-prism high blind | 76 | 74 | 1 | a `read` (2) |
| Ternary-Bonsai-mlx high blind | 52 | 49 | 2 | a `read` (3) |
| gemma-4-12b high guided | 21 | 18 | 2 | a `grep` (2) |
| gemma-4-12b high blind | 15 | 14 | 1 | `edit` (2) |

Tool-call error rate from the recorded telemetry, aggregated per model:

* google/gemma-4-12b — 117 errors in 166 calls, **70.5%**, 3 runs
* bonsai-prism — 22 in 76, 28.9%, 1 run
* gemma-4-26b-a4b — 20 in 115, 17.4%, 1 run (parked model, excluded)
* qwen3.6-35b-a3b — 84 in 997, 8.4%, 4 runs
* prism-ml/Ternary-Bonsai-27B-mlx-2bit — 34 in 404, 8.4%, 4 runs
* mlx-community/Qwen3.8-27B-4bit — 24 in 307, 7.8%, 4 runs

The runbook proposed the mlx Bonsai parser crash and the Qwen3.8 runs
as candidates for the second model. Both are among the CLEANEST rows by
error rate. The evidence points elsewhere.

## Models chosen

**1. `google/gemma-4-12b`.** Worst on both measures by a wide margin:
70.5% tool-call error rate, and a 72-call identical loop. Its low-guided
run made 130 tool calls with only 30 distinct, of which one invalid
command (`ls -F_r`, a flag that does not exist) accounts for 88. It is
the clearest possible test of the rule "do not repeat the same call
unchanged".

**2. `prism-ml/Ternary-Bonsai-27B-mlx-2bit`.** The 30-call typo'd-path
loop that the rules were actually written for, plus the `qwen3_coder`
parser crash the draft's second paragraph targets.

**`bonsai-prism` is not proposed**, because the behaviour it was chosen
for is not in its log. Keeping it would spend a slot on a model with no
loop to fix. The owner mandated it, so this is a recommendation to
change the runbook, not a decision taken. Running three models instead
of two is the alternative if the owner wants the mandated row kept.

## What the trial measures

From the session log of each arm, the numbers that already discriminate:

* longest identical consecutive run of the same call and arguments
* count of the most repeated call
* distinct calls as a fraction of total calls, which is the loop
  signature in one number
* tool errors from the harness telemetry
* parser crashes, counted as `harness_crash` end reasons

Success is not a score. The question is how much the numbers move.

## Trial design

Design 1 from the draft, narrowed.

* **Task**: one Mendel item, handed directly. Replace a single
  dependency. Do NOT ask the model to fetch issue 13 — the fetch is
  where `bonsai-prism` self-typo'd the repo as `irai/mendel` and
  derailed a whole run, which is a different failure and would confound
  this one.
* **Arms**: with and without the draft "Tool calls" section, delivered
  by `pi --append-system-prompt`. Two models, two arms, four runs.
* **Isolation**: scratch worktrees, unscored, never written to
  `results.json` or `results-guided.json`.
* **Preparation**: the cold-start sequence in
  `docs/methodology/checklist.md` step 4, once for the session.
* **Frozen**: `benchmark/agents-global.md` stays at v1.0. Nothing in
  this trial edits it.

Cheaper probe first, from draft alternative 3: replay the two exact
failing situations as short prompts before spending full runs. For
gemma-4-12b, a directory listing task in a worktree whose path is easy
to mistype. For the MLX Bonsai, a multi-line edit with embedded quotes.
If the rules do not change behaviour on the replay, the full runs are
not worth the machine time.

## Open, needs the owner

1. Keep `bonsai-prism` as mandated, swap it for `gemma-4-12b`, or run
   all three.
2. Confirm which Mendel dependency is the single handed task.
