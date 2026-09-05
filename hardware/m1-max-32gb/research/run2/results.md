# Research run 2 — results

Summary table. Detail is in `results/`, the running log is in
`state.md`, the ranked list the owner approved is in
`results/experiments.md`.

Session 1: 2026-09-04, night, unattended. Machine rebooted before it
started, `iogpu.wired_limit_mb=24000`, zero swap for the whole session.

## ATTENTION, coordinator — read `results/two-gemma-entries.md` first

Two different LM Studio entries were treated as one model. The best
Gemma-12B score (0.909/0.872, 100% completion) comes from
`gemma-4-12b-it-mlx`, where thinking is off and cannot be turned on. The
0.622 row and **all three Mendel rows** come from `google/gemma-4-12b`,
which is not in the model store today. Two config blocks in the report
say the good config is not reproducible; a probe on 2026-09-04 shows it
is. The owner asked for the planner's full attention on this before the
site settles anything about Gemma-12B.

## Owner decision, 2026-09-04

**Gemma-4-12B on MLX or LM Studio is ruled out for thinking-on agentic
work.** No further item in this run chases that combination. GGUF
Gemma-12B stays in scope. Reasoning and sources in
`results/gemma12-verdict.md`.

Consequence for the planner: **all three Gemma-4-12B Mendel rows are
LM Studio**, so every scored Gemma-12B agent number sits on the ruled-out
combination, and no GGUF Gemma-12B agent row exists. A GGUF Mendel run is
requested — this run does not schedule scored benchmarks.

## For the planner, first

**GGUF / llama-server rows are KEEPERS on template grounds. MLX /
LM Studio multi-turn rows are the SUSPECT ones. Every EvalPlus row is a
keeper, on either backend.** Evidence and the strength of each verdict
are in `results/row-verdicts.md`.

## Gemma-12B is closed, 2026-09-04

**Usable configuration for agent work: llama-server, f16 KV, no MTP,
thinking off.** It reaches Gemma's own 262144 trained window still above
the 8 tok/s floor, sits flat at 59% of the iogpu cap, and on the Mendel
probe (xtend) it made 42 tool calls and committed working code.

**Not usable for agent work: LM Studio / MLX, either thinking state.**
Faster at every depth it survives (1.8x at 131K) but stops on swap growth
at 147K with wired at 87% of the cap, and on the same probe with thinking
OFF it looped 2679 lines on the thought channel and committed nothing.

**The q8 KV default is what made this model look slow.** q8 falls through
the floor by 16K; f16 holds to the window. Detail in
`results/gemma12-depth.md`, `results/mendel-probe-xtend.md`, asks in
`results/planner-notes.md`.

## Findings

