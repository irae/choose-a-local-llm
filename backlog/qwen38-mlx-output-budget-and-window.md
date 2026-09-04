# Qwen3.8 27B on MLX: output budget versus window, and what a cap costs

Status: parked 2026-09-04. Bench 9 runs with the 8192 budget as
written; the owner judges by its results and re-runs later if that was
wrong. The dynamic cap (option 3) stays a framework candidate.
Filed: 2026-09-04, from research runs 1 and 2.
Needs hardware: no for the decision; the re-run is a bench item.

## The facts

- pi's entry for this model declares `contextWindow` 26624 and
  `maxTokens` 16384. The window is real: the measured ceiling at the
  current wired limit is between 26708 and 28672 tokens, so 26624 sits
  84 tokens under the last success. It cannot go up.
- `maxTokens` is the per-response cap pi sends as `max_tokens`. It is
  not a context size and it does not trigger compaction. Compaction is
  pi's own step between turns, driven by `contextWindow`.
- Once the prompt passes about 10240 tokens, prompt plus 16384 no
  longer fits in 26624. The server then returns almost nothing: run 7
  recorded three turns that ended on `length` after one output token,
  with prompts of about 20318 tokens. That, not the window, is what
  broke the Qwen3.8 low rows.

## The choices, and what each costs

1. **`maxTokens` 8192, window unchanged** (research run 2's proposal,
   in bench 9). A response longer than 8192 tokens is cut at 8192. On
   an agent task that is a very large single edit; most turns are far
   shorter. Compaction timing does not change.
2. **Keep 16384, lower `contextWindow` to about 10240** so pi compacts
   before the arithmetic breaks. The model then works with a third of
   its real window, and compacts three times as often. Worse.
3. **A dynamic cap in pi**: `max_tokens` = window minus the current
   prompt, per request. The right fix, but it is a pi feature or a
   runner-side computation, not a config edit. A backlog item for the
   framework if the owner wants it.

The cap is model-specific. It exists because this model's window on
this machine is 27K; a model with a 90K window keeps 16384 with room to
spare. Nothing here is a loop detector.

Recommendation: option 1 for this model only, and note the cap in the
row's config text. Option 3 as a framework feature later.
