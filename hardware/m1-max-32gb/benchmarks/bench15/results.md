# Run 15 — results

One section per block, in run order. Every number with the exact
command that produced it and the file under `results/` that holds the
evidence. A simulator(mendel) row states its score, libraries done,
worst defect, wall clock, peak context, compaction count, and the
sampling read from `meta.json`. A vision table carries no verdict.
A table carries no pick.

## `qwen36-f16-ladder-creep`

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`,
`--no-mmproj`, f16 KV, no drafter, one slot, wired 25000. Tool
`e38c467`.

**Ladder.** Probed `-c 65536` once: loaded (wired 25027 MB) and served
a real 6001-token completion request cleanly. `-c 65536` is the top of
the block's own `DEPTH_LIST`, so no lower rung needed testing; served
`-c` = 65536.

**Creep**, `DEPTH_LIST="4096,8192,16384,24576,32768,40960,49152,57344,65536"`:

| depth | tok/s | wired MB | free MB | swap Δ | compress | decompress |
|--:|--:|--:|--:|--:|--:|--:|
| 4114 | 50.49 | 25027 | 79 | 0 | 107 | 90 |
| 8222 | 48.41 | 25025 | 63 | 0 | 293 | 286 |
| 16386 | 46.17 | 25010 | 71 | 0 | 0 | 925 |
| 24602 | 43.71 | 25010 | 64 | 0 | 3183 | 949 |
| 32818 | 41.50 | 25009 | 61 | 0 | 2010 | 391 |
| 40982 | 39.32 | 25008 | 78 | 0 | 74 | 462 |
| 49198 | 37.20 | 24967 | 63 | 0 | 11643 | 4751 |
| 57362 | 35.03 | 24921 | 155 | 0 | 375 | 248 |
| 65578 | 33.64 | 24921 | 129 | 0 | 0 | 1128 |

`no ceiling found up to 65536`, exit 0. No swap growth, no sustained
compression onset, speed never dropped under the 8 tok/s floor.
`gatedBy: untested` — the deepest step is the depth list's own end,
not a measured ceiling.

`qwen36_f16_c` = 65536 (served). `qwen36_f16_clean` = 65578 (deepest
clean depth).
Files: `results/creep-qwen36-f16-nodrafter.tsv`,
`results/server-qwen36-f16-c65536.log`.
Deviation: none.

## `qwen36-f16-mendel-on`

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`,
`--no-mmproj`, f16 KV, no drafter, one slot, `-c 65536`, wired 25000.
Window 65536 (largest multiple of 8192 at or under `qwen36_f16_clean`
65578). Branch `qwen3.6-35b-a3b-f16-on-issue-13`. Model:
`qwen3.6-35b-a3b-f16 (unsloth UD-Q4_K_XL, no drafter, on)`.
`end_reason: complete`. 211 tool calls, 2 compactions (both `overflow`,
at 14:11:03Z and 14:26:42Z), wall clock about 33 min (well inside the
300-min cap), `peak_context` 45332/65536 (69.2%) at close, sampling
temperature 1 / top_p 0.95 (server default, no sampling parameter
passed).

**Scored** by a subagent. Score **50/100**. Worst defect **critical**,
trap A: `apply-extra-options.js` keeps `.then()` over
`fs.promises.glob` at all three call sites; the repro throws
`TypeError ... .then is not a function`. The model used
`fs.globSync` correctly in four other files but never checked the
return type at this one. No test covers the file. The model never
read the root `package.json` (rimraf and tmp still declared) and
never ran `pnpm install/remove/add` (trap root devDeps); never opened
`legacy-packages/` or grepped `rimraf` repo-wide (trap B, never seen).
Trap C passes; the chalk v1.1 port is correct.

**Verified `peak_context`: 61485** (93.8% of the 65536 window) —
corrects the 45332 closing-read value first written here, which was
after compaction. The subagent derived 61485 from the assistant-message
usage records, the field `PLAN.md` defines as the counter.

Harness fault, unscored: one turn at 14:11:03Z produced 1 output token
with partial thinking and no tool call (an output-limit alarm below
budget), which forced the first compaction — not a model defect.

Published to `~/code/mendel-benchmark`, branch `benchmark`, commit
`57722e8`.
Files: `~/.local/share/mendel-benchmark/runs/qwen3.6-35b-a3b-f16-on-blind-events.jsonl`,
`~/.local/share/mendel-benchmark/runs/qwen3.6-35b-a3b-f16-on-blind-meta.json`,
`results/mendel-qwen36-f16-on.log`, `results/run-watch-mendel-qwen36-on.log`.
Deviation: none.