| # | Item | Status | Finding | Detail |
| --- | --- | --- | --- | --- |
| T1.1 | Gemma-12B replay on llama-server, five arms | done | **CORRECTED.** Pre-fix template looped 3 of 3; post-fix looped **1 of 2**. The fixed template does NOT prevent the loop — the second control refuted the claim the first control carried. Matches HF discussion 41, which reports the loop at F16 and so model-level. | `results/replay-llama.md` |
| T1.1 | Pre-fix template arms | done | Both looped: 498 identical thinking lines in one, a two-line cycle in the other. Zero and one commits. | `results/replay-llama.md` |
| T0.1 | Gemma-4 chat templates | done | **Every local MLX container ships the template Google replaced on 2026-07-15 to fix the thought loop.** The LM Studio container carries the stale jinja file AND the current inline copy; transformers resolves to the stale one. | `results/container-audit.md` |
| T0.1b | Pre-fix template and OpenAI tool calls | done | The pre-fix template silently renders raw JSON where Gemma expects its own key-value form. The post-fix template refuses that input instead. llama-server deserializes first and escapes it; LM Studio's engine is unverified. | `results/container-audit.md` |
| T0.2 | Quantized-PLE defect | done | **Does not reproduce.** Our Gemma-4 MLX quants hold no per-layer embedding tensor at all. They do keep `embed_tokens` at 4 bits where the QAT repo protects it at 8. | `results/container-audit.md` |
| T0.3 | Instruction sets and KV policy | done | `FEAT_DotProd` yes, `FEAT_I8MM` no, as assumed. The only q4 KV in a published config is the Bonsai fork, paired with a calibration bias file built for q4. | `state.md` |
| T0.4 | Prompt-cache health | done | All three backends answer with the same `cached_tokens` field and pi records it per turn, so no server work was needed. Live runs read 90-98 percent. Alert rule proposed. | `results/prompt-cache-telemetry.md` |
| T2.1 | llama.cpp context ramp with the MTP drafter | done | **The drafter does not fail at 262144.** All ten arms loaded and served, `-ngl 999` and `--fit on` alike, 13.6 GB wired at the top. Speed reads 27.3 tok/s against a published 45.0. | `results/context-ramp.md` |
| T2.1b | IOAccelerator as a memory meter | done | **Useless for llama-server too**, closing a run 1 question. It read 9 MB while the server held 13.6 GB wired. | `results/context-ramp.md` |
| T2.2 | Qwen3.8 window arithmetic | proposed | `maxTokens` 16384 and `contextWindow` 26624 cannot both hold past a 10240-token prompt. Diff proposes 8192. | `results/config-proposals.md` |
| T2.2b | Qwen3.8 ceiling re-probe | done | **Ceiling is between 26708 and 28672 at wired 24000**, so the declared 26624 sits ~84 tokens below the last success. Thin, not wrong. The step past it reproduced section E's dead-thread bug live: Metal OOM inside `mx.eval`, generation thread dead, process alive. The log caught it; `/health` would not have. | `results/qwen38-ceiling.md` |
| T2.3b | DRY against the repetition loop, arm 3 | done | **DRY does not stop the repetition loop, it hides it.** 1133 shape-identical `ls -d` lines inside ONE tool call generated over 70 minutes, every path corrupted, then rejected by pi for hitting the output limit. The model recovered three minutes later. Every exact-match detector read it as clean. | `results/dry-arm.md` |
| — | Arm 2 repeat, second observation | running | Started 10:32Z, 100-minute wall. The template result rests on one run per arm; this is the cheapest strengthening. | `results/replay-llama.sh short-repeat` |
| — | No-MTP speed baseline | done | **26.15 py / 26.17 js against a published 22.3 — faster.** That clears the machine, the build and the wired limit together. The whole py gap is drafter effectiveness: 1.22x here against a published 2.02x. | `results/kv-speed.md` |
| P3 | KV type speed A/B | done | **The KV type is not the gap.** f16 beats q8_0 by 4.6 tok/s, exactly the page's own estimate, and costs 2.1 GB at 262K. But our js reads 32.84 against a published 31.3 — faster — while only py is short. A slow build would slow both. Likely cause: MTP draft acceptance, which no published row records. | `results/kv-speed.md` |
| — | Repetition repetition loop detector | built | Finds the shape the newline check and the tool-call counter both miss: well-formed prose repeated inside the thought channel. Exits non-zero at five identical lines. | `results/measure-repeat-run.py` |
| — | Near-duplicate repetition loop detector | built | Needed because DRY makes every repeated line unique. Normalises letters and digits to a shape, so an incrementing counter cannot hide. Separates all three arms: 2/5 clean, 498 and 1133 looped. | `results/measure-neardup.py` |
| T2.3 | Sampler defaults | done | DRY and XTC exist on this build; every repetition defence is off; `repeat_last_n` is 64 tokens, shorter than one tool call. So the known negative for `repeat_penalty` never tested what it aimed at. | `results/sampler-defaults.md` |
| T2.4 | Loop stop as a pi extension | built | Ends the run on N identical consecutive calls; never edits a result. Loads cleanly under pi 0.84.3, verified with a negative control. | `results/loop-stop.ts` |
| — | The newline flood | done | Only ONE flood survives in any LM Studio log. It sits in `reasoning_content`, ends with a bare channel-open token, and follows the runner's model nudge, not a tool response. n=1, and a counting trap is recorded. | `results/flood-shape.md` |
| — | Model revisions | done | Pinned. **The Gemma-12B copy LM Studio serves has no revision reference at all.** | `results/model-pins.md` |
| T3.1 | Bonsai thinking level | proposed | `low` maps to null on both Bonsai entries, so the scheduled level was unreachable. Thinking off is reachable and is the published best row, 0.927/0.902. | `results/config-proposals.md` |
| T3.4 | New model candidates | done | Ranked by fit here: Devstral Small 2 first. Nothing downloaded. | `results/model-candidates.md` |
| E | Liveness watchdog | built | Probes a real completion only after the run's own output stalls, so it does not compete for the single slot. Smoke-tested. | `results/liveness-watch.sh` |

## Blocked, with reasons

| Item | Why |
| --- | --- |
| The LM Studio engine probe | Needs a Gemma-12B loaded in LM Studio. Run 1's kernel panic came from that model's load and unload cycles with a client connecting, so it is not run unattended. Five minutes with the owner present. First item next session. |
| ~~DRY against a real loop (T2.3 part 2)~~ | **UNBLOCKED by arm 2.** llama-server does repetition loop, on the pre-fix template, and DRY exists there. Arm 3 (`short-dry`) is queued: arm 2's exact configuration with `--dry-multiplier 0.8` and a 2048-token window, against the 64-token default that could never see a repeat. |
| Firing the loop stop (T2.4 part 2) | Still blocked, but for a narrower reason. The repetition loop is inside the thought channel, not in tool calls, and `loop-stop.ts` counts identical tool calls. It would not fire on arm 2. A thinking-channel stop is a different design. |
| ~~Re-quantization A/B (T3.3)~~ | **Rescoped by the owner on 2026-09-04** (master `8314735`): no weight transformation of our own. Section C is now a survey of PUBLISHED quants, shortlisted for approval, with downloads allowed in this run. Survey in `results/quant-survey.md`. |

## Changes proposed, none applied

Four, all in `results/config-proposals.md`: the Qwen3.8 window
arithmetic, the Bonsai thinking level, a llama.cpp speed re-probe, and
promoting the liveness watcher to a shared tool. A fifth, replacing the
stale `chat_template.jinja` in the Gemma-4 containers, is in
`results/container-audit.md` — it changes a container behind published
rows, so it is the owner's decision.
