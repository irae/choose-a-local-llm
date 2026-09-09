# Mendel sampling audit

This page answers one question: what temperature and top_p/top_k did
each Mendel run use. We never wrote these values on any published row.
This audit tries to recover them after the fact.

## Method

We checked three sources, in this order:

1. Claude session history at `~/.claude/projects/*/*.jsonl`. Each Bash
   tool call in these files records the exact command line. We
   searched all 34 matching session files for `llama-server`,
   `mlx_lm.server`, `lms load`, and `run-worker.sh`, and pulled out
   every distinct server-start command (503 distinct commands after
   de-duplication).
2. `~/code/mendel-benchmark/benchmark/scratchpad/benchmark/runs/*-meta.json`.
   None survive. `run-worker.sh` deletes its scratch directory at the
   end of each run.
3. `scratchpad/benchmark/.pi-agent-*` pinned config directories. None
   survive, for the same reason.

Source 2 was the best possible source, since `run-pi-rpc.mjs` writes
the fully resolved pi model entry there, sampling included. It is
gone for every run.

## What we found

No `llama-server` command, no `mlx_lm.server` command, and no `lms
load` command in any session, for any run, carries a `--temp`,
`--top-p`, `--top-k`, `--min-p`, or `--repeat-penalty` flag. These
backends took no sampling flags at the command line in any Mendel
run on this machine.

We also checked `~/.pi/agent/models.json`, the file that defines each
model's harness entry (`contextWindow`, `maxTokens`, `thinkingLevelMap`,
etc.). It has no `temperature`, `top_p`, or `top_k` field anywhere, for
any model, today. We have no earlier copy of this file to check
against, so we cannot rule out a past edit, but the current file
carries no such field for any entry.

We found one file that mentions "temperature" nine matches, but every
hit is either about a hardware temperature sensor (an unrelated coding
task) or about the EvalPlus scoring harness, which always runs at
temperature 0 by EvalPlus's own convention, not a Mendel setting. None
of these hits describe a Mendel agent run.

**Conclusion: temperature and top_p/top_k are not recorded for any
Mendel run on this machine.** No source we can still reach ever wrote
these values down, and no server command ever set them explicitly. We
did not infer a default for any row below. Where a cell reads "not
recorded," we found no value, not a value we assumed.

## Per-run table

Oldest first. Runs 10, 11, and 12 have the most detail because they
are the newest and best-documented; runs 7 and 9 are the earliest
Mendel runs we could still trace.

