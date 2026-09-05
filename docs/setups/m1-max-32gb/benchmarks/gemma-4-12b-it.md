# Gemma-4-12B-it Q4_K_XL on M1 Max 32 GB — llama-server benchmarks

Build: llama-server 0.3.0 (build 10621, commit c1d0e7a00), Metal.
All runs: temperature 0, `n_predict` 256 unless noted. Fresh server start per config.
Sections dated 2026-08 were measured at `iogpu.wired_limit_mb=27000`; sections dated 2026-09 at 24000. Each section states its own era.
MTP works: the unsloth repo ships a separate draft model (`mtp-gemma-4-12b-it.gguf`) and llama-server loads it automatically with `--spec-type draft-mtp`.

## Recommended configuration (2026-09-04, wired limit 24000)

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

- **f16 KV.** At 16,411 used tokens f16 decodes 22.66 tok/s against q8_0's
  6.53 — 3.2x, and q8_0 is already under the 8 tok/s floor there. The KV
  policy makes q8_0 the default for the context it unlocks; on this model
  f16 costs no context, because it holds 262,144 inside the wired limit.
- **No MTP drafter.** The drafter buys short-prompt speed and costs depth:
  dropping it gained 22% at 8K and 9% at 16K.
- Context is **model-limited, not memory-limited**: 262,144 is the trained
  maximum, and wired memory sits flat at 14,186 MB, 59% of the limit, from
  load to the window.
- Thinking off. Thinking on is a pitfall of this model on both backends —
  see the retired-entry section below.
- Sub-agent variant: `--parallel 2 -c 524288` gives 2×256K slots at 16.9 GB
  RSS (measured 2026-08 at the retired 27000 limit).
- Reasoning effort: not applicable — the chat template reports `supports_reasoning_effort: false`.

Base startup command (flags that change per run are shown in each section):

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b-it --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 32768 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

Prompts:

- **py**: `Write a Python function that parses ISO dates.`
- **js**: `Write a JavaScript function that deep clones an object.`

## Thinking

Gemma 4 has trained-in binary thinking (`<|think|>`, `enable_thinking` in the chat template, default OFF, no effort levels). All sections below except the one marked "thinking ON" were measured with thinking off (raw `/completion` prompts).

## MTP sweep — thinking ON — chat endpoint, `enable_thinking: true`, 1024 tokens, 32K, f16 KV

| n-max | py tok/s | py accept | js tok/s | js accept |
|---|---|---|---|---|
| **3** | **35.00** | 694/985 (70%) | **35.55** | 700/969 (72%) |
| 4 | 33.34 | 735/1152 (64%) | 33.91 | 739/1135 (65%) |
| 6 | 26.80 | 784/1429 (55%) | 25.92 | 776/1477 (53%) |

Thinking-on peak is n-max 3 (thinking-off peak is n-max 4): thinking text drafts worse, so shallower wins. Mixed-agent guidance: use n=3 for a thinking main-agent server, n=4 for thinking-off sub-agent slots.

## Baseline — no MTP (no `--spec-type` flags)

| prompt | pp tok/s | decode tok/s | draft_n | accepted |
|---|---|---|---|---|
| py | 45.3 | 22.27 | – | – |
| js | 48.6 | 22.16 | – | – |

## MTP sweep — q8_0 KV, 32K context

| n-max | py tok/s | py accept | js tok/s | js accept |
|---|---|---|---|---|
| 1 | 24.26 | 126/129 (98%) | 22.42 | 114/140 (81%) |
| 2 | 24.90 | 167/174 (96%) | 21.91 | 155/198 (78%) |
| 3 | 37.90 | 188/199 (94%) | 31.30 | 174/242 (72%) |
| 4 | 39.49 | 201/216 (93%) | 31.06 | 186/274 (68%) |
| 6 | 36.37 | 215/238 (90%) | 26.53 | 200/327 (61%) |
| 7 | 38.42 | 219/246 (89%) | 27.69 | 205/345 (59%) |

Peak: n-max 4 for Python; js ties between 3 and 4. n-max 4 chosen (best py, js within noise).

## KV cache: q8_0 vs f16 at n-max 4

