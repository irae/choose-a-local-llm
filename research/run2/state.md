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
- **The flood, read from LM Studio's server logs**
  (`results/flood-shape.md`). Only ONE flood survives in any log from
  June to September; run 7's three are gone from this source. It sits in
  `reasoning_content`, ends with a bare `<|channel>`, and follows the
  runner's model nudge, not a tool response. n=1, labelled as such.
  Records a counting trap: 119 "floods" were 119 re-sends of one
  message, because every request body carries the whole history.
- **The pre-fix template corrupts OpenAI-shaped tool calls**
  (`results/container-audit.md`, finding 1d, tool
  `results/render-templates.py`). Given `arguments` as a JSON string it
  emits raw JSON where Gemma expects its own key-value form, and says
  nothing. The post-fix template refuses that input instead. Upstream
  `mlx_lm.server` deserializes first and escapes; what LM Studio's engine
  does is the open question, and the probe is written down.
- **IOAccelerator is the wrong meter for llama-server too**
  (`results/context-ramp.md`), closing a run 1 open question. It read
  9 MB while the server held 13.6 GB wired.

### Blocked, with the reason

- **The LM Studio probe is NOT run tonight, on purpose.** The question
  it answers is the highest-value one left: does the LM Studio MLX
  engine read the stale `chat_template.jinja` or the current inline
  template, and does it deserialize `function.arguments` before
  rendering. It needs a Gemma-12B loaded in LM Studio. Run 1's kernel
  panic came from LM Studio load and unload cycles of that exact model
  with a client connecting, and a panic while the owner sleeps would
  reboot their Mac and end the night. It is a five-minute check with the
  owner present. It is the first item for the next session.
  Static analysis was tried and does not settle it: the LM Studio main
  bundle references BOTH `chat_template.jinja` and the inline
  `chat_template`, so both readers exist, but the bundle is minified with
  a string table and the precedence cannot be read out of it. The MLX
  engine native module is stripped and names neither.

- **T2.3 part 2 and T2.4 part 2 are blocked by their own dependency.**
  DRY is llama-server only, and arm 1 shows llama-server does not loop,
  so there is nothing on that backend for a sampler or a loop stop to
  act on. Both tools are built and one is load-tested; neither can be
  fired at a real loop until a looping backend is available.

### Next, in order

1. T1.1 arm 2, `replay-llama.sh short` — chained, starts by itself.
2. T2.2, the Qwen3.8 ceiling re-probe. Needs the GPU, so it waits for
   both arms.
3. T2.3 part 2, whether DRY stops a loop. **Blocked by a dependency:**
   DRY is llama-server only, and if the llama-server arm does not loop
   there is nothing for DRY to act on. The only looping backend here is
   the LM Studio MLX path, which has no DRY.
4. T2.4 part 2, firing the loop stop on a real replay. Same dependency.

### Verification note

`npm run verify` was NOT run in this session. Two reasons, both
checkable: this branch changes 27 files and every one is under
`research/`, with nothing under `docs/`, so the site build cannot be
affected; and `node_modules` is absent in this worktree, so verifying
would mean an install competing with the GPU run for CPU and network.
**Run it before this branch merges to master.**

### Left on the machine

- `iogpu.wired_limit_mb=24000`, set by the owner. Resets on reboot.
- Desktop widgets are still OFF from run 1. Restore command in
  `../run1/results/restore.md`.
- Mendel worktree `../mendel-bench-run2-replay-embedded` and branch
  `run2-replay-embedded-issue-13`, holding the replay.
- Run 1 also left `../mendel-bench-repro-gemma-4-12b-low-guided` and
  `../choose-a-local-llm-research1`.


---

## Session 1 close — 2026-09-04

Ran unattended through the night on the owner's standing orders: keep
the GPU busy, never halt, commit blocks and move on, ask nothing.

### What the session was for, and what it found

The run's central question was section D: does the Gemma-12B failure
belong to the model or to the serving path. **It belongs to the chat
template, and that is now demonstrated rather than argued.**

