# LM Studio forensics — 2026-08-29 late session (Fable agent)

Scope: understand the "weird" GUI-load run, find what we can and cannot
control in LM Studio, and set the rules night 4 must follow. Nothing here
goes to the site. All probes ran on LM Studio 0.4.23 / mlx-engine 1.10.1,
model `google/gemma-4-12b` (gemma4_unified, MLX safetensors), 32 GB
machine, `iogpu.wired_limit_mb=24000`.

## Conclusion 1 — context length is NOT controllable for this model

Every control path was tested live tonight. Auto-fit wins in all of them.
Each test loaded the model and read `lms ps` (and the server log's
`context_fit` line):

| Path | Result |
|---|---|
| `lms load -c 100000` | CONTEXT = 158,464 (ignored) |
| `lms load --context-length 100000` | ignored |
| `lms load -c 4096` | ignored |
| REST `POST /api/v1/models/load` with `context_length` | accepted silently, ignored |
| REST with `contextLength` / `config` keys | rejected (`unrecognized_keys`) |
| Per-model file `.internal/user-concrete-model-default-config/google/gemma-4-12b.json` with `llm.load.contextLength` | ignored (restored from backup after the test) |
| `settings.json` `defaultContextLength` (8,192) | ignored (log shows `configured=8,192 fitted=158,464`) |

A full scan of `~/.cache/lm-studio` found no other file that stores a
context length. The per-model config path DOES work for other engines
(devstral, GGUF, pins 131,072 the same way), so this is specific to
gemma4_unified on mlx-engine.

**This falsifies night 3's "pinned" narrative.** The v2 sweeps believed
`lms load -c 158464` pinned the window. The flag did nothing; the number
matched only because it was copied from auto-fit. Auto-fit is
deterministic for a fixed wired limit, so the v2 results stay valid and
reproducible — but "pinned" was the wrong explanation, and night 4 block
3's plan (`lms load -c 262144`) cannot work.

`--parallel` IS honored (verified: loads with 2 and 4 both took effect).
`--gpu`, `--ttl` not re-tested; no reason to distrust them.

## Conclusion 2 — the full 262,144 context cannot fit on this machine

