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

### Block 5: Gemma-12B thinking-on EvalPlus resume — in progress

Resumed from the 54/164 jsonl left by bench4, budget 12000.
`RESULTS_BASE=benchmarks/bench3/results EVALPLUS_MAX_NEW_TOKENS=12000
benchmarks/run-humaneval.sh gemma12-lmstudio-thinking-on
google/gemma-4-12b`. Expect a high empty-completion rate (calibration:
6/10 samples hit a 30000-token cap). Desired next state: keep polling
until 164/164, evaluate, record honestly, then move to block 6.
