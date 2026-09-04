# LM Studio thinking probe — the best Gemma config IS reproducible

Run 2, 2026-09-04, with the owner present. Script:
`lmstudio-thinking-probe.sh`. Model loaded once, not cycled. No panic,
no incident; the machine was quiet before and after.

## What was asked

The best Gemma-12B EvalPlus row — **0.909 / 0.872 at 100% completion** —
was measured on 2026-08-28 with thinking off by default. A later note in
`reports/gemma-4-12b-it.md` says "current engine builds always think, so
this config is not reproducible today", which would block any re-run and
any Mendel attempt on the only Gemma-12B config that scores well.

## Result — thinking is OFF, and cannot be turned on

Model key `gemma-4-12b-it-mlx` (`lmstudio-community/gemma-4-12B-it-MLX-4bit`),
LM Studio server on port 8081, one prompt, three request shapes:

| Request | `reasoning_content` | content | thinking |
| --- | --- | --- | --- |
| no `enable_thinking` sent | 0 chars | 1906 | **OFF** |
| `enable_thinking: false` | 0 chars | 1923 | **OFF** |
| `enable_thinking: true` | 0 chars | 1923 | **OFF** |

Checked that the thinking is not merely hidden elsewhere: the content
carries **zero** `<|channel>` tokens and zero `<think>` tags in every
arm. The `reasoning_content` field exists and is empty.

**So thinking is off by default and the API cannot turn it on.** That is
exactly the state `benchmarks/bench3/state.md` recorded in August:
"thinking-on is blocked: LM Studio's REST API exposes no working thinking
toggle for this model."

## Two corrections this forces

1. **The report's note is wrong for this model key.** "Current engine
   builds always think" does not hold for `gemma-4-12b-it-mlx` today.
   **`gemma12-best-eval` is reproducible.** The note should be corrected
   or scoped to whatever entry it was observed on.
2. **The failing Mendel runs used a different LM Studio entry.** All
   three Gemma-12B Mendel rows ran `google/gemma-4-12b`, not
   `gemma-4-12b-it-mlx`. `google/gemma-4-12b` is not in
   `~/.cache/lm-studio/models` today, and it is the entry whose EvalPlus
   run produced reasoning that exhausted the budget on 61 of 164
   problems. So the "always thinks" observation, the 0.622 score and the
   failed Mendel runs all belong to that OTHER entry — not to the one
   behind the good score.

## What this reopens

The owner's ruling was "Gemma-4-12B on MLX or LM Studio is out **for
thinking-on agentic work**". On this model key thinking-on is not even
reachable, so the ruled-out configuration cannot be produced by
accident.

That leaves a concrete, untried, and cheap experiment:

**Run Mendel guided against `gemma-4-12b-it-mlx` with no
`enable_thinking` in the request** — the exact configuration behind
0.909 / 0.872 at 100% completion. It has never been tried. Every Gemma-12B
Mendel row so far used the other entry with thinking on.

Two things are needed and neither is a measurement:

- a pi model entry pointing at `gemma-4-12b-it-mlx` rather than
  `google/gemma-4-12b`, sending no thinking kwarg
- a scored run, which a research run does not schedule

## Honest caveat

This probe used one prompt at `max_tokens` 600 and all three replies hit
`finish_reason: length`. It establishes the thinking state, which is what
it was for. It says nothing about quality, speed or behaviour over a long
agent run.

Evidence: `~/.local/share/choose-a-local-llm/evidence/run2-lmstudio-probe/`.