| KV type | py tok/s | js tok/s |
|---|---|---|
| q8_0 | 39.49 | 31.06 |
| f16 | 44.99 | 31.30 |
| f16 (repeat, same server) | 45.22 | 31.31 |

## Context ramp — n-max 4, f16 KV, short probe (`n_predict` 64)

GGUF metadata: `gemma4.context_length = 262144`, sliding window 1024 on 5 of 6 layers (KV stays small).

| `-c` | slots | result | RSS |
|---|---|---|---|
| 131072 | 1 | OK, 37.5 tok/s | 10.4 GB |
| 262144 | 1 | OK, 35.5 tok/s — model maximum | 12.4 GB |
| 524288 | 2×262144 | OK, MTP active, 37.5 tok/s | 16.9 GB |
| 786432 | 3×262144 | OK, MTP active, 37.1 tok/s | 21.2 GB |
| 1048576 | 4×262144 | Metal OOM (f16 KV) | – |
| 1048576 | 4×262144, **q8_0 KV** | **OK, 33.7 tok/s** | 16.9 GB |

With q8_0 KV (default per KV policy), **four full 256K slots fit** — the best concurrency config on the machine.

No Metal OOM at any size. The model's trained context is the ceiling, not memory.

## Final config validation — n-max 4, f16 KV, `-c 262144`

| prompt | pp tok/s | decode tok/s | draft_n | accepted |
|---|---|---|---|---|
| 4087-token text, `n_predict` 128 | 279.7 | 29.19 | 147 | 89 (61%) |
| py | 50.5 | 44.88 | 216 | 201 (93%) |
| js | 53.2 | 31.20 | 310 | 177 (57%) |

No Metal errors. RSS 14.2 GB after the long prompt — ~17.8 GB left for macOS + DB.

## Comparison with Qwen3.8-27B

| metric | Qwen3.8-27B Q4_K_M | Gemma-4-12B Q4_K_XL |
|---|---|---|
| best decode (py) | 16.8 tok/s | 45.2 tok/s |
| best decode (js) | 15.6 tok/s | 31.3 tok/s |
| best n-max | 3 | 4 |
| pp at 4K prompt | 122.8 tok/s | 279.7 tok/s |
| max context, 1 slot | 96K (memory limit) | 256K (model limit) |
| max context, 2 slots | 2×44K (memory limit) | 2×256K (model limit) |
| RSS at max, 1 slot | 24.1 GB | 12.4 GB |

## Depth sweep (limit 25000, 2026-08-28)

llama+MTP q8, 128K alloc: 14.0 tok/s at 4K, 9.0 at 8K, 6.8 at 16K — **8 tok/s
floor at ~11K**, the shallowest of all models. Surprising given the metadata
says sliding-window attention on 5 of 6 layers (KV is small); the depth cost
must come from elsewhere (kernel path or the global layers) — unexplained,
worth a look if this model stays in play. RSS 9.5 GB. MLX: unsupported —
mlx-lm 0.31.3 lacks the `gemma4_unified` model type (watch for an mlx-lm
release).

Re-confirmed 2026-09-03 under the current wired limit (24000), same
`-c 262144` command: 13.76 at 4,115, 8.76 at 8,234, 6.54 at 16,410 —
**below the 8 tok/s floor at 16,410**, close to the earlier reading
(the exact crossing point was not re-bracketed at ~11K this time).
RSS 10.5 GB. No load-time OOM at the huge `-c 262144` allocation,
unlike the same MTP-drafter pattern on Qwen3.6-35B-A3B — this model
is small enough to fit comfortably under the current limit.

## Depth sweep via LM Studio's MLX engine (limit 25000, 2026-08-28)

`lmstudio-community/gemma-4-12B-it-MLX-4bit` served CLI-only: `lms load
"lmstudio-community/gemma-4-12B-it-MLX-4bit" --context-length 131072
--gpu max --yes` + `lms server start` (port 1234; API id
`gemma-4-12b-it-mlx`; model store shared with the app).