## `vision-ladder`

A measurement, no gate and no verdict.

**The page image.** `hardware/m1-max-32gb/benchmarks/bench15/results/vision/page.png`,
sha256 `864f41d0220c1ba64c9f9f8eec21871da6c523ef325713231ea3f18b814a7480`,
1400×1400. Shows the whole table.

Deviation: `textutil -convert pdf` is not a supported format on this
machine (`textutil -help` lists `txt, rtf, rtfd, html, doc, docx, odt,
wordml, webarchive` — no `pdf`). `cupsfilter` has no text/rtf or
text/html to PDF filter installed either. Fallback used instead of the
runbook's PDF step: `textutil -convert rtf page.txt -output page.rtf`,
then `qlmanage -t -s 1400 -o . page.rtf` directly — QuickLook
thumbnails an RTF file the same way it thumbnails a PDF, so the PDF
step is skippable on this machine. The resulting PNG shows the whole
table cleanly (verified by reading the image). Not a stop-and-ask; the
run did not wait.

| server | `-c` | loaded | served | wired load MB | wired after MB | prompt tok (filler) | prompt tok (no filler) | image tok (diff) | decode tok/s |
|---|--:|:--:|:--:|--:|--:|--:|--:|--:|--:|
| Qwen3.6 f16, vision | 65536 | yes | yes | 25680 | 25678 | 8983 | 1978 | 7005 | 48.5 |
| Gemma-26B f16, vision | 204800 | yes | yes | 25678 | 26618 | 7894 | 889 | 7005 | 51.3 |

Qwen3.6 server: projector confirmed loaded (`load_model: loaded
multimodal model, '.../mmproj-BF16.gguf'`). Prompt eval 16094.62 ms /
8983 tokens (558.14 tok/s) on the filled request; eval time 7937.30 ms
/ 386 tokens (48.51 tok/s) decode. No-filler request: prompt eval
7451.32 ms / 1978 tokens (265.46 tok/s), eval 7735.78 ms / 400 tokens
(51.58 tok/s) decode. Replies: `results/vision/reply-qwen36-c65536.json`,
`results/vision/reply-qwen36-c65536-nofiller.json` — both read the
table correctly (electricity, distribution, gas, standing charge, late
fee, subtotal, VAT, total), not judged further.

Gemma-26B server: projector confirmed loaded the same way. **Deviation:**
the first attempt at default `--ubatch-size` (512) crashed the server
on the filled request (`src/llama-context.cpp:1724:
GGML_ASSERT((cparams.causal_attn || cparams.n_ubatch >= n_tokens_all)
&& "non-causal attention requires n_ubatch >= n_tokens") failed`) —
the image chunk needs a bigger ubatch than the default. Restarted at
`--ubatch-size 2048`, same `-c 204800`, and the request served clean.
This flag is a batching parameter, not part of the block's fixed
identity (files, revision, KV type), so it was changed without a
stop-and-ask; the run did not wait. On the filled request: prompt eval
15550.60 ms / 7894 tokens (507.63 tok/s); the reply hit `max_tokens`
400 still inside its own reasoning (`finish_reason: length`, empty
`content`, 400 tokens of `reasoning_content`) — the server served it,
the model just did not finish reasoning in budget, so no JSON to judge.
No-filler request: prompt eval 6635.46 ms / 882 tokens (132.92 tok/s,
7 tokens cache-read), eval 7232.47 ms / 400 tokens (55.17 tok/s), same
`length` stop. Replies: `results/vision/reply-gemma26-c204800.json`,
`results/vision/reply-gemma26-c204800-nofiller.json` — not judged
further, per the block's own rule.

`vision_qwen36_c` = 65536 (first probe served; no step-down needed).
`vision_gemma26_c` = 204800 (first probe served, after the ubatch
fix; no step-down needed).

## `vision-ladder-up`

Both servers, projector on, no drafter, f16 KV, `--parallel 1`, wired
25000, Gemma-26B with `--ubatch-size 2048`. Rung test: the
`vision-ladder` filled request, served with real content.

