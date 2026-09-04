# Which published rows the template bug touches

Run 2, 2026-09-04. Written for the planner. This is the practical
output of the template work: which existing numbers survive, which are
suspect, and how strong each verdict is.

## Verdicts

| Rows | Verdict | Strength |
| --- | --- | --- |
| **GGUF on llama-server** (all Gemma-4 rows) | **KEEPERS** | Proved |
| **EvalPlus rows, every backend** | **KEEPERS** | Proved |
| **MLX / LM Studio, multi-turn agent rows** (Mendel) | **SUSPECT** | Strong, not proved |

## Why the GGUF rows are keepers

Three checks, all local:

1. Both Gemma GGUFs carry the **post-fix** template. The 12B and the
   26B-A4B embed the identical text, hash `e78e690d773f`, containing the
   tool-response branch Google added on 2026-07-15.
2. It was **active**. All four recorded `llama-server` commands in
   `docs/setups/m1-max-32gb/models.json` pass `--jinja`, and on this
   build `--jinja` defaults to enabled anyway. Without it llama.cpp
   would fall back to a built-in template; that never happened.
3. Only **one revision** of each GGUF was ever downloaded — a single
   snapshot directory per repo — so no earlier run could have used a
   different file.

## Why every EvalPlus row is a keeper

The two templates differ in exactly one place: what they emit after a
**tool response**. An EvalPlus request has none. Rendering an EvalPlus
prompt under both templates gives **byte-identical output**, with
thinking on and off (`evalplus-unaffected.md`).

So the bug cannot reach a single-turn benchmark, whichever container was
used. This also bounds the finding: **the template must not be offered
as an explanation for any single-turn number.**

## Why the MLX rows are suspect, and why only "suspect"

What is proved:

- Every local Gemma-4 MLX container ships the **pre-fix**
  `chat_template.jinja`, hash `a23ecdbb9d01`, matching Google's
  2026-06-03 revision.
- `AutoTokenizer.from_pretrained` on the exact directory LM Studio
  serves resolves to that pre-fix file, even though a current template
  sits unused in `tokenizer_config.json` beside it.
- On llama-server, forcing that same pre-fix template makes Gemma-4-12B
  fall into a repetition loop in three arms out of three, while the
  post-fix template did not.

What is **not** proved:

- **Which file LM Studio's own MLX engine reads.** It is a different
  build from upstream mlx-lm. Its binaries name neither file, and its
  application bundle references both. Static analysis could not settle
  it, and the live probe was deliberately not run unattended because
  run 1's kernel panic came from that exact model's load and unload
  cycles.

So the chain is: our containers carry the broken template, the standard
loader picks it, and that template reliably produces the failure on
another backend. That is strong. It is not the same as watching LM
Studio do it.

## What would close the gap

One probe, five minutes, owner present:

1. Load Gemma-12B in LM Studio.
2. Send one chat completion whose history contains an assistant tool
   call, and read back which rendering the engine produced —
   `flood-shape.md` has the two expected outputs already computed.
3. Check whether its template can be overridden without editing the
   container.

Answer 2 and the MLX rows move from suspect to proved-or-cleared. Answer
3 and we know whether a clean A/B on that path is possible at all.