| depth | decode tok/s |
|---|---|
| 4K | 36.7 |
| 16K | 36.9 |
| 33K | 34.8 |
| 49K | 33.1 |
| 74K | 30.8 |
| 82K | 31.2 |
| 98K | 28.6 |
| 115K | 28.0 |
| 131K | 26.1 |
| 147.5K | 25.1 |
| 155.8K | 30.8 |
| 163.9K | 30.0 |
| 168.0K | 29.9 |
| **169.6K** | **29.7 — deepest healthy point; 171K fails clean (server rejects, does not crash or OOM)** |

**The flattest curve of the whole project** (-9% over 169K) at 8.8 GB RSS —
LM Studio's gemma4_unified implementation appears to honor the
sliding-window attention that the llama.cpp path does not (llama floor ~11K
on the same model). Decode speed never drops toward the 8 tok/s floor and
no Metal OOM ever appears; the request past the boundary fails instantly
with a clean rejection, and the server serves normally again right after.
The ceiling here is LM Studio's own MLX loader: it auto-fits the loaded
context to 170240 tokens regardless of what is requested at load time
(confirmed via
[lmstudio-bug-tracker#2250](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/2250)
and [#1902](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/1902),
open, unfixed, no workaround as of 2026-08). This model's own trained
context is 262144 and the machine has memory to spare at 8.8 GB RSS — the
170240 figure is an LM Studio limitation, not a measurement of this model
or this machine. This era is superseded by the 2026-09-04 sweeps below,
which apply the compression-onset criterion at the current wired limit.

## Depth sweeps, both backends (2026-09-04, wired limit 24000)

House method: append-only prompt growth, 25 s pause per step, memory
counters in every step row, machine clean with the other backend quit.
llama-server on raw `/completion`, with `-c` always above the deepest
step of the arm (139,264 for the shallow half, 262,144 for the deep
half); LM Studio on the chat endpoint with `--parallel 4`, because its
raw completions path is broken on this build. Thinking off everywhere.

| used tokens | llama f16, no drafter | llama q8, no drafter | llama q8 + MTP | LM Studio MLX |
|---|--:|--:|--:|--:|
| 4,115 | 24.64 | 14.15 | 13.82 | 34.19 |
| 8,235 | 24.05 | 10.64 | 8.74 | |
| 16,411 | 22.66 | **7.12 — floor** | **6.53 — floor** | 32.05 |
| 24,587 | 21.59 | | | |
| 32,819 | 20.58 | | | 30.59 |
| 49,159 | 18.75 | | | |
| 65,551 | 17.42 | | | 27.08 |
| 81,943 | 15.87 | | | |
| 98,335 | 14.91 | | | 24.52 |
| 114,726 | 13.94 | | | |
| 131,118 | 13.04 | | | **23.23 — last stable** |
| 163,858 | 11.30 | | | |
| 180,238 | 10.72 | | | |
| 196,618 | 10.24 | | | |
| 212,998 | 9.69 | | | |
| 229,378 | 9.24 | | | |
| **245,810** | **8.86 — deepest step inside the trained window** | | | |

**The two backends stop for different reasons.** llama-server allocates
its KV from `-c`, so wired memory holds flat at 14,186 MB — 59% of the
limit — from load to the window; the step past 262,144 is refused. The
LM Studio engine grows into the cap: past the last stable step wired
reaches 87% of the limit and the sweep stops on 69 MB of swap growth.

**The chat path costs nothing on llama-server.** 24.68 tok/s against
24.64 at 4,114 used tokens, and 22.59 against 22.66 at 16,386. The raw
figures therefore transfer to harness use.

**A control on the deep half.** The deep steps started from a prefill
jump to 131,072 rather than a creep from 4K, so the first of them
re-measured a depth the slow creep already had: 12.67 tok/s against
13.04, 2.8% low. Arriving fast gives macOS less time to yield memory,
which is the direction the pause rule predicts, so the deep half is
marginally pessimistic.

## The agent probe (2026-09-04)

One short dependency-replacement task, the same base commit, thinking
off on both arms, 25-minute cap.

| | llama-server, f16 KV | LM Studio `gemma-4-12b-it-mlx` |
|---|--:|--:|
| tool calls | **42** | 5 |
| distinct calls | **30** | 4 |
| repetition loop | **none** | 2679 lines, `<channel\|><\|channel>thought` |
| commits | **1** | **0** |

Thinking off is enough for EvalPlus, which is single-turn. It is not
enough for multi-turn tool work on the MLX path: the loop is on the
thought channel, in `text_delta`, and no `enable_thinking` kwarg was
sent — the same request shape as the 0.909 / 0.872 scoring run.

## `google/gemma-4-12b`: the retired entry and the thinking-on pitfall {#the-retired-entry}

Retired 2026-09-04. This LM Studio entry always thinks, is gone from the
model store, and produced every failed Gemma-12B agent run on this
machine. Its numbers are off the current pages; the superseded speed and
ceiling readings are on [the historical page](../historical.md). The
evidence is collected here so the report page stays clean.

**The 0.622 / 0.610 score is a completion failure, not a quality drop.**
61 of 164 problems came back empty. Of the 103 it answered, 102 passed —
99.0%. Read together with the thinking-off row (0.909 / 0.872 at 164 of
164 answered), thinking makes this model better at the problems it
finishes and unable to finish 37% of them.

**All three invalid Mendel rows ran this entry.** One run made 130 tool
calls with only 30 distinct, and repeated a single invalid command 72
times in a row. The runs also produced newline floods that sit in
`reasoning_content`, end on a bare channel-open token, and never
proceed; the flood follows the runner's model nudge, not a tool
response. The rows stay in the data, marked invalid, because they
measure this serving combination and not the model's coding.

**The container ships Google's pre-fix chat template, and the standard
loader picks it.** The LM Studio container carries two templates: the
stale `chat_template.jinja` that Google replaced on 2026-07-15 to fix
the thought loop, and a current inline copy in `tokenizer_config.json`.
Transformers resolves to the stale file. The stale template, with
thinking on, opens the thought channel after a tool response; with
thinking off the two templates render byte-identical output.

**The loop is not only the template, and not only MLX.** Replayed on
llama-server with the same task and prompt, the pre-fix template looped
in three of three arms and the post-fix template still looped in one of
two. DRY sampling did not stop the loop, it hid it: 1133
shape-identical lines inside one tool call, which every exact-match
detector reads as clean.

**The two entries behave in opposite ways.** Probed 2026-09-04 with the
model loaded once: `gemma-4-12b-it-mlx` answers with thinking off and
the API cannot turn it on, in all three request shapes;
`google/gemma-4-12b` returns populated `reasoning_content` for a plain
chat request and no toggle turns it off. Both ids resolve to the same
container, so the difference is the entry, not the weights.

**Upstream says the same.** Google reproduced the 12B thought loop at
full precision and closed it as a weight-level attractor, pointing at
the 2026-07-15 template fix; LM Studio bug 2013 records that Gemma-4's
reasoning delimiters default to `<think>` instead of the documented
`<|channel>thought` / `<channel|>` pair, so the parser needs a manual
override. No fixed MLX container exists: the community Gemma-4 repos
were last updated before the template fix.

**The conclusion.** Thinking on is a pitfall of this model in our
configurations, on both backends. Keep the model thinking off, where the
template question is moot and the llama-server path works.

## Runtime lore for this model

The general lessons behind these three items are in
[the server lore](../../../methodology/server-lore.md). The specifics
below belong to this model on this machine.

- **The context window cannot be pinned on the MLX path.** This model's
  architecture is `gemma4_unified`. Every path to set the window is
  ignored, and LM Studio's auto-fit computes it from
  `iogpu.wired_limit_mb`: 158,464 tokens at a 24000 limit.
- **Thinking depends on which model store entry you load.** The
  "thinking is always on" behavior was observed on the LM Studio entry
  `google/gemma-4-12b`, which is retired and gone from the model store
  (see [the retired entry](#the-retired-entry)). The entry `gemma-4-12b-it-mlx` is
  thinking OFF and cannot be turned on — all three request shapes return
  an empty `reasoning_content` (probed 2026-09-04,
  `hardware/m1-max-32gb/research/run2/results/lmstudio-thinking-probe.md`).
- **A curated Hub id resolved to another repository's weights.** The
  entry `google/gemma-4-12b` resolves to
  `lmstudio-community/gemma-4-12B-it-MLX-4bit`. Check
  `hub/models/<id>/manifest.json` before you assume two ids are two sets
  of weights.