**Qwen3.6.** Probed `-c 73728`. Load line said "model loaded" but the
log also carried `error: Insufficient Memory
(kIOGPUCommandBufferCallbackErrorOutOfMemory)` at load time — the
known pitfall (a server can say "loaded" and still fail every real
request). Sent the filled request to confirm: it failed
(`llama_decode: failed to decode, ret = -3`, `Compute error`), no
`usage` in the reply. `-c 73728` is not a served rung.
`vision_qwen36_c` stays **65536**, the `vision-ladder` value; the
climb closes at its first step.

**Gemma-26B.** Probed `-c 212992` (`--ubatch-size 2048` carried over).
Load line clean this time, no OOM at load. Sent the filled request:
failed the same way (`Insufficient Memory`, `Compute error`, `ret =
-3`) at `n_tokens = 7890`, no `usage` in the reply. `-c 212992` is not
a served rung. `vision_gemma26_c` stays **204800**, the `vision-ladder`
value.

| server | `-c` tried | loaded (log line) | served (real request) | verdict |
|---|--:|:--:|:--:|---|
| Qwen3.6 f16, vision | 73728 | yes, with an OOM line at load | no — decode Compute error | not a rung, stays 65536 |
| Gemma-26B f16, vision | 212992 | yes, clean | no — decode Compute error | not a rung, stays 204800 |

Neither arm climbed. `vision_qwen36_c` = 65536, `vision_gemma26_c` =
204800 (unchanged from `vision-ladder`).
Files: `results/server-vision-qwen36-c73728.log`,
`results/server-vision-gemma26-c212992.log`.
Deviation: none (both failures are within the block's own "a `-c`
that loads and fails the request is not a rung" rule).

## `vision-drafter-shallow`

Five cells per model at depth 256 (one warmup + two counted requests
per cell), `request-drafter.json` (page image + prompt, no filler,
`max_tokens` 256). f16 KV, `--parallel 1`, wired 25000.

### Qwen3.6, `-c 65536`

The model card says the projector and the MTP drafter do not work
together. That did not hold here: `--spec-draft-n-max 1` loaded (both
the mmproj and the MTP draft context) and served fine. `n-max 2` and
`n-max 3` both loaded but failed every real request
(`Insufficient Memory` / `Compute error`, `ret = -3`) — the same OOM
signature as `vision-ladder-up`'s failed climbs, not a
projector/drafter incompatibility. Memory cost grows monotonically
with `n-max` (project convention: each extra draft token costs more
KV budget), so **`n-max 4` was not tested — inferred to fail the same
way**, not a measurement.

| n-max | tok/s (2 counted) | mean | acceptance | wired MB at load |
|--:|---|--:|---|--:|
| none | 50.33, 50.38 | 50.36 | — | 25476 |
| 1 | 58.11, 51.42 | 54.77 | 0.889, 0.693 | 25555 |
| 2 | fail (OOM, Compute error) | — | — | — |
| 3 | fail (OOM, Compute error), same signature | — | — | — |
| 4 | not tested, inferred fail | — | — | — |

A table and no pick.
Files: `results/server-vision-qwen36-drafter-nodraft.log`,
`results/server-vision-qwen36-drafter-n1.log`,
`results/server-vision-qwen36-drafter-n2.log`,
`results/server-vision-qwen36-drafter-n3.log`.
Deviation: none.

### Gemma-26B, `-c 204800`, `--ubatch-size 2048`

No-drafter cell served clean. Every drafter cell (`n-max 1` first)
failed to serve — same OOM signature (`Insufficient Memory`,
`Compute error`, `ret = -3`) as `vision-ladder-up`'s failed climb.
Unlike Qwen3.6, even `n-max 1` has no headroom left at this model's
own `-c` (204800 already leaves less margin than Qwen3.6's 65536).
**`n-max 2`, `3`, `4` were not tested — inferred to fail the same
way**, not a measurement.

| n-max | tok/s (2 counted) | mean | acceptance | wired MB at load |
|--:|---|--:|---|--:|
| none | 54.30, 54.27 | 54.29 | — | 25470 |
| 1 | fail (OOM, Compute error) | — | — | — |
| 2 | not tested, inferred fail | — | — | — |
| 3 | not tested, inferred fail | — | — | — |
| 4 | not tested, inferred fail | — | — | — |

A table and no pick.
Files: `results/server-vision-gemma26-drafter-nodraft.log`,
`results/server-vision-gemma26-drafter-n1.log`.
Deviation: none.