Three arms, everything held fixed but one variable each, each proved
from its own live server with `POST /apply-template`:

| Arm | Template | Sampler | Repetition loop |
| --- | --- | --- | --- |
| 1 `embedded` | post-fix (Google, after 2026-07-15) | defaults | **none**, shape-run 2 |
| 2 `short` | pre-fix (Google `657684f`, 2026-06-03) | defaults | 498 identical thinking lines |
| 3 `short-dry` | pre-fix | DRY 0.8, window 2048 | repetition loop moved into a tool call |

Arm 1 committed three dependency removals and left a clean tree. Arm 2
committed nothing. The container audit then showed why this matters
here: **every Gemma-4 MLX container on this machine ships the pre-fix
template**, and `AutoTokenizer` resolves to it, so the published
Gemma-12B rows were measured on the failing configuration.

The second result is about defences, not causes. DRY did not stop the
repetition loop; it changed its shape and its channel. That is an argument
against shipping a sampler fix and for the harness STOP the coordinator
proposed — with the caveat that a STOP counting identical calls would
fire later on arm 3 than on arm 2, though arm 3's output is worse.

### Instruments built, because each earlier one was blind

`count-events.py` (identical calls), `flood-check.py` (newline runs),
`measure-repeat-run.py` (identical lines) and `measure-neardup.py` (same
shape after normalising letters and digits). The last was needed twice
over: a prefix comparison reported 10 where the truth was hundreds,
because the model's own counter defeated it, exactly as it defeated DRY.
`count-events.py` reproduces run 1's published numbers on run 1's
archived session, so the family is calibrated against an independent
count.

### Errors made in this session, recorded

- A shell script was edited while bash was still reading it. Arm 1's
  cleanup aborted at end of file; the server was left up and the
  evidence unarchived, both fixed by hand within a minute. No
  measurement was affected. **Never edit a running script.**
- A monitor's own command text contained `llama-server`, so the chain's
  `pgrep -f llama-server` matched the monitor and would have waited
  forever for a server that was already dead. Caught before it cost the
  night. All monitors now use bracketed patterns.
- The first flood detector fired on HTML that `curl` fetched into a tool
  result. Tool results are not model output.
- The llama.cpp build was named as a candidate for the speed gap. It is
  not: `/props` reports `b10621-c1d0e7a00`, exactly the build the
  published page cites. Corrected in two files.
- "119 floods" in an LM Studio log were 119 re-sends of one message,
  because every request body carries the whole history. Corrected.

### Not done, and why

- **The LM Studio engine probe.** The highest-value question left: does
  its MLX engine read the stale `chat_template.jinja`, and does it
  deserialize `function.arguments` before rendering. It needs a
  Gemma-12B loaded in LM Studio, and run 1's kernel panic came from that
  exact model's load and unload cycles with a client connecting. Not run
  while the owner sleeps. Five minutes with them present. **First item
  next session.** Static analysis was tried and cannot settle it.
- **Firing `loop-stop.ts` at a real repetition loop.** It counts identical tool
  calls; both loops here are inside one unfinished call or in
  thinking. A different design is needed.
- **Re-quantization A/B.** Needs original weights, a large download.
- **`npm run verify`.** Nothing under `docs/` changed and `node_modules`
  is absent here. Run it before this branch merges.

### Left on the machine

- `iogpu.wired_limit_mb=24000`, set by the owner. Resets on reboot.
- Desktop widgets still OFF from run 1. Restore command in
  `../run1/results/restore.md`.
- Three mendel worktrees and branches, all holding replay evidence:
  `run2-replay-embedded`, `run2-replay-short`, `run2-replay-short-dry`.
- Run 1's leftovers: `../mendel-bench-repro-gemma-4-12b-low-guided` and
  `../choose-a-local-llm-research1`.
- This worktree, `../choose-a-local-llm-research2`, branch `research2`.
- Evidence in `~/.local/share/choose-a-local-llm/evidence/run2-*`.
