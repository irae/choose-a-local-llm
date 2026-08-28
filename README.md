# Finding the best local coding model for your machine

A repeatable process to answer, for one specific computer: which local model +
runtime should I code with? It measures three axes — max context for one session,
max decode speed, and best multi-session (concurrent sub-agents) setup — then
verifies code quality per quantization with a benchmark gate. Everything runs
against OpenAI-compatible servers a coding harness can actually use.

This repo is the worked example for one machine (an Apple Silicon Mac; specifics
at the bottom), but the process applies to any box: substitute your memory budget
and your candidate models.

## The flow — rules for every step

This is the methodology. Every test cycle follows all of these; do not skip steps.

1. **One model on the GPU at a time.** Fresh server start per configuration. Long
   runs go in background tasks.
2. **Warmup first.** Send a discarded warmup request; measure only after it.
3. **Fixed prompts**, temperature 0, fixed token count (we use 256), identical
   across every model and config:
   - py: `Write a Python function that parses ISO dates.`
   - js: `Write a JavaScript function that deep clones an object.`
   Two languages matter: speculative-decoding acceptance differs by language, so a
   single-prompt benchmark can mislead.
4. **Read the server's own timings, not wall clocks**, where available.
   llama-server: `.timings` from `/completion` (`prompt_per_second`,
   `predicted_per_second`, `draft_n`, `draft_n_accepted`). mlx-lm: the
   `Prompt:`/`Generation:` tokens-per-sec lines.
5. **Find context maxima by probing, not by spec sheet.** Raise the allocated
   context in fixed steps (we use 8K) until the GPU OOMs
   (`kIOGPUCommandBufferCallbackErrorOutOfMemory` on Metal); record RSS/peak
   memory per step. Reserve headroom for the OS and whatever else the machine
   runs (we keep ≥5 GB). A config that loads but decodes degraded (tok/s
   collapse) counts as failed. Speculative decoding: sweep the draft depth per
   model AND per mode — the optimum shifts with output style (thinking on/off).
6. **Record each result on every surface in the same pass** — a result is not
   recorded until all agree: the model's `benchmarks-*.md` (full data), its HTML
   report **including the summary KPI boxes at the top** (they go stale easily),
   the cross-model `comparison.html`, and the harness config (ours:
   `~/.pi/agent/models.json`). Every server config gets a copy-paste command box
   in its HTML whose alias equals the harness model id.
7. **After tests, always check for leftovers and clean up**: look for stray
   server processes (`pgrep -fl "llama-server|mlx_lm"`), kill them, verify no
   background task still holds the GPU. End every session/batch with the machine
   idle.