LM Studio's own `context_fit` math: `working_set=23.44GiB reserve=3.00GiB
baseline=6.28GiB full_kv=16384B/token prompt_inputs=7680B/token
attention=65536B/token rotating_peak=0.94GiB`. Per token that is 89,600
bytes. At 262,144 tokens the estimated peak is ~29.1 GiB, above the
23.44 GiB working set. Auto-fit solves for the safe ceiling and gets
158,464. Without sudo (not available tonight) the wired limit cannot
change, so 158,464 is a constant on this machine.

`lms load --estimate-only` is not trustworthy: it reported 8.83 GiB
(weights only, "Confidence: LOW") for a 262k request that the engine's
own math prices at ~29 GiB. Do not use it as a fit check.

## Conclusion 3 — the real ceiling data already exists in the night-3 logs

The owner's new criterion for LM Studio table rows: **the ceiling is the
onset of memory compression/swap**, the tok/s figure is from before that
onset, and the context-window column keeps the auto-fit estimate
(158,464; trained max 262,144 stays a footnote).

Cross-reference of `/tmp/mem-watch-gemma12-single.log` (20-s interval)
with the server log's per-step `Prompt cache restore` timestamps:

- Steps ≤49,087 tokens: no compression, no swap. Last clean step:
  **49,087 tokens at 30.53 tok/s**.
- 74,108-token step (prefill starts ~20:52): first heavy compression
  burst (47,366 pages ≈ 0.74 GiB at 20:52:52). Onset is inside this step.
- 98,089 and deeper: sustained heavy compression (bursts up to 232,576
  pages ≈ 3.6 GiB) plus swapouts from 131k on. The server keeps working
  (25.19 → 22.77 tok/s at 158k) but the system is in memory-pressure
  territory the whole time.

2-context alternating (`/tmp/mem-watch-gemma12-alt.log`): heavy
compression starts at the ~49.9k-per-context step (21:35). Combined
~100k tokens across contexts, consistent with the single-context onset.
Last clean step: ~33k per context.

So under the new criterion, for `google/gemma-4-12b` on LM Studio:
single context ceiling ≈ 74k-step onset (report "compression starts
between 49k and 74k"; clean figure 30.53 tok/s @ 49k); two parallel
contexts ≈ 50k each. No new sweep is required to fill the table row; a
short confirmation sweep (steps 41k, 49k, 57k, 65k, 74k with the
watcher) is enough to bracket the onset tighter if time allows.

## Explanation of the "weird" run's artifacts

- **Constant disk-cache eviction all night.** The prompt cache disk
  budget is ~25% of free disk (14.68-14.91 GiB cap with 59 GiB free).
  It sat at cap the whole session and evicted 2-4 GiB/min continuously.
  Within a sweep the restore still worked (cached_tokens climbed
  normally) until the deepest alt steps, where both 147k contexts forced
  full recomputes (`cached_tokens=0`, ~150k uncached, twice: 22:03 and
  22:23). Freeing disk space raises the cap proportionally.
- **The 22:44 fatal error** ("tokens to keep ... greater than the
  context length") was our own sweep script exceeding the 158,464 window
  because its chars/4 estimate undercounts. Known; not an LM Studio bug.
- **Duplicate instance event.** At 20:41 the CLI `lms load` created a
  second instance (`google/gemma-4-12b:2`) while the GUI copy from 18:08
  was still resident, then unloaded the `:2` copy ten seconds later. The
  surviving instance that served the v2 sweeps was the 18:08 GUI/JIT
  auto-fit load — one more reason "pinned" was an illusion.
- **First-pass 7.08 tok/s crash at 98,089 tokens**: still no direct
  data (no watcher then), but the v2 logs show 98k is exactly where
  sustained heavy compression lives. Transient compression/swap storm is
  now the best explanation; the dual-instance guess from night 3 has no
  supporting load event in the log at first-pass time.
- **JIT traps.** `justInTimeModelLoading=true` plus
  `jitModelTTL=1200s`: a request naming an unloaded model silently loads
  it with fresh auto-fit, and a GUI/JIT-loaded model can auto-unload
  after 20 idle minutes. For runs, always load explicitly via `lms load`
  and check `lms ps` before starting.
- **Guardrails are off** (`modelLoadingGuardrails.mode="off"`,
  `alwaysAllowLoadAnyway=true`). That is the "unsafe loading": no fit
  check at load time. With context uncontrollable it changes little for
  this model (auto-fit is itself conservative), but MLX allocates KV
  lazily, so a load that "succeeds" proves nothing about deep-context
  safety.

## Thinking toggle — closed

Re-tested under fully idle conditions (the open watch-list caveat):
`chat_template_kwargs: {enable_thinking: false}` still produced 1,037
reasoning tokens (control request: 1,161). **The toggle does not work;
thinking is always on for `google/gemma-4-12b` via LM Studio.** The
watch-list item can close. Consequence: the thinking-on EvalPlus run
needs no special request body.

## Qwen3.8-27B notes found during the scout

- `.internal/user-concrete-model-default-config/qwen/qwen3.8-27b.json`
  already exists with custom fields
  `ext.virtualModel.customField.qwen.qwen3.827b.reasoningEffort:
  "medium"` and `...preserveThinking: false` — the owner touched this
  model in the GUI before. The weights are NOT downloaded (`lms ls`
  shows only gemma-4-12b).
- Reasoning effort likely also maps to the OpenAI-style
  `reasoning_effort` request parameter; night 4 must verify "low"
  actually changes `reasoning_content` length before trusting it, given
  how request parameters failed for gemma.

## State left behind

Server running on port 8081, no model loaded, no watcher or Monitor
processes. The per-model gemma config file was restored from backup
(`/tmp/gemma-4-12b.default-config.bak.json` kept).
