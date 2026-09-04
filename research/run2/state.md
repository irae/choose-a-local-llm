# Research run 2 — state

Created 2026-09-04 by the coordinator.

Start here: read `AGENT.md`, then `../run1/state.md` (its session close
carries two conclusions that reversed earlier text) and
`../run1/results/`. Log every session below with a handing-over
section at the end, like the `benchmarks/bench<N>` convention.

Your first deliverable is `results/experiments.md`: the ranked
experiment list for the owner to filter. Nothing runs before the owner
approves it.

---

## Session 1 — 2026-09-04, night, unattended

Worktree `../choose-a-local-llm-research2`, branch `research2`.

### Owner instructions for this session

The owner approved the experiment list with **no filter — all tiers**,
then left for the night with these standing orders: keep the GPU busy,
mind warmup and slow ramps, self-recover, never halt. If an item is
blocked, write the block down, commit, and move to the next item.
Infer dependencies and skip an item only when a blocked item truly
blocks it. Ask no questions.

The owner set `iogpu.wired_limit_mb` from 0 to 24000 themselves before
leaving. The machine was rebooted about an hour before the session
started.

### Machine at the start

Uptime 58 minutes, zero swap, 1.65 GB wired, 12.9 GB free pages, no
server, no LM Studio process, no panic log. Little Snitch Agent is
running, so approval prompts can appear; llama-server runs with
`--offline`, which removes its need for the network.

### Done

**T2.1, the llama.cpp context ramp — finished. See
`results/context-ramp.md`.** Ten arms, 8K to 262K, with `-ngl 999` and
again with `--fit on`. Every arm loaded, every arm allocated the MTP
drafter, no swap. **The drafter does not fail at 262144.** 13.6 GB
wired at the top context. Speed reads 27.3 tok/s where the published
page says 45.0; that is a re-probe proposal for the owner, not a
correction, and the differences that could carry it (f16 versus q8_0 KV,
wired limit 27000 versus 24000, build 10621 versus homebrew 0.3.0) are
recorded there.

**T0.1 and T0.2, the container audit — finished. See
`results/container-audit.md`. This is the session's main result.**

