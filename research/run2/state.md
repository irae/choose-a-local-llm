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
`results/container-audit.md`.** Two results.

1. Two different Gemma-4 chat templates sit in the cache and they
   disagree about what to emit after a tool response. The long one
   (in the unsloth GGUF, and inside `tokenizer_config.json` of the
   lmstudio-community MLX repo) opens a thought channel and does not
   close it. The short one (every `chat_template.jinja`, including the
   same LM Studio repo's own) emits nothing. One repo therefore ships
   both, and which runs depends on which file the loader reads. The
   dangling open matches the newline flood exactly. Which template is
   newer cannot be read from the local files, so the direction became a
   replay arm rather than a claim.
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

Early reading at 4 tool calls: 4 distinct, longest identical run 1. The
model recovered from its own failed grep by rewriting it, which is the
opposite of the loop. Too early to mean anything — both measured LM
Studio arms were already repeating by call 11-40.

The pi config is a pinned copy under `/tmp/run2/replay-embedded/pi-agent`
built by `results/make-replay-models.py`. **The owner's
`~/.pi/agent/models.json` was not touched.**

### Next, in order

1. T1.1 arm 2, `replay-llama.sh short` — the same replay with
   `--chat-template-file` pointing at the short template. Together the
   two arms separate the backend from the template.
2. T2.3, the sampler probe, on whichever server is up.
3. T2.2, the Qwen3.8 window arithmetic and ceiling re-probe.
4. T0.4 and T2.4, both code, no GPU.

### Left on the machine

- `iogpu.wired_limit_mb=24000`, set by the owner. Resets on reboot.
- Desktop widgets are still OFF from run 1. Restore command in
  `../run1/results/restore.md`.
- Mendel worktree `../mendel-bench-run2-replay-embedded` and branch
  `run2-replay-embedded-issue-13`, holding the replay.
- Run 1 also left `../mendel-bench-repro-gemma-4-12b-low-guided` and
  `../choose-a-local-llm-research1`.
