# Qwen3.6-35B-A3B on MLX: the two missing agent rows

Unscheduled. Needs hardware: yes, two agent runs of up to five hours
each, plus one smoke.

This model has no agent row on the MLX server at all. Run 11 planned
both, blind and guided at thinking on, and skipped them: no pi entry
existed for `mlx-community/Qwen3.6-35B-A3B-4bit`, and the runbook made
a missing entry a stop. The entry is no longer a blocker, because
`npm run pi:models` writes it from the site data.

What it needs when it runs:

- Serve the site row `qwen36-mlx-think`:
  `mlx_lm.server --model mlx-community/Qwen3.6-35B-A3B-4bit
  --prompt-cache-size 2 --port 8081`.
- The window comes from the newest MLX creep for this model. Run 11
  block 1 measured a ceiling of 40982 tokens at 37.4 tok/s at wired
  25000, and the generation thread then died on a Metal OOM while the
  models endpoint still answered. At the standing limit of 24000 that
  ceiling is unmeasured, so the block starts with a creep.
- The MLX server allocates its cache as it goes and cannot refuse a
  request it cannot serve, so the window must sit below the measured
  ceiling by at least one turn's growth. That margin is what
  `../../research/unscheduled/no-oom-at-mendel.md` derives, and this
  item should not run before it.
- The Mendel smoke first; a fail drops both rows.

Why it is worth doing: the MLX arm is the fastest curve this model has
at shallow depth, and every agent score it holds today came from
llama-server.