8. **KV cache policy: 8-bit (q8_0) is the default** on memory-constrained
   machines — near-lossless (we verified byte-identical outputs vs f16 at
   temperature 0), and the context it unlocks overrules f16's ~1% speed edge.
   Mention f16 only as a secondary option. Deeper KV quantization (q4_0) is
   banned for quality. **Every published config uses q8 — no exceptions**, even
   configs limited by the model's trained window: under the current wired limits
   those also need the KV savings (Gemma-26B's 256K window fits only with q8).
   Caveat to measure per model: q8 can lower MTP draft acceptance and with it
   decode speed (Gemma-26B js: 81% → 68%, ~72 → ~53 tok/s; Gemma-12B py:
   f16 was +5.5 tok/s).
9. **API-or-nothing.** A config qualifies only if it serves an HTTP API a
   harness/agent can use. CLI-only paths are disqualified — benchmark them only
   as a rare, explicitly-approved curiosity; their numbers stay in markdowns,
   never in HTML reports.
10. **Keep thinking-on AND thinking-off data, both labeled — never replace one
    with the other.** The target harness setup is mixed: the main agent thinks
    (debugging, decisions), sub-agents run thinking-off (clear instructions, max
    speed). HTML tables show thinking-on; thinking-off goes in note text.
11. **Benchmark scripts must reuse the server's prompt cache perfectly.** Grow
    prompts append-only: each request's prompt = the previous prompt + the
    server's own generated reply + the new text. Never insert or change text
    before an existing prefix mid-run, and never end prompts with a fixed
    suffix that later steps insert before — that breaks reuse and reprocesses
    the whole prompt every step. llama-server reuses any longest common
    prefix; mlx_lm.server only reuses strict extensions of its cache state,
    so append-only is the one scheme that works everywhere. Verify reuse in
    llama's `.timings.prompt_n` (must be roughly the delta, not the total).
    This rule binds every unattended night run.
12. **Downloads: sequential, one at a time** on slow connections, needed-first
    order, never during meetings. GPU benchmarks may run while a download is in
    flight, but max-context tests need the machine alone. Download only the exact
    files needed (`--hf-file` / `hf_hub_download` — repos often bundle huge F16
    variants you don't want).

## Runtimes (mainstream only, CLI)

- **llama-server** (llama.cpp). The concurrency backbone: slots share one weight
  copy — `--parallel N -c TOTAL` gives N slots of TOTAL/N each. Supports MTP
  speculative decoding (`--spec-type draft-mtp`).
- **mlx_lm.server** (mlx-lm, Apple Silicon). Often faster decode per request, but
  no slots (one request at a time, requests queue) and no preallocated context.
  **Parallel serving runs on llama-server only** — N mlx instances mean N weight
  copies and per-agent port wiring (measured, ruled out).
- No forks, no `--HEAD` builds, no GUI-first tools. Rolling prebuilt binaries of
  llama.cpp master exist but are master-channel — waiting for stable releases
  avoids maintaining a sideloaded toolchain.

## How we picked models (reasoning to reuse)

- **Prefer MoE on bandwidth-limited hardware.** Decode speed scales with *active*
  parameters: a 35B-total/3B-active model decodes ~4× faster than a dense 27B at
  comparable quality. The two MoE candidates ended up dominating every speed axis.
- **Prefer models with MTP (multi-token prediction) support** — it stacks with
  MoE and is output-lossless, so it is free speed. Check that the GGUF repo
  embeds the MTP tensors or ships a draft-model file.
- **Take the newest strong models even if slow** — reviewers' consensus matters;
  benchmark them anyway and let the quality gate decide.
- **One compressed-frontier experiment at a time** (ours: ternary Bonsai) —
  extreme quantization claims need local verification before trusting them.
- **Use the most popular mainstream quant repos** (check HF download counts);
  verify exact file lists before downloading.
- **Per-quantization scoring**: published benchmarks cover full-precision models.
  What you run is a quant — quality must be measured per quant, not per model.

## Code-quality gate (EvalPlus, then Aider)

Two tiers. Tier 1, **EvalPlus (HumanEval+ / MBPP+)**: cheap, execution-verified,
sensitive to exactly the damage quantization does. It is a **gate, not a
ranking** — every model that scores well advances. It says nothing about
long-context or harness behavior. Tier 2, for gate survivors: the **Aider
polyglot benchmark** (225 Exercism problems, 6 languages, 2 attempts with test
feedback, docker-run against your servers) — hours per model, so only survivors.

Gate mechanics: temperature 0, pass@1, small **prompt** context (problems are
tiny, single-turn, no compaction involved — prompt context size does not
affect scores). Serve each config through its fastest runtime (MTP never
changes outputs, so it is fair). Score thinking-on for fair comparison with
published numbers; a thinking-off pass is worthwhile where sub-agent
(thinking-off) use is planned.

**`max_tokens` (output budget) is a different axis from prompt context, and it
does affect scores.** An earlier version of this rule said "~3072 is generous"
and lumped it in with the context-doesn't-matter point above — that was wrong.
Verified 2026-08-26 on night 1: Ternary Bonsai burned ~4,500+ tokens of
reasoning on a single HumanEval problem before ever starting its answer; at a
3072 cap, over 40% of its later completions came back with empty content
(all-reasoning, no room left to answer) — a harness ceiling masquerading as a
model failure. Set `max_tokens` high enough that a thinking-heavy config never
hits it (test this per model, don't assume one number fits all — a compressed
or heavily-quantized model can need much more room to reach a conclusion, and
this can worsen over a long run rather than staying constant). A tight cap
truncates mid-thought and falsely tanks scores.

Record clean-run timing per config if convenient (wall-clock of the final,
successful attempt, excluding restarts/bugfixing) — it's a secondary,
approximate signal, not something to chase precision on. pass@1 is the score
that matters; don't spend effort making timing exact.

---

# This machine — M1 Max, 32 GB

- `sudo sysctl iogpu.wired_limit_mb=25000` (resets on reboot) — required for the
  big-context configs. On 32 GB, 27000 was too much: the machine became too slow
  for normal use. 24000 gave too little context (Qwen3.6-35B capped at 40K).
  25000 is the current compromise. Context maxima measured under 27000 need a
  re-probe at 25000; Qwen3.6-35B and Gemma-26B are re-probed so far.
- Decode speed drops at deep fill (~17 tok/s measured at 31K used tokens, vs
  62-68 near-empty). Accepted: the initial session is where speed matters most.
  A filled-context check belongs in every context probe; allocation alone
  overstates what is usable.
- Servers always on port 8081 (8080 is the DB admin UI). Harness: pi
  (`~/.pi/agent/models.json`).

## Models under test

| model | files | reports |
|---|---|---|
| Qwen3.6-35B-A3B (MoE) | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` | `benchmarks-qwen3.6-35b-a3b.md`, `report-qwen3.6-35b-a3b.html` |
| Gemma-4-26B-A4B (MoE) | `unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL` + `mtp-gemma-4-26B-A4B-it.gguf` | `benchmarks-gemma-4-26b-a4b.md`, `report-gemma-4-26b-a4b.html` |
| Qwen3.8-27B | `bartowski/Qwen3.8-27B-GGUF:Q4_K_M`, `mlx-community/Qwen3.8-27B-4bit` (+ `-MTP-4bit` draft) | `benchmarks-qwen3.8-27b.md`, `report-qwen3.8-27b.html` |
| Ternary Bonsai-27B | `prism-ml/Ternary-Bonsai-27B-mlx-2bit` (GGUF Q2_0 parked — needs next llama.cpp release) | `benchmarks-bonsai-27b.md`, `report-bonsai-27b.html` |
| Gemma-4-12B-it | `unsloth/gemma-4-12b-it-GGUF:Q4_K_XL` | `benchmarks-gemma-4-12b-it.md`, `report-gemma-4-12b-it.html` |

1-bit Bonsai is out of scope (deleted). Cross-model summary: `comparison.html`.

Model thinking controls: Gemma 4 = binary `enable_thinking`, default OFF.
Qwen3.6 family (incl. Bonsai) = binary, default ON. Qwen3.8 = graded effort
(`low`/`medium`/`xhigh`).

## EvalPlus night plan

**Standing rule: every unattended night run must include a heartbeat.**
Right after starting any long-running block, schedule a wakeup no more than
20 minutes out. On each wakeup, confirm real progress happened since the
last check (for example: the sample count grew), not just that the process
is still alive — a stuck process can stay alive while making zero progress.
If progress did not happen, treat the block as dead: stop it, restart it,
and record the incident. Verified necessary on night 2 (2026-08-27): a
run with no heartbeat check sat silently retrying one request for 52
minutes with zero progress before anyone noticed.

**Night 1** — user-decided order (rationale: Bonsai reportedly stacks well with
Qwen3.6-35B MoE; Gemma is regarded as grunt-agent tier — good executor, weaker on
hard tasks — but its 256K window keeps it in play):
1. Qwen3.8 MLX 4-bit at `reasoning_effort=medium`, `mlx_lm.server` (~3 h).
2. Qwen3.6-35B-A3B (llama+MTP, thinking on, ~1 h).
3. Ternary Bonsai (mlx_lm.server, ~2.5 h).
4. Gemma-4-26B-A4B (llama+MTP, thinking on, ~45 min).
5. Gemma-4-12B (llama+MTP, thinking on, ~1.2 h).
Total ~8.5 h; overflow slips to night 2.

**Night 2** (kit: `night2/NIGHT-AGENT.md`): fix the token-budget flaw and get
fair scores. Phase A calibrates a per-model `max_tokens` (10-problem sample at
a 30K cap, budget = observed max × 1.5). Phase B corrects the three night-1
scores cheaply — at temperature 0 only the empty completions need
regenerating. Phase C scores the two Gemma configs fresh. The executor may
invent fixes for unforeseen problems; fairness rules and limits are in the
runbook.

**Night 3 candidates**: Qwen3.8 GGUF on llama-server, xhigh, production
single-slot config; a thinking-off pass for sub-agent configs.

Night kit: `night1/` — small single-purpose scripts (env check, EvalPlus install,
one server script per block, `run-humaneval.sh`, `progress.sh`, cleanup) plus
`night1/NIGHT-AGENT.md`, the prompt for the overnight agent that runs the list,
retries failed blocks, and keeps a 20-minute `ScheduleWakeup` heartbeat.

## Current state (2026-08-25, end of day)

Speed and context axes fully measured for all five models, q8-KV maxima included —
see `comparison.html`. Headlines: Gemma-26B 256K @ 62 (q8 KV); Gemma-12B 4×256K
slots; Qwen3.8 160K @ ~15; Qwen3.6-35B 68/74 peak.
The wired limit moved from 27000 (machine too slow) to 24000 (too little context)
to 25000 (current). Qwen3.6-35B re-probed at 25000: max context 96K at 62-68
tok/s near-empty, ~17 tok/s at deep fill (accepted). At 24000 it was 40K with no
multi-slot config. Multi-slot at 25000 is untested. The other models' context
maxima still assume 27000 and need a re-probe.
Gemma-26B re-probed at 25000: the full 256K window still fits on one slot but
now needs q8 KV (f16 OOMs) — 62 py / 53 js tok/s (q8 lowers js draft
acceptance); two slots reach 2×184K.
**Pending (not today): re-test the remaining model/config combinations under the
new `iogpu.wired_limit_mb` regime** — every context and multi-slot maximum for
Gemma-12B, Qwen3.8, and Bonsai was measured at 27000 and must be re-probed (and
deep-fill checked) at 25000, or at whatever limit wins. Deep-fill checks for
Qwen3.6-35B at 96K and Gemma-26B are also pending.
Open: the EvalPlus nights; ternary Bonsai GGUF when
llama.cpp ships Q2_0 support; optionally Gemma-on-MLX and unsloth's Qwen3.8 GGUF
(more popular than bartowski's; verify it embeds the `nextn` MTP tensors before
switching).
