# ATTENTION, coordinator — two different LM Studio Gemma entries were treated as one model

Run 2, 2026-09-04. The owner asked for this to reach the planner's full
attention before the site settles anything about Gemma-12B.

## The finding

Every Gemma-12B number on the site comes from LM Studio, but from **two
different registered entries**, and they behave differently:

| Entry | Where it appears | Thinking | Result |
| --- | --- | --- | --- |
| `gemma-4-12b-it-mlx` — the short key for `lmstudio-community/gemma-4-12B-it-MLX-4bit` | the EvalPlus **thinking-off** run, `gemma12-lmstudio-off` | **off, and cannot be turned on** | **0.909 / 0.872, 0/164 empty, 100% completion** |
| `google/gemma-4-12b` | the EvalPlus **thinking-on** run and **all three Mendel rows** | on | 0.622 / 0.610, **61/164 empty**, and three failed agent runs |

`google/gemma-4-12b` is **not in `~/.cache/lm-studio/models` today**. The
only Gemma-4 container in the store is
`lmstudio-community/gemma-4-12B-it-MLX-4bit`.

## Why it matters

Three site claims trace to conflating these entries:

1. **"Thinking is always on with this engine"** and **"current engine
   builds always think, so this config is not reproducible today"**
   (`reports/gemma-4-12b-it.md`, config blocks #1 and #2). Probed on
   2026-09-04 with the model loaded once: on `gemma-4-12b-it-mlx`
   thinking is **off** with no kwarg, **off** with
   `enable_thinking:false`, and **off** with `enable_thinking:true` —
   zero `<|channel>` tokens and zero `<think>` tags in every reply.
   **The good config is reproducible.** Evidence in
   `lmstudio-thinking-probe.md`.
2. **The Mendel verdict on Gemma-12B.** All three rows ran the
   thinking-on entry. The entry behind the best score has never been put
   in front of Mendel.
3. **The 0.622 row.** Its 61 empty completions are reasoning exhausting
   the output budget, the failure `docs/methodology/evalplus.md` warns
   about. Of the 103 it did answer, 102 passed — 99.0%. See
   `gemma12-thinking-score.md`.

## What the planner has to decide

- Whether the two entries are labelled distinctly everywhere, since
  "Gemma-4-12B, MLX" currently covers both.
- What happens to the config blocks that say thinking cannot be turned
  off. They are wrong for the entry that matters and should be corrected
  or scoped.
- Whether `google/gemma-4-12b` is re-obtained for reproducibility, or
  its rows are marked as resting on a container the machine no longer
  holds.
- Whether the three Mendel rows are re-labelled as the thinking-on
  entry, so the gap is visible rather than implied.

This run changes no published page. All of the above is the planner's.
