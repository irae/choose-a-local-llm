# Mendel probe (xtend) — Gemma-12B thinking-off, both backends

Run 2, 2026-09-04. The owner's closing probe for this model. Task is run
1's `PROMPT_PARSER`: replace one dependency that spans two packages —
`xtend` with `Object.assign` in `lib/core/tree-hash-walker.js` and
`lib/config/index.js`, keep the no-mutation behaviour, and remove it from
`package.json`. Short by design; run 1 built it so this question would
not need a full Mendel run.

Both arms: thinking OFF, same task, same base commit, 25-minute cap,
pinned pi configs under `/tmp` so `~/.pi/agent/models.json` was untouched.

## Result

| | llama-server, f16 KV, thinking off | LM Studio `gemma-4-12b-it-mlx`, thinking off |
| --- | --- | --- |
| tool calls | **42** | 5 |
| distinct | **30** | 4 |
| longest identical run | 2 | 2 |
| repetition loop | **none** | **YES — 2679 lines, ratio 0.02** |
| what repeated | — | `<channel\|><\|channel>thought` |
| commits | **1** | **0** |
| working tree | **clean** | 0 changes |
| end reason | finished | `complete` |

## The finding: thinking-off does not save the MLX path

The LM Studio arm looped on **`<channel|><|channel>thought`** — closing
the thought channel and immediately reopening it, 2679 times, in
`text_delta` rather than in a tool call.

This matters because the whole reason to keep Gemma-12B on LM Studio was
that thinking-off is its reachable, high-scoring configuration. **It was
thinking off, and it still looped.** The probe sent no
`enable_thinking` kwarg, which is exactly the shape of the 0.909/0.872
EvalPlus run.

So the earlier separation does not hold for agent work:

- thinking-off is enough for **EvalPlus**, which is single-turn — 0/164
  empty completions, verified.
- thinking-off is **not** enough for a multi-turn tool-using task on this
  backend.

The llama-server arm, same model family, same task, thinking off, made
42 calls and committed working code.

## What this closes

The owner's ruling was Gemma-12B on MLX/LM Studio out for **thinking-on**
agentic work. This probe extends the evidence to thinking-off: on the
agent path the MLX backend loops either way. The usable configuration for
agent work is **llama-server, f16 KV, thinking off**.

One run per arm. The loop signature here is the channel open/close cycle,
which is the same family as every other loop this run measured.
