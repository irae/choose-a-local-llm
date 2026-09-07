# Bonsai MLX at thinking off: the guided and blind agent rows

Unscheduled. Needs hardware: yes, one smoke and two agent runs.

Thinking off is this model's best quality score, 0.927 base with every
completion delivered, and it has no valid agent row at that level.
Two attempts were lost to the harness, not to the model: a dead
GitHub token that sent it into a login loop, and 85 identical shell
calls against a missing file, stopped by the operator after three
hours. Both are invalid rows in the guided results.

Both causes are fixed. The token is checked before every agent run,
and the runner now ends a run on five identical tool calls.

What it needs when it runs:

- Serve the site row `bonsai-mlx-off`:
  `mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit
  --prompt-cache-size 2 --port 8081`, thinking off through the pi
  level `off`.
- The window from the newest MLX creep for this model, minus the
  in-turn margin from
  `../../research/unscheduled/no-oom-at-mendel.md`. Bonsai holds the
  worst growth on record, 17440 tokens in one turn from a single 51 KB
  shell result, so this model is the reason that margin exists.
- The Mendel smoke first, then guided, then blind.

It sits behind the fork's f16 work, which is scheduled: if f16 KV
moves this model's usable depth, the MLX arm matters less.
