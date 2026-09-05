# The MLX template arm cannot run, and why

Run 2, 2026-09-04. Aborted after 90 seconds. Recorded because the plan
was wrong, not the machine.

## What was attempted

Take the template result from llama.cpp onto the MLX path, by serving
`mlx-community/gemma-4-12B-it-4bit` on upstream `mlx_lm.server` twice:
once as the container is (pre-fix template), once with `--chat-template`
supplying Google's post-fix file.

## Why it cannot work

`mlx_lm.server` refuses the model:

```
File ".../mlx_lm/utils.py", line 191, in _get_classes
ValueError: Model type gemma4_unified not supported.
```

Upstream mlx-lm 0.31.3 has no `gemma4_unified` implementation. LM
Studio's MLX engine is a different build and does have one — which is
precisely why the published Gemma-12B MLX rows were measured there and
not on upstream mlx-lm.

**This was already documented in our own report.**
`docs/setups/m1-max-32gb/reports/gemma-4-12b-it.md` line 89 says
"mlx-lm cannot serve it: it lacks the `gemma4_unified` model type." The
arm was designed without reading it. That is the error here: the repo
had the answer and the plan did not consult it.

## A second, smaller mistake it exposed

The server's readiness check was `GET /v1/models`, which returned 200
while the model had failed to load. A route answering 200 says the HTTP
server is up, not that the model is usable — the same trap as trusting
`/health`, which run 1 recorded and section E is about. The check should
be a real completion. `liveness-watch.sh` in this folder already probes
that way; the arm script did not.

## What this does to the MLX question

The template comparison on the MLX path can only be run on **LM Studio's
engine**, because it is the only MLX build here that can load Gemma-4.
That is the probe deliberately deferred overnight, for the kernel-panic
reason in `state.md`. So it now needs the owner present, and it grows one
step:

1. Does the LM Studio MLX engine read `chat_template.jinja` (stale) or
   the inline `tokenizer_config.json` copy (current)?
2. Does it deserialize `function.arguments` before rendering?
3. **Can its template be overridden at all**, without editing the
   container? If not, testing the fix on that path means changing the
   container, which changes the configuration the published rows were
   measured on.

Question 3 is new and it is the one that decides whether a clean A/B is
even possible on the MLX path.

## What still stands

Nothing measured is affected. The llama.cpp result — three pre-fix arms
looped, one post-fix arm did not — is untouched by this. What is lost is
only the attempt to extend it to MLX without the owner present.