1. **Our MLX Gemma-4 containers serve the chat template Google replaced
   to fix the thought loop.** Proven, not inferred:
   - Google's pre-fix revision `657684f` (2026-06-03) is 17466
     characters and has no tool-response branch. The file after the fix
     commit `711c136` (2026-07-15, "chat template — null handling,
     reasoning preservation, turn-tag balance") is 18681 characters and
     opens the thought channel after a tool response.
   - Every local `chat_template.jinja` matches the PRE-FIX hash. The
     `lmstudio-community` container carries both files: the stale jinja
     and the current inline copy in `tokenizer_config.json`.
   - `AutoTokenizer.from_pretrained` on the exact directory LM Studio
     served resolves to the pre-fix template. mlx-lm loads its tokenizer
     through transformers, so the MLX path runs the stale one while the
     current one sits unused beside it.
   - The unsloth GGUF that llama-server uses carries a post-fix
     template.

   So the dangling `<|channel>thought` is the FIX, and the newline flood
   ran on a container Google had already corrected for that exact
   failure. A one-file fix is written in `container-audit.md` and NOT
   applied: it would change a container behind published rows.
2. The quantized-PLE defect does not reproduce. Our Gemma-4 MLX quants
   contain no per-layer embedding tensor at all. What they do have is
   `embed_tokens` at 4 bits with no override, where the QAT OptiQ repo
   protects it at 8 bits.

**T0.3, instruction sets and KV audit — finished.** `FEAT_DotProd = 1`,
`FEAT_I8MM = 0`, `FEAT_BF16 = 0`, `FEAT_SME = 0` on this M1 Max, exactly
as the runbook assumed. The only q4 KV in any published config is the
Bonsai prism fork, and it is not naive q4: it pairs `--cache-type-k q4_0
--cache-type-v q4_0` with a `--kv-mean-center` calibration bias file.
Two entries in `docs/setups/m1-max-32gb/models.json` carry it. That is
the config section B asks to test at q8_0.

### Running when this was written

**T1.1 arm 1 of 2, the llama-server replay** (`results/replay-llama.sh
embedded`). The failing `google-gemma-4-12b-low-guided` Mendel task, the
archived 3935-character prompt, base commit `benchmark-guided-base`,
replayed against `unsloth/gemma-4-12b-it-GGUF:Q4_K_XL` on llama-server
instead of the LM Studio MLX path. Declared context 158464 to match the
LM Studio arm's compaction point; the server serves 262144, which the
ramp proved fits. Wall cap 150 minutes.

Reading at 24 tool calls: 21 distinct, longest identical run 1, zero
swap, 90.8 percent prompt-cache share. Both measured LM Studio arms were
already repeating by call 11-40, so this arm is inside the window where
the failure appears and has not produced it. Not a result until the arm
ends.

The pi config is a pinned copy under `/tmp/run2/replay-embedded/pi-agent`
built by `results/make-replay-models.py`. **The owner's
`~/.pi/agent/models.json` was not touched.**

Arm 2 is chained to start when arm 1 releases the GPU, so the machine
does not idle. The template finding above changed what arm 2 means: it
forces the same GGUF onto the PRE-FIX template, so the pair is a
before-and-after of Google's fix on one backend.

### Also done, no GPU

- **T0.4, prompt-cache health** (`results/prompt-cache-telemetry.md`).
  All three backends answer with the OpenAI `cached_tokens` field and pi
  already records it per turn, so `cache-share.py` needed no server
  work. Proposed alert: below 20 percent cache share after turn 3 is a
  broken serving config.
- **T2.4, the loop stop** (`results/loop-stop.ts`). Blocks the Nth
  identical consecutive tool call and terminates the run. Never edits a
  result. Loads only with `pi -e`, so a scored run cannot pick it up by
  accident. **It loads.** `pi --mode rpc -e loop-stop.ts` exits 0 with
  no error on pi 0.84.3; the same command with a deliberately broken
  extension exits 1 and names the failure, so the check can tell the two
  apart. It has **not** been fired against a real loop yet.
- **T2.3 part 1, sampler facts** (`results/sampler-defaults.md`). Read
  from the running server: DRY and XTC exist, every repetition defence
  defaults to off, and `repeat_last_n` is 64 tokens. One bash tool call
  is longer than that, so the known negative for `repeat_penalty` never
  tested what it was aimed at.
- **T3.4, candidate shortlist** (`results/model-candidates.md`). Ranked
  by fit on this machine: Devstral Small 2 first. Nothing downloaded.
- **Three config changes as diffs** (`results/config-proposals.md`),
  none applied.

### Next, in order

1. T1.1 arm 2, `replay-llama.sh short` — chained, starts by itself.
2. T2.2, the Qwen3.8 ceiling re-probe. Needs the GPU, so it waits for
   both arms.
3. T2.3 part 2, whether DRY stops a loop. **Blocked by a dependency:**
   DRY is llama-server only, and if the llama-server arm does not loop
   there is nothing for DRY to act on. The only looping backend here is
   the LM Studio MLX path, which has no DRY.
4. T2.4 part 2, firing the loop stop on a real replay. Same dependency.

### Left on the machine

- `iogpu.wired_limit_mb=24000`, set by the owner. Resets on reboot.
- Desktop widgets are still OFF from run 1. Restore command in
  `../run1/results/restore.md`.
- Mendel worktree `../mendel-bench-run2-replay-embedded` and branch
  `run2-replay-embedded-issue-13`, holding the replay.
- Run 1 also left `../mendel-bench-repro-gemma-4-12b-low-guided` and
  `../choose-a-local-llm-research1`.
