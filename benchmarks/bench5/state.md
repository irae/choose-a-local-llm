# Night 5 state

## Order deviation (owner's instruction, 2026-08-30)

Run block 8 (Mendel: Gemma-12B LM Studio) before block 7 (bonsai-off
EvalPlus). All other blocks keep the order in `AGENT.md`.

## Run log

### Block 1: bonsai-fork-single depth sweep — done

Speed floor 33K used tokens, 7.9 tok/s, 9.6 GB RSS, no compression or
swap. Recorded on the site, committed on `run5`.

### Block 2: bonsai-fork-2x depth sweep — done

Slot 0 swept, slot 1 idle. Speed floor 33K used tokens, 7.8 tok/s,
10.9 GB RSS, no compression or swap. Recorded on the site, committed.

### Block 3: Gemma-12B LM Studio shallow probe — done

4K-33K confirmation sweep. Shallow 35.4 tok/s (replaces the earlier
unverified 37), 8.1 GB RSS (replaces 8.8 GB). Matches the bench4
65K/29.29 tok/s ceiling. Recorded on the site, committed.

### Block 4: Mendel (Bonsai MLX, then Qwen3.8-27B) — done

- Bonsai MLX: two attempts crashed on the same `mlx_lm.server`
  `qwen3_coder` tool-parser bug (unescaped quote in a multi-line
  edit-tool JSON argument). Scored 55/100 partial from the second
  attempt's 3 real commits. Not a firewall issue (checked Little
  Snitch's log, no blocks).
- Qwen3.8-27B (effort medium): one run hit a different failure (a
  truncated tool-call warning, not a crash) and the `pi` client exited
  silently; resumed in the same worktree with no lost work. Scored
  79.5/100 partial — closed at the ~4h soft time budget with 3 of 8
  libraries done and `rimraf` partially done. Real `pnpm install`s,
  test/lint runs before each commit, correct `chore:` commit types —
  much better process discipline than the Bonsai run.
- Both scored on `../mendel`'s `benchmark` branch, pulled + rebased
  onto the owner's new "round 2" guided/blind commits, pushed to
  `origin/benchmark`. Imported into `docs/setups/m1-max-32gb/comparison.md`.

### Block 5: Gemma-12B thinking-on EvalPlus resume — paused at 98/164

Resumed from the 54/164 jsonl left by bench4, budget 12000. Owner
changed the plan (2026-08-30 night): stop this block, focus fully on
Mendel guided runs for the rest of the night. Stopped cleanly at
98/164, watcher stopped, LM Studio unloaded and server stopped. The
jsonl resumes cleanly with the identical command:
`RESULTS_BASE=benchmarks/bench3/results EVALPLUS_MAX_NEW_TOKENS=12000
benchmarks/run-humaneval.sh gemma12-lmstudio-thinking-on
google/gemma-4-12b`. Desired next state: resume this once the Mendel
guided queue is done (or the owner says so).

## Plan change (owner's instruction, 2026-08-30 night): Mendel guided runs

The owner added a new "guided" Mendel prompt/rubric track (already
merged upstream on `../mendel`'s `benchmark` branch as the round-2
guided/blind split: `prompt-guided.txt`, `results-guided.json`,
`results-guided.csv`, `report-guided.html`). Owner wants every local
model that already has a blind Mendel score, plus Qwen3.8-27B thinking
low (unscored, new config), run against the guided prompt tonight.
Order: best to worst by our own EvalPlus pass@1 plus score.

Queue (Gemma-4-26B-A4B excluded — parked, reminder to owner: still
parked, no benchmarks including Mendel). Owner reordered on
2026-08-30 night: Qwen3.8-27B medium moved to last (a first attempt
started and was stopped with zero commits, worktree/branch cleaned up,
nothing lost):

1. Qwen3.6-35B-A3B, llama-server MoE (0.921 plus) — already has a
   blind score (`qwen3.6-35b-a3b`, 42/100); needs the guided run.
2. Ternary Bonsai-27B, mlx 2-bit (0.884 plus) — already has a blind
   score (55/100 partial); needs the guided run.
3. Qwen3.8-27B, effort low — new config, no EvalPlus score yet.
4. Qwen3.8-27B, mlx 4-bit, effort medium (0.939 plus) — already has a
   blind score (79.5/100 partial); needs the guided run. Moved last
   per the owner.

Owner added a 5th item on 2026-08-30 night, before Qwen3.8-27B medium:
Gemma-12B LM Studio guided. Final queue: Qwen3.6-35B-A3B, Bonsai MLX,
Qwen3.8-27B low, Gemma-12B LM Studio, Qwen3.8-27B medium.

**Finding: the Qwen3.6-35B-A3B MTP drafter is currently broken on this
brew llama.cpp build.** `--spec-type draft-mtp --spec-draft-n-max 3`
fails to allocate (`Insufficient Memory`, Metal command buffer error),
and once it fails the whole backend enters a broken state — every
completion after that returns HTTP 500 `Compute error`, even though
`/health` still reports ready. This reproduced at both `-c 98304` and
`-c 65536`, with the GPU fully idle beforehand (plenty of free
memory), so it is not a memory-pressure fluke. Dropping the drafter
flags entirely loads and generates normally at the full `-c 98304`.
The Mendel guided run for this model uses the no-drafter command
below; this does not affect scoring (Mendel does not measure tok/s),
but it does mean the site's own `14.1/8.6 tok/s` figures for this
config are unverified against the current brew build and may need a
re-check before the next depth sweep.

Guided serving command actually used (no MTP):
```
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 98304 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

Blocks 6-9 from the original runbook wait until this queue is done.