| date | model alias | backend | full server command | temperature | top_p / top_k | source |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-08-30 to 2026-09-03 (run 7) | `prism-ml/Ternary-Bonsai-27B-mlx-2bit` | MLX (`mlx_lm.server`) | `mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit --prompt-cache-size 2 --port 8081` (worker-started; some blocks also ran `mlx_lm.server` by hand after a failed auto-start) | not recorded | not recorded | session `8c53a030-9a20-451d-b2b6-62ac417cefb5.jsonl` and `eba857ca-0d00-4b57-96c5-9af1ef9e8790.jsonl`; mendel-benchmark commits 2026-08-30 to 2026-09-03 |
| 2026-09-02 to 2026-09-03 (run 7) | `mlx-community/Qwen3.8-27B-4bit` | MLX (`mlx_lm.server`) | `mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit --reasoning-effort medium --port 8081` | not recorded | not recorded | session `8c53a030-9a20-451d-b2b6-62ac417cefb5.jsonl`; run-worker.sh call `./run-worker.sh mlx-community/Qwen3.8-27B-4bit pi blind low` and `pi guided low` |
| 2026-09-03 (run 7) | `qwen3.6-35b-a3b` | llama.cpp (`llama-server`) | worker-started; command not captured verbatim in session history, only the worker call `./run-worker.sh qwen3.6-35b-a3b pi blind high` and `pi guided high` | not recorded | not recorded | session `eba857ca-0d00-4b57-96c5-9af1ef9e8790.jsonl` and `91f392c1-d8be-4e8f-9d1e-2583c6b6331d.jsonl` |
| 2026-09-03 (run 7) | `google/gemma-4-12b` | LM Studio (`lms`) | worker-started; `./run-worker.sh google/gemma-4-12b pi blind high` and `pi guided high` | not recorded | not recorded | session `91f392c1-d8be-4e8f-9d1e-2583c6b6331d.jsonl` |
| 2026-09-05 (run 9) | `gemma-4-12b` | llama.cpp (`llama-server`) | worker-started; `./run-worker.sh gemma-4-12b pi guided off` | not recorded | not recorded | `hardware/m1-max-32gb/benchmarks/bench9/results.md`; session `f55b29c3-3267-4031-a93c-5a1e6d10cc1a.jsonl` |
| 2026-09-05 (run 9) | `mlx-community/Qwen3.8-27B-4bit` | MLX (`mlx_lm.server`) | worker-started, retried after a start failure; `./run-worker.sh mlx-community/Qwen3.8-27B-4bit pi guided low` | not recorded | not recorded | session `f55b29c3-3267-4031-a93c-5a1e6d10cc1a.jsonl`; `bench9/results.md` |
| 2026-09-05 (run 10, block B) | `qwen3.8-27b` (GGUF, bartowski) | llama.cpp (`llama-server`) | `llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M --alias qwen3.8-27b --no-mmproj --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 -ngl 999 -fa on -c 49152 --cache-type-k f16 --cache-type-v f16 --jinja --port 8081 --offline` | not recorded | not recorded | `hardware/m1-max-32gb/benchmarks/bench10/AGENT.md` block B; `.pi/agent/models.json` entry `qwen3.8-27b` has no sampling field |
| 2026-09-06 (run 10, block C) | `gemma-4-26b-a4b` | llama.cpp (`llama-server`) | same as the published `gemma-4-26b-a4b` command: MTP n=2, q8_0 KV, `-c 212992`, `--alias gemma-4-26b-a4b`, `--jinja --port 8081` | not recorded | not recorded | `hardware/m1-max-32gb/benchmarks/bench10/results.md`, "Run 10 Block C: Mendel smoke pass" |
| 2026-09-06 (run 10, block E) | `qwen3.8-27b` (GGUF, bartowski) | llama.cpp (`llama-server`) | same server as block B, f16 KV, `-c 49152` | not recorded | not recorded | `hardware/m1-max-32gb/benchmarks/bench10/AGENT.md` block E |
| 2026-09-06 (run 11, block 1 series) | `qwen3.6-35b-a3b` | llama.cpp (`llama-server`) | q8_0 KV, `-c 98304` (block 1's chosen config), `reserveTokens 8192`; exact flag list not captured verbatim for this instance | not recorded | not recorded | `hardware/m1-max-32gb/benchmarks/bench11/results.md`, "Block 9/10" |
| 2026-09-06 (run 11, block 2) | `gemma-4-26b-a4b` | llama.cpp (`llama-server`) | worker-started; `./run-worker.sh gemma-4-26b-a4b pi guided off` | not recorded | not recorded | `hardware/m1-max-32gb/benchmarks/bench11/results.md`, "Block 2/10" |
| 2026-09-06 (run 11, block 3) | `gemma-4-26b-a4b` | llama.cpp (`llama-server`) | `./run-worker.sh gemma-4-26b-a4b pi blind off` | not recorded | not recorded | `hardware/m1-max-32gb/benchmarks/bench11/results.md`, "Block 3/10" |
| 2026-09-06 (run 11, block 4) | `gemma-4-12b` | llama.cpp (`llama-server`) | f16 KV, no drafter, `-c 262144`, `reserveTokens 8192`; `./run-worker.sh gemma-4-12b pi blind off` | not recorded | not recorded | `hardware/m1-max-32gb/benchmarks/bench11/results.md`, "Block 4/10" |
| 2026-09-06 to 2026-09-07 (run 11, block 5) | `gemma-4-26b-a4b` | llama.cpp (`llama-server`) | `./run-worker.sh gemma-4-26b-a4b pi guided high` | not recorded | not recorded | `hardware/m1-max-32gb/benchmarks/bench11/results.md`, "Block 5/10" |
| 2026-09-07 to 2026-09-08 (run 11, block 8) | `bonsai-prism` (PrismML fork, f16 KV bias regenerated) | MLX (`mlx_lm.server`) | `./run-worker.sh bonsai-prism pi guided high` | not recorded | not recorded | `hardware/m1-max-32gb/benchmarks/bench11/results.md`, "Block 8/10"; mendel-benchmark commit "Score bonsai-prism guided high ... f16-KV PrismML fork" 2026-09-08 |
| 2026-09-08 (run 11, block 9 retry) | `qwen3.6-35b-a3b` | llama.cpp (`llama-server`) | same as block 1, pi window raised 49152 → 81920 (`models.json` edit, owner-authorized); `./run-worker.sh qwen3.6-35b-a3b pi guided off` | not recorded | not recorded | `hardware/m1-max-32gb/benchmarks/bench11/results.md`, "Block 9/10 retry" |
| 2026-09-08 (run 12) | `qwen3.8-27b-reserve8192` (Qwen3.8-27B GGUF, control re-run) | llama.cpp (`llama-server`) | same build as run 10 block B, `MENDEL_CONTEXT_WINDOW=65536`, reserve 8192 | not recorded | not recorded | `hardware/m1-max-32gb/benchmarks/bench12/results.md`, "`qwen38-gguf-blind-medium`" |
| 2026-09-09 (run 12) | `qwen3.8-27b-ista2` (ISTA GSQ-IQ3_S build) | llama.cpp (`llama-server`) | f16 KV, `-c 131072`, window 114688, `n-max 3`, wired 25000 | not recorded | not recorded | `hardware/m1-max-32gb/benchmarks/bench12/results.md`, "`qwen38-ista-mendel`" |
| 2026-09-09 (run 12) | `qwen3.8-27b-atomicchat` (AtomicChat AD-IQ3_S build) | llama.cpp (`llama-server`) | `-c 106496`, window 98304, n-max 3 | not recorded | not recorded | `hardware/m1-max-32gb/benchmarks/bench12/results.md`, "`qwen38-atomicchat-mendel`" |

## Runs we could not recover anything for

- Runs 1 through 3, and any Mendel activity in runs 4, 5, 6, and 8: we
  found no `run-worker.sh` call, no server command, and no results row
  tying these runs to a Mendel block. If Mendel ran in these windows,
  the record of it did not survive in the sources we can still reach.
- Every server command we found, across every run, has no sampling
  flag at all — so even where the table above shows a full command
  line, temperature and top_p/top_k stay "not recorded" for that row.

## What would close this gap for future runs

`run-pi-rpc.mjs` already writes the resolved `model_info` (sampling
included) to a `*-meta.json` file mid-run. The only miss is
`run-worker.sh` deleting that file at cleanup. Keeping one copy per
run, or copying its `model_info` block into the run's row in
`results.md` before cleanup, would make this audit unnecessary for
every run after this one.
