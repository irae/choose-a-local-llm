# Run 20 — report

The large form of the run's status line
(`docs/methodology/status-lines.md`, "The site comparison, in full").
Eight re-runs of the empty EvalPlus problems of scored Mac rows, with
the finish reason recorded, 2026-09-15 to 2026-09-16, no block waited
on a human.

| old/new | # | Config | Level | Budget | Base | Plus | Empty | Cause | Re-run wall |
|---|--:|---|---|--:|--:|--:|--:|---|--:|
| old | — | Qwen3.8-27B ISTA IQ3_S-mtp, f16 KV | medium | 8192 | 0.976 | 0.945 | 1/164 | † unproven | — |
| new | — | same | medium | 8192 | 0.976 | 0.945 | 1/164 | budget | 4 |
| old | — | Qwen3.8-27B ISTA IQ3_S-mtp, no drafter | low | 8192 | 0.976 | 0.933 | 1/164 | † unproven | — |
| new | — | same | low | 8192 | 0.976 | 0.933 | 1/164 | budget | 4 |
| old | — | Bonsai-27B fork, q4_0 KV + bias | on | 10240 | 0.927 | 0.890 | 4/164 | † unproven | — |
| new | — | same | on | 10240 | 0.927 | 0.890 | 4/164 | budget | 34 |
| old | — | Bonsai-27B MLX 2-bit | on | 10240 | 0.915 | 0.884 | 5/164 | † unproven | — |
| new | — | same | on | 10240 | **0.933** | **0.902** | 2/164 | budget | 42 |
| old | — | Qwen3.6-35B-A3B UD-Q4_K_XL, q8_0 KV | on | 26624 | 0.939 | 0.921 | 5/164 | † unproven | — |
| new | — | same | on | 26624 | **0.957** | **0.939** | 2/164 | budget | 47 |
| old | — | Gemma-4-26B-A4B UD-Q4_K_XL, f16 KV | on | 30000 | 0.884 | 0.860 | 18/164 | † unproven | — |
| new | — | same | on | 30000 | 0.896 | 0.872 | 16/164 | budget | 150 |
| old | — | Gemma-4-26B-A4B MLX 4-bit | on | 30000 | 0.713 | 0.701 | 46/164 | † unproven | — |
| new | — | same | on | 30000 | **0.793** | **0.768** | 31/164 | budget | 410 |
| old | — | Qwen3.8-27B unsloth UD-IQ3_S, f16 KV | xhigh | 20000 | 0.945 | 0.927 | 8/164 | † unproven | — |
| new | — | same | xhigh | 20000 | 0.945 | 0.927 | 8/164 | budget | 200 |

Findings:

- **Every empty is the output budget.** 65 problems re-ran; 23
  completed on today's builds and 42 hit `finish_reason: length` at
  the same budget. Not one ended on `stop` with no answer, so no row
  on the site carries a `model` cause.
- **Four scores moved up**, all on thinking-on rows: Bonsai MLX,
  Qwen3.6 GGUF, Gemma-26B GGUF and Gemma-26B MLX. The Qwen3.6 change
  reversed the thinking-on against thinking-off reading on its pages,
  and the Bonsai change reversed the MLX against fork reading.
- **`budget` at 30000 does not mean a larger budget helps.** The two
  Gemma-26B rows and both Qwen3.8 xhigh rows keep empties at or near
  the cap; the thinking-budget test (run 22) is the next step on those
  configs.
- **The Bonsai MLX server died three times** on long generations with
  no OOM signature, likely unbounded prompt-cache growth; the Gemma-26B
  MLX command already carries `--prompt-cache-size 2` and ran clean.
  Future Bonsai MLX serve commands should carry it.
- **A killed `run-humaneval.sh` can leave its Python child alive.** One
  stray hit the next block's fresh server before it was caught; no
  data was written. A checklist note is pending.

Gates: none. The Mac session cannot be addressed from the coordinator's
machine, so the run's last two closes reached `master` by merge alone.
