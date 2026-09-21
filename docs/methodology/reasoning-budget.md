# The thinking budget

Why every scored [EvalPlus](./evalplus.md) run closes the thinking at
8192 tokens, what that did to the scores, and what it does not prove.
The rule itself is in [EvalPlus](./evalplus.md#fast-mode-one-thinking-budget-for-every-model),
"Fast mode". This page is the reasoning behind it.

## The problem

A thinking model writes its reasoning before its answer. On some
problems the reasoning never ends: the model repeats one idea, or one
line, until the output budget runs out. The answer never arrives. The
benchmark records an empty answer, and an empty answer counts as
failed.

An empty answer hides the cause. A model that cannot solve the problem
and a model that solves it slowly both score zero. Before the budget,
three configurations on the RTX 5060 Ti 16 GB lost most of their
score this way: Gemma-4-12B NVFP4 at thinking on left 53 of 164
answers empty, Gemma-4-12B UD-Q4_K_XL left 34, and Gemma-4-26B-A4B
NVFP4 left 14. Every answered problem of the 12B passed its base
tests. The lost points were time, not ability.

The loops are the same problems on every model: HumanEval/99, 32, 145,
then 137, 39, 64. A larger output budget does not help. At 30000
tokens of output the same problems still loop, on both machines. On
this hardware, at 8 to 15 tok/s, 30000 tokens is 35 to 60 minutes on
one problem.

## How the method arrived

The first answer was a calibration. Each configuration ran ten fixed
problems with no budget. The longest converged reasoning, times 1.5,
became that model's thinking budget, and the longest converged answer
set the answer budget. The server then closed the thinking at that
budget and the model answered. Forced answers that failed were run
again with no budget, to sort them into four cells: passed anyway,
passed with more thinking, looped, or wrong both ways.

Twelve calibrated runs on nine configurations, on both machines, made
the case against the calibration:

- The calibration measured luck, not the model. In 10 of 12
  calibrations the longest converged problem was HumanEval/32, 145 or
  76, at 17000 to 27859 tokens, so the formula gave the 30000 cap in 7
  of 12 cases. One loop-prone problem in the sample set the budget of
  the whole run.
- No forced answer ever passed with more thinking. Of 131 forced
  answers, 39 failed a test and ran again with no budget: 30 looped to
  the cap, 9 converged and failed again, 0 passed.
- A forced answer passed 111 times of 131.
- A simulation from the finish logs put a fixed budget of 8192 at 762
  of 2885 minutes saved (26 percent) across the twelve runs, with 0 to
  6 natural passes per run at risk. The one real 8192 run of that
  series, Qwen3.8-27B ISTA IQ3_S at q8_0 KV and effort xhigh, lost
  none: 0.976/0.933 at 8192 and at 30000, in 175 minutes against 273.

So the calibration cost a run of ten problems, then a proof run, and
it still set the budget from the tail. The owner replaced it with one
fixed number for every model on 2026-09-19. The record of the test is
`hardware/arrietty/research/thinking-budget.md` in the repository.

## How it works now

Every scored run serves with two llama.cpp flags and one client value:

```
llama-server ... --reasoning-budget 8192 \
  --reasoning-budget-message "Thinking budget reached. Give the final answer now."
EVALPLUS_MAX_NEW_TOKENS=16384
```

- The server counts the reasoning tokens. At 8192 it injects the
  message into the reasoning and closes the thinking tag.
- The model then writes its answer. It still answers; the budget stops
  the thinking, not the response. The answer keeps 8192 tokens of room
  inside the 16384 output budget, and no converged answer has needed
  more than 1300.
- Nothing is calibrated. The same two numbers apply to every model,
  level and machine.
- A forced answer is a real answer. It passes or fails by its tests
  like any other. The run counts it under `forced`, beside the score,
  so a reader sees how often the model did not converge on its own.
- A run with no thinking serves without the flag at the same output
  budget.

The rows now compare, because every row got the same amount of
thinking. A score under fast mode says: this is what the model gets
done inside 8192 tokens of reasoning.

## The splice

Temperature 0 on a fixed serving configuration is deterministic. The
reasoning of a run at a larger budget begins with the same 8192 tokens
that fast mode allows. So an earlier run of the same configuration, at
a thinking budget of 8192 or more, already holds the fast-mode answer
of every problem whose reasoning stayed inside 8192 tokens and was not
forced. The tool `benchmarks/thinking-budget.py splice` copies those
samples and their finish lines into the new run, and lists the rest.
The new run generates only the listed problems under the fast flags.

What it costs: the spliced row's wall is its own generation time plus
the source's time for the kept problems, so the wall is a sum of two
runs on the same hardware, not one clock. A source with no finish log
cannot be spliced and the row runs in full. On 2026-09-20, five
ternary rows kept 146 to 152 problems each and generated 12 to 18;
one 12B row kept 119 and generated 45; three rows ran all 164.

## The results

Every scored thinking row of the RTX 5060 Ti 16 GB got its fast-mode
score on 2026-09-20 (the last row ended early on 2026-09-21). The
table gives each row before and after. "Before" is the published
score under the earlier method: a calibrated thinking budget where
the row had one, else a plain output budget. Empty and forced counts
are out of 164. Walls are active minutes.

| Row | Before: base / plus | Empty | Forced | Thinking budget | Wall | After: base / plus | Forced | Wall |
| --- | --- | --: | --: | --: | --: | --- | --: | --: |
| Gemma-4-12B NVFP4, f16 KV, thinking on | 0.659 / 0.640 | 53 | — | none | 204 | **0.976 / 0.951** | 44 | 211 |
| Gemma-4-12B UD-Q4_K_XL, f16 KV, thinking on | 0.793 / 0.780 | 34 | — | none | 259 | **0.988 / 0.963** | 34 | 198 |
| Gemma-4-26B-A4B NVFP4, f16 KV, thinking on | 0.909 / 0.878 | 14 | — | none | 215 | **0.988 / 0.951** | 19 | 154 |
| Qwen3.8-27B UD-IQ3_S, q8_0 KV, effort xhigh | 0.957 / 0.921 | 3 | — | none | 290 | 0.963 / 0.921 | 8 | 188 |
| Bonsai-2-27B PTQ1_0, f16 KV, effort xhigh | 0.970 / 0.939 | 0 | 6 | 30000 | 196 | 0.976 / 0.945 | 12 | 125 |
| Bonsai-2-27B PQ2_0, f16 KV, effort xhigh | 0.982 / 0.945 | 0 | 6 | 30000 | 183 | 0.982 / 0.945 | 12 | 121 |
| Bonsai-2-27B PTQ1_0, q8_0 KV, effort xhigh | 0.982 / 0.945 | 0 | 9 | 30000 | 245 | 0.982 / 0.945 | 16 | 140 |
| Bonsai-2-27B PQ2_0, q8_0 KV, effort xhigh | 0.982 / 0.939 | 0 | 7 | 25209 | 176 | 0.988 / 0.945 | 12 | 119 |
| Bonsai-2-27B PTQ1_0 with the refusal-ablation LoRA, f16 KV, effort xhigh | 0.976 / 0.945 | 0 | 10 | 30000 | 274 | 0.976 / 0.945 | 18 | 152 |

Every "after" row has 0 empty answers. The full records, with the
forced problem ids, are under `hardware/arrietty/benchmarks/` in the
repository, and each row's page under
[the RTX 5060 Ti setup](../setups/arrietty/comparison.md) shows the
earlier score marked with a †.

One independent check: Gemma-4-12B NVFP4 at thinking on had scored
0.976 / 0.951 with 45 forced answers under its calibrated budget of
7350 tokens. The 8192 run reads the same pair with 44 forced.

## How much better it is

The gain depends on how long the model thinks.

- **Large for models that loop.** The three rows that had no thinking
  budget were under-measured by 8 to 32 points of base pass@1. Gemma-4-12B
  NVFP4 moved from 0.659 to 0.976. Its UD-Q4_K_XL build moved from
  0.793 to 0.988. Gemma-4-26B-A4B NVFP4 moved from 0.909 to 0.988. The
  earlier scores measured the output budget, not the model.
- **Near nothing for models that converge.** The five ternary rows
  moved from 0.970-0.982 to 0.976-0.988 base, and 0.939-0.945 to 0.945
  plus. The Qwen3.8 IQ3_S row moved from 0.957 to 0.963. The changes
  are within one to two problems.
- **No row went down.**
- **The wall fell on the five spliced ternary rows**, by 32 to 45
  percent: the PTQ1_0 q8_0 row from 245 to 140 minutes, the LoRA row
  from 274 to 152. It fell on the two Gemma rows that used to run out
  of output budget and ran in full again, 215 to 154 and 259 to 198.
  It rose on one row: the 12B NVFP4 row went from 204 to 211 minutes,
  because 44 forced answers each cost 8192 thinking tokens plus an
  answer, where the earlier run cut them at 8192 tokens of output.

What the numbers do not prove:

- They do not prove that 8192 is the best budget. The test showed that
  more thinking rescued no forced failure across twelve runs. It did
  not test smaller budgets, and it did not test other model families.
- They do not say a forced answer is as good as a converged one. A
  forced answer passes about 85 percent of the time; the forced count
  beside each score is the measure of how much the budget did.
- A high forced count with a high score means the model thinks past
  the point where its answer is ready. It does not mean the model
  needs the thinking.

## Limits

- **No agent row has run under a thinking budget.** Every
  [Mendel](./mendel.md) score on the site was served without the flag.
  EvalPlus problems are short and single-turn; an agent task runs for
  hours with tool calls. A budget that fires in the middle of a tool
  call could help or harm, and no data says which. The agent side is
  pending.
- **MLX rows cannot run fast mode.** `mlx_lm` accepts a thinking
  budget and does not enforce it. Those rows keep a plain output
  budget and say so.
- **Two tool defects the fast-mode runs found**, both recorded in the
  run kit:
  - `benchmarks/run-humaneval.sh` picks its samples file with `find
    "$DIR" -name "*.jsonl"` and `head -1`. Since the finish log sits
    beside the samples directory, `find` order can return
    `finish.jsonl`, and the evaluate step stops with "No completion
    or solution found in sample". Two blocks of the day hit it and were
    evaluated by hand from the samples file; the score is the same
    evaluator on the same file. The fix is to search `$DIR/humaneval`
    only.
  - The row command of the refusal-ablation LoRA row downloads its
    adapter with `hf download`, which fails on the named repository.
    The run served the adapter from its git clone at commit `947a80c`,
    the same file the earlier run served.
- **One answer that ran to the output budget.** On three ternary rows
  and one 12B row, one forced answer went on to 16384 tokens after the
  budget fired (HumanEval/64 on the ternary rows, HumanEval/145 on the
  12B). Each held code and was scored. Fast mode makes this rare, not
  impossible.
