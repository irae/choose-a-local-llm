# Qwen3.8-27B: find a configuration that finishes agent work

Status: draft 2026-09-05, candidate 2 surveyed 2026-09-07. Needs
hardware: yes, one Mendel smoke per candidate.

The best single-turn score on this hardware never completed a Mendel
run (five attempts, four partial, one invalid; the report page opens
with it, `docs/setups/m1-max-32gb/reports/qwen3.8-27b.md`). Run 9 gave
its llama row f16 KV and 49K, and run 10 block B passed the Mendel
smoke on that row (8 tool calls, one clean commit, 62 s), so the row
gets a Mendel blind run in run 10. Before the model retires from the
daily-driver question, this item tries, in order, and stops at the
first that yields a completed run:

1. **Vision off.** A video on this model
   (https://www.youtube.com/watch?v=0xUxO_9zqTU, diagrams only, read
   the transcript) says dropping the vision tower frees memory. Our
   llama command already passes `--no-mmproj`; check whether the MLX
   container and LM Studio still load the tower, and what the GGUF
   saves with and without it at the same `-c`.
2. **Alternative quants, GGUF first.** GGUF takes every flag we use
   (KV type, drafter, slots, no vision); MLX takes none of them. The
   survey is done, desk work only: **[the quant and build
   survey](#the-quant-and-build-survey)** below. It lists 30 community
   builds with their proof, computes the context each buys, and ends
   with three builds to try and the downloads they need. A 3-bit build
   that reaches 96K at 12 tok/s beats a 4-bit build at 49K for agent
   work.
3. **Reasoning effort: low and xhigh, not medium.** The community
   reports (owner, 2026-09-06) that effort medium is the worst of this
   model's settings for agent work: it thinks too much and does not
   reach a conclusion. Low and xhigh are the two to try. Every scored
   row here ran medium (the llama blind 87 included) or low on the MLX
   build, and the MTP acceptance sweep on the report page shows medium
   only as the fastest decode. The owner also pointed at
   https://www.youtube.com/watch?v=dHK90xc9Q64; its transcript,
   fetched and condensed, is `qwen38-configs/video-dHK90xc9Q64.md`.
   That video says nothing about effort levels; it covers quant and
   context on 32 GB Macs (4-bit MLX holds 32K at 15.8 tok/s, 19.2 GB;
   llama.cpp issue 27756, a silent end-of-sequence past about 130K
   context on this model), which feeds candidate 2. The trial:
   the Mendel smoke on the llama f16 row at low and at xhigh, then the
   blind run at whichever passes with the fewer nudges, against the
   medium row's 87. Run 11 holds no Qwen3.8 block; the deferred EvalPlus
   at medium and the guided run wait for this item's answer, because
   the effort level decides which config is worth scoring.
   **The desk evidence found for this step is
   [below](#reasoning-effort-what-the-sources-say); it does not agree
   with the report, and it does not settle it. The plan stands.**
4. **The OOM-at-load threshold.** Moved to
   `unscheduled/no-oom-at-mendel.md`,
   which holds the llama fit findings (`--fit` is off whenever `-ngl`
   is set by hand; `-ub` sizes the compute buffer; `llama-fit-params`
   projects without a server).

## What is already known

- `kv-quant-on-m1.md`: the model is dense, 48 DeltaNet layers without
  KV and 16 full-attention layers at 64 KiB of KV per token; no lookup
  tables (those belong to the Flash-Next variant). A quantized KV
  cache is slow here because of llama.cpp's decode-time attention
  kernel, not the chip; a q4_0 KV trial is a Qwen-only experiment
  (int4 KV breaks Gemma 4 past about 950 tokens).
- The MLX row's window problem is
  `../benchmarks/unscheduled/qwen38-mlx-window.md` and
  `unscheduled/no-oom-at-mendel.md`, both unscheduled; the MLX server
  has no memory bound and no
  quantized KV.

Each candidate goes through the Mendel smoke on the llama row; a pass
becomes a bench item. Research publishes no number.

## The quant and build survey

Desk work, 2026-09-07. No download, no server, no model run. Every
size, recipe and proof below comes from a publisher page or from a
third-party measurement, and every context figure is **computed here,
not measured**. Sources are listed at the end of the file.

### The memory model used for every context figure

Two inputs, both already in the repo:

- **KV per token** (`kv-quant-on-m1.md`): 16 full-attention layers x 2
  x 4 KV heads x head_dim 256 x 2 bytes = **65,536 bytes per token at
  f16**, and **32,768 bytes at q8_0**. The 48 DeltaNet layers keep a
  fixed recurrent state of about 150 MB that does not grow with the
  window. Per 1K tokens (1024) that is **0.0671 GB at f16** and
  **0.0336 GB at q8_0**.
- **The machine's ceiling**: the current row serves
  `bartowski/Qwen3.8-27B-GGUF:Q4_K_M` at `-c 49152` and 23.5 GB wired,
  and 65536 OOMs at load
  (`docs/setups/m1-max-32gb/reports/qwen3.8-27b.md`). So the ceiling
  **B = 23.5 GB**.

The fixed cost that is neither weights nor KV (compute buffer, graph,
recurrent state, allocator slack) is fitted from that one measured
row:

```
O = B - weights - KV
O = 23.5 - 17.77 - (48 x 0.0671)
O = 23.5 - 17.77 - 3.22 = 2.51 GB, rounded to 2.5 GB
```

The context a build buys is then, with the file size S in GB:

```
free for KV, F = B - O - S = 21.0 - S
context at f16 KV = F / 0.0671 thousand tokens
context at q8_0 KV = F / 0.0336 thousand tokens
```

Check: at S = 17.77 the formula gives 48K, and the machine serves
49152. The unit of the 23.5 GB figure (GB or GiB) and the size of O are
both absorbed by this one calibration, so the formula is a projection
from a single point. **Every context number below is unverified.** The
fit also assumes O does not change with the quant recipe or the window,
which is not measured; a larger window needs a larger compute buffer,
so the deep figures are the least safe.

Three caps sit above the arithmetic:

- **262144 tokens** is the trained window. Nothing above it counts.
- **About 130K tokens** is where llama.cpp issue 27756 starts to bite
  on this model (see [known defects](#known-defects-worth-carrying)).
  A GGUF row above about 128K is not usable, whatever the memory says.
- The **8 tok/s floor** is a speed question, and speed on this chip is
  a Mac measurement. **No row below answers it.** The floor column is
  `unknown` for every build, including the ones we already own weights
  for.

### GGUF builds

Sizes are the publisher's own file sizes. The KLD column is mean KL
divergence against BF16 logits on a held-out 87-chunk corpus at context
4096, measured and published by AtomicChat, not by us; top-1 is the
share of tokens whose top prediction matches BF16 on the same corpus.
A build with no entry there carries `none` and its recipe wording is
the only claim it makes.

| # | publisher / repo | recipe, publisher's words | size | revision to pin | proof | ctx f16 | ctx q8_0 | 8 tok/s |
|--:|---|---|--:|---|---|--:|--:|---|
| G1 | bartowski/Qwen3.8-27B-GGUF | Q4_K_M (the row we serve today) | 17.77 GB | `f0eec4a4bb4975114a030d048952d83c0a53c034` | none of its own; imatrix corpus published in-repo (`Qwen3.8-27B-calibration-v6.txt`, 583 chunks, 63.3% tool-calling) | 48K (measured 49152) | 96K | measured 15.0 at 49K |
| G2 | bartowski/Qwen3.8-27B-GGUF | Q4_K_S, "slightly lower quality with more space savings, recommended" | 16.71 GB | same | none | 64K | 128K | unknown |
| G3 | bartowski/Qwen3.8-27B-GGUF | IQ4_XS, "decent quality, smaller than Q4_K_S with similar performance, recommended" | 15.57 GB | same | none | 81K | 162K | unknown |
| G4 | bartowski/Qwen3.8-27B-GGUF | IQ4_NL, "similar to IQ4_XS, but slightly larger" | 16.33 GB | same | none | 70K | 139K | unknown |
| G5 | bartowski/Qwen3.8-27B-GGUF | Q4_1, "legacy format, similar performance to Q4_K_S but with improved tokens/watt on Apple silicon" | 17.83 GB | same | none; the Apple-silicon claim is the card's own and is not checkable from here | 47K | 94K | unknown |
| G6 | bartowski/Qwen3.8-27B-GGUF | Q3_K_XL, "uses Q8_0 for embed and output weights. Lower quality but usable" | 16.39 GB | same | none | 69K | 137K | unknown |
| G7 | bartowski/Qwen3.8-27B-GGUF | Q3_K_L, "lower quality but usable, good for low RAM availability" | 15.28 GB | same | none | 85K | 170K | unknown |
| G8 | bartowski/Qwen3.8-27B-GGUF | Q3_K_M, "low quality" | 14.61 GB | same | none | 95K | 190K | unknown |
| G9 | bartowski/Qwen3.8-27B-GGUF | IQ3_M, "medium-low quality, new method with decent performance comparable to Q3_K_M" | 13.90 GB | same | none | 106K | 212K | unknown |
| G10 | bartowski/Qwen3.8-27B-GGUF | IQ3_XS, "lower quality, new method, slightly better than Q3_K_S" | 13.33 GB | same | none | 114K | 229K | unknown |
| G11 | bartowski/Qwen3.8-27B-GGUF | IQ3_XXS, "lower quality, new method with decent performance, comparable to Q3 quants" | 12.63 GB | same | none | 125K | 249K | unknown |
| G12 | unsloth/Qwen3.8-27B-GGUF | UD-Q4_K_XL, Dynamic v3.0 | 17.6 GB card, 17.92 GB measured | `4ca720788d1e01f1bff70c033e0d0028fd02e502` | third party: KLD 0.0095, top-1 96.02% | 46K | 92K | unknown |
| G13 | unsloth/Qwen3.8-27B-GGUF | UD-IQ4_XS, Dynamic v3.0 | 14.3 GB card, 15.71 GB measured | same | third party: KLD 0.0176, top-1 94.47% | 79K | 158K | unknown |
| G14 | unsloth/Qwen3.8-27B-GGUF | Q4_K_S | 16.12 GB measured | same | third party: KLD 0.0171, top-1 94.49% | 73K | 145K | unknown |
| G15 | unsloth/Qwen3.8-27B-GGUF | UD-Q3_K_XL, Dynamic v3.0 | 13.1 GB card, 13.44 GB measured | same | third party: KLD 0.0397, top-1 91.87% | 113K | 225K | unknown |
| G16 | unsloth/Qwen3.8-27B-GGUF | UD-IQ3_S, Dynamic v3.0 | 12 GB card | same | none for this exact file | ~134K | ~268K | unknown |
| G17 | unsloth/Qwen3.8-27B-GGUF | UD-IQ3_XXS, Dynamic v3.0 | 10.9 GB card, 11.91 GB measured | same | third party: KLD 0.0733, top-1 89.22% | 135K | 271K | unknown |
| G18 | AtomicChat/Qwen3.8-27B-GGUF | AD-Q4_K_M, "Atomic Dynamic" layout: first and last layers lifted, extra bits on the attention gate and the state output path | 17.12 GB | `ca10ebceb1887be9d33b838770a36b39d75a8a4c` | own: KLD 0.0113, top-1 95.59% | 58K | 116K | unknown |
| G19 | AtomicChat/Qwen3.8-27B-GGUF | AD-IQ4_XS | 16.51 GB | same | own: KLD 0.0125, top-1 95.39% | 67K | 134K | unknown |
| G20 | AtomicChat/Qwen3.8-27B-GGUF | AD-IQ4_XS-IQ3_S (mixed) | 14.44 GB | same | own: KLD 0.0266, top-1 93.15% | 98K | 195K | unknown |
| G21 | AtomicChat/Qwen3.8-27B-GGUF | AD-IQ3_S | 13.84 GB | same | own: KLD 0.0325, top-1 92.41% | 107K | 213K | unknown |
| G22 | AtomicChat/Qwen3.8-27B-GGUF | AD-IQ3_S-IQ3_XXS (mixed) | 12.98 GB | same | own: KLD 0.0434, top-1 91.33% | 120K | 239K | unknown |
| G23 | AtomicChat/Qwen3.8-27B-GGUF | AD-IQ3_XXS | 12.08 GB | same | own: KLD 0.0697, top-1 89.13% | 133K | 266K | unknown |
| G24 | ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF | IQ3_S, "3.50 bpw", GSQ plus RCO, non-uniform per-tensor mixed precision | 11.8 GB, `-mtp` about 12.15 GB | `d562806dbafae37109975e970aae91b43e73b440` | own: perplexity wiki 7.07 / c4 11.76 / FineWeb-Edu 8.34; AIME25 100.00, GPQA-D 89.39, LiveCodeBench v6 85.71; two papers (arXiv 2604.18556, 2605.00649) | 137K, `-mtp` 132K | 274K, `-mtp` 264K | unknown |
| G25 | ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF | IQ3_XXS, "3.00 bpw" | 10.1 GB, `-mtp` about 10.45 GB | same | own: perplexity 7.20 / 12.13 / 8.59; AIME25 100.00, GPQA-D 88.89, LiveCodeBench v6 84.57 | 162K | 325K | unknown |

Its own BF16 baseline, published by ISTA-DASLab in the same table, is
perplexity 7.05 / 11.45 / 8.14, AIME25 100.00, GPQA-D 89.90,
LiveCodeBench v6 85.71. That is what makes its IQ3_S claim readable:
the same harness ran both ends.

Notes on the GGUF rows, and what cannot be checked from a desk:

- **bartowski offers no proof at all.** The card gives a recipe
  sentence per file and publishes its calibration corpus, which is
  useful and is not a measurement. Our whole Qwen3.8 GGUF record rests
  on this publisher, and it has never been compared against BF16 by
  anyone we can cite. Its files are absent from the AtomicChat
  comparison.
- **unsloth's own claim cannot be checked.** The card says Dynamic v3.0
  gives ">10% top-1% better accuracy at the same size compared to every
  other provider". No table, corpus or script backs it on the page. The
  third-party numbers in the table above are AtomicChat's, and they put
  unsloth ahead of nobody in particular: AtomicChat's own files sit
  lower on the same curve, which is what a publisher's own comparison
  usually shows. Treat both directions as marketing until a third
  party re-runs it.
- **AtomicChat is the only GGUF publisher here that publishes raw
  logits.** The metrics dataset holds per-file KLD percentiles, top-1
  agreement, the corpus, and the BF16 reference logits, "enabling
  independent verification". Its dataset viewer is broken; the numbers
  come from `results.json`. It is still a publisher measuring itself
  against competitors, and its own files win. The method (one corpus,
  one context, one reference) is sound and re-runnable; the selection
  of competitor files is not ours.
- **ISTA-DASLab is the only one offering task-level proof**, and the
  only one with papers behind the method. Its claim is strong: IQ3_S at
  11.8 GB matches BF16 exactly on AIME25 and LiveCodeBench v6. Two
  cautions. It says nothing about Metal or Apple Silicon, and it names
  no llama.cpp build. And a coding-benchmark match is not an agent-loop
  match, which is exactly what this repository keeps finding.
- **`ISTA-DASLab/Qwen3.8-27B-3Bit-GSQ` is not a candidate.** It is
  safetensors for vLLM 0.27.1 with a patch, not GGUF, and the card
  names no llama.cpp or Metal path.
- **i-quant speed on an M1 is the open risk.** llama.cpp Metal has
  hand-written kernels for IQ4_XS and IQ3_S, and community reports say
  sub-4-bit i-quants run well below K-quants on Apple Silicon before
  the M4 generation, which closed most of the gap. This machine is an
  M1 Max. No measurement of an IQ3 build on this chip exists here or in
  any source found. That is why the shortlist starts with a K-quant.
- The MTP head matters: our row runs `--spec-type draft-mtp`. AtomicChat
  states its files carry an MTP head for that flag. ISTA-DASLab ships
  separate `-mtp` files, about 0.35 GB larger. For unsloth and bartowski
  the MTP path is what our current row already uses, so it is present in
  the bartowski file at least.

### MLX builds

The GGUF arithmetic does not transfer. `mlx_lm.server` preallocates no
cache, offers no quantized KV
([mlx-lm #1043](https://github.com/ml-explore/mlx-lm/issues/1043)), and
its measured marginal cost here is **about 0.16 GB per 1K tokens**,
roughly 3x the f16 KV slope, because prefill activation buffers
dominate (`docs/setups/m1-max-32gb/benchmarks/qwen3.8-27b.md`). So the
MLX projection uses the measured anchor instead: the 16.07 GB 4-bit
build reaches 28K at 22.0 GB wired, and each GB of weights not loaded
buys about 6.3K more tokens at 0.16 GB per 1K.

```
context (K) = 28 + (16.07 - S) / 0.16 x 1
```

That is a one-point extrapolation over a curve that is not linear and
that ends in a hard Metal OOM, not a soft floor. **Every MLX context
below is unverified and the least trustworthy figure in this file.**

| # | publisher / repo | recipe, publisher's words | size | revision to pin | proof | ctx f16 | ctx q8_0 | 8 tok/s |
|--:|---|---|--:|---|---|--:|--:|---|
| M1 | mlx-community/Qwen3.8-27B-4bit | 4-bit (the row we serve today) | 16.07 GB | `3e6447f082e89cc7f0bc6e5441afd38dfce760ff` | none | 28K, measured | not available on the server | measured 15.3 at 28K |
| M2 | AtomicChat/…-MLX-AD-4.50bpw-DWQ-16.0GB | AD layout, DWQ, 4.50 bpw | 16.0 GB | not pinned | none on the card | ~28K | n/a | unknown |
| M3 | AtomicChat/…-MLX-AD-3.80bpw-DWQ-13.7GB | AD layout, DWQ, 3.80 bpw | 13.7 GB | not pinned | none on the card | ~43K | n/a | unknown |
| M4 | AtomicChat/…-MLX-AD-3.70bpw-DWQ-13.4GB | AD layout, DWQ, 3.70 bpw | 13.4 GB | `16aea93cf9a1e439b20a0b3374ceaaa3a815c6eb` | none on the card | ~45K | n/a | unknown |
| M5 | AtomicChat/…-MLX-AD-3.50bpw-DWQ-12.7GB | AD layout, DWQ, 3.50 bpw | 12.7 GB | `400a1aa8c45cfd7cd626d09b9f0ee627979015da` | none; README is empty | ~49K | n/a | unknown |
| M6 | lmstudio-community/Qwen3.8-27B-MLX-4bit | 4-bit | not fetched | not pinned | none | ~28K | n/a | unknown |
| M7 | mlx-community/Qwen3.8-27B-MTP-4bit | 4-bit MTP draft head | not fetched | not pinned | none | draft only | n/a | n/a |

The AtomicChat MLX DWQ builds carry the same AD name as the GGUF files
that do have published KLD, **but no MLX file has any published
measurement**: the 3.50 bpw card is empty and the others show only
metadata. Do not carry the GGUF KLD numbers across to them; a DWQ MLX
build is a different recipe on a different runtime. All MLX cards are
tagged image-text-to-text, so the vision tower is present and
candidate 1 (vision off) is still open for them.

MLX is not in the shortlist. It takes none of our flags, it has no
quantized KV, it OOMs hard instead of slowing down, and every one of
its rows here scored partial or invalid on Mendel. If the three GGUF
trials all fail the speed floor, M5 at 12.7 GB is the next thing to
look at, because it is the only path that could roughly double the MLX
window.

### The shortlist: three builds, in order

The rule is the file's own: a 3-bit build that reaches 96K at 12 tok/s
beats a 4-bit build at 49K. All three are 3-bit. The Q4_K_M row we
already serve is the control, so no 4-bit download is on the list.

1. **`unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL`** (G15, 13.44 GB, projected
   113K at f16 KV). It is a K-quant, so it avoids the i-quant Metal
   path that community reports call slow on pre-M4 Apple Silicon.
   **What it proves:** whether a 3-bit build keeps both a large window
   and the decode speed on this chip. If a K-quant 3-bit fails the
   8 tok/s floor, no 3-bit build will pass, and candidate 2 is closed.
2. **`AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S`** (G21, 13.84 GB, projected
   107K at f16 KV). At almost the same size as G15 it drifts 18% less
   against BF16 (0.0325 against 0.0397 mean KLD, 92.41% against 91.87%
   top-1), by the publisher's own measurement.
   **What it proves:** whether moving bits around inside a 3-bit budget
   buys agent quality, and what an i-quant costs in decode speed on
   this M1 at the same size as run 1.
3. **`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`** (G24, about
   12.15 GB, projected 132K at f16 KV, capped to about 128K by issue
   27756). It is the only build with task-level proof and the only one
   with papers.
   **What it proves:** whether a "task-lossless" 3-bit claim, made on
   AIME25 and LiveCodeBench, survives a Mendel agent loop. This
   repository has found several times that a single-turn score does not
   predict an agent run; this build makes that a clean test.

Each goes through the Mendel smoke on the llama row first, with the
current row's flags unchanged except `-c`, before anything is scored.

### The downloads to authorize

One decision, three files, taken before any run. Sizes are the
publisher's.

| order | file to fetch | size |
|--:|---|--:|
| 1 | `unsloth/Qwen3.8-27B-GGUF` → `UD-Q3_K_XL` | 13.44 GB |
| 2 | `AtomicChat/Qwen3.8-27B-GGUF` → `Qwen3.8-27B-AD-IQ3_S.gguf` | 13.84 GB |
| 3 | `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF` → `Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf` | about 12.15 GB |
| | **total** | **about 39.4 GB** |

No mmproj file is needed: the row runs `--no-mmproj`. If the owner
authorizes only one, take number 1.

### The trial, as the owner approved it

The owner approved all three builds on 2026-09-07 and sent the
download to the machine the same evening. The machine fetches them
with llama's own Hugging Face path, at the revisions above, so the
files land in the cache llama already reads. The machine records each
file name, revision and real size beside the other model pins.

The trial runs at wired **25000**, the limit the next runs drive.

Each build takes the same three steps, in this order, and stops at the
first one that fails:

1. **Context creep.** Every build gets one. The creep gives the
   ceiling, the curve and the depth where decode falls under 8 tok/s.
   This is the step that answers the one question the survey could not:
   speed. A build that cannot hold 8 tok/s at a depth the agent task
   needs is finished here, whatever its window.
2. **Mendel smoke**, against the same smoke on the row we serve today.
3. **EvalPlus smoke**, the same budget on both sides, against the same
   row.

Rules for the trial:

- **KV cache is f16.** This hardware is slow at a quantized KV cache,
  so f16 is the default for every creep and every smoke. Use q8_0 only
  where a build cannot reach a needed depth at f16, and say so in the
  row.
- **No full Mendel run and no full EvalPlus run.** Research stops at
  the two smokes. A build that passes both becomes a bench item; the
  scored run happens there, not here.
- **GGUF only.** No MLX build enters the trial unless it is the only
  build of that model that exists.
- Serving flags stay as the current row has them, `--no-mmproj`,
  `--spec-type draft-mtp`, one slot. Only `-c` changes.
- **Every build is tried with the MTP drafter where the build has
  one.** ISTA-DASLab ships a separate `-mtp` file, about 0.35 GB
  larger, and shortlist build 3 is already that file. AtomicChat says
  its files carry an MTP head. The unsloth build inherits the path our
  current row already uses. Where a build needs a separate MTP file,
  that file is downloaded upfront with the weights, not later. Where a
  build has no MTP head, record that and run it without one.
- A build served above 120K needs a long-prompt completion check in
  its smoke, because of llama.cpp issue 27756 below.

### Reasoning effort: what the sources say

Step 3 keeps its plan. This is the desk evidence found for it, and it
runs **against** the report that medium is the worst setting.

- **Against.** A benchmark write-up scores this model at effort medium
  8.18 on its agentic index, above Qwen3.6-27B at 7.96, and 32% faster.
  It states plainly that "low is both slower and worse than medium,
  because thinking less at each step costs extra agentic rounds", and
  that the right unit for agent work is rounds multiplied by time per
  round, not per-request latency. Caveat: it is one blog, its agentic
  index is its own, and the same page's qualitative test is a single
  "build me a website" task, not a repository task.
- **Against, weakly.** On the model's own Hugging Face discussion
  "This model cannot stop thinking", the complaint is about the
  **default, xhigh**, and the top answer recommends **medium** as the
  fix: about one third less wait "without quality loss". That is the
  opposite of the report. It is a forum reply with no published
  measurement.
- **For, weakly.** The same blog notes medium spent more total tokens
  than xhigh in its website test, about 860K input and 38K output
  against 500K and 60K, without a proportionally better result. A
  setting that costs more than the level above it and delivers less is
  the shape of the report's complaint, seen once, on one task.
- **Neither.** The video the owner pointed at says nothing about effort
  levels (`qwen38-configs/video-dHK90xc9Q64.md`).

Two more findings that matter for how the trial is run:

- `{"enable_thinking": false}` is reported as unsupported on 3.8 where
  it worked on 3.6. Effort is graded here; there is no thinking-off
  arm to add.
- Effort is settable per request as
  `{"chat_template_kwargs": {"reasoning_effort": "..."}}`, or
  server-wide with `--reasoning-effort`, which our row already does.
  A community workaround, adding "think carefully but BRIEF" to the
  template, is reported to cut reasoning tokens without hurting output.
  It is a third arm the trial could add for free.

**Nothing here settles it.** Every source is single-turn or
qualitative, and none runs a repository agent loop. Our own 87 was
scored at medium and completed. The trial as written, the Mendel smoke
at low and at xhigh against the medium row's 87, is still the only way
to answer it, and it is now more interesting, not less, because the
public evidence points the other way.

### Known defects worth carrying

- **llama.cpp issue 27756, silent end-of-sequence past about 130K.**
  **Still open** as of this survey. Title: "Qwen3.5-hybrid 64-layer
  (Qwen3.8-27B): silent instant-EOS beyond ~130k context on both CUDA
  and CPU". Prefill completes with no error and the correct token
  count, then generation stops at `tokens_predicted = 1` with
  `stop_type` "eos" and empty content. The failure zone is
  non-monotonic between about 130K and 133K and deterministic past
  about 174K. The reporter's hypothesis is per-layer accumulation error
  in the Gated DeltaNet recurrent state, which fits the 27B's 48 GDN
  layers; the 35B variant with fewer such layers survives longer
  contexts. No fix, no PR, no workaround is named in the issue.
  **Metal is neither confirmed nor excluded: the report covers CUDA and
  CPU only.** For us the effect is a cap, not a blocker: it puts a hard
  ceiling near 128K on every GGUF row above, which removes the deep
  q8_0 columns from consideration and clips shortlist build 3 from a
  projected 132K to about 128K. A silent EOS also looks exactly like a
  finished turn to a harness, so an agent run that hits it would score
  as a partial with no error in any log. If a shortlisted build is ever
  served above 120K, the smoke must include a long-prompt completion
  check.
- **`mlx_lm.server` has no quantized KV**
  ([mlx-lm #1043](https://github.com/ml-explore/mlx-lm/issues/1043)),
  already recorded in `kv-quant-on-m1.md`. It is why the MLX table has
  no q8_0 column.
- **Quantized KV is slow on this chip under llama.cpp**, 2 to 4 µs per
  cached token against 0.2 to 0.3 at f16 (`kv-quant-on-m1.md`). Every
  q8_0 column above is therefore a memory statement only. It buys
  window and it costs depth speed, and this model already sits at
  15 tok/s at 49K.
- **i-quants below 4 bits on pre-M4 Apple Silicon** are reported slow
  against K-quants. Unmeasured on this machine. It is the reason
  shortlist build 1 is a K-quant.

## Sources

- Qwen3.8-27B config and card: https://huggingface.co/Qwen/Qwen3.8-27B
- bartowski GGUF: https://huggingface.co/bartowski/Qwen3.8-27B-GGUF
- bartowski file sizes: https://huggingface.co/api/models/bartowski/Qwen3.8-27B-GGUF/tree/main
- unsloth GGUF: https://huggingface.co/unsloth/Qwen3.8-27B-GGUF
- unsloth run-locally guide: https://unsloth.ai/docs/models/qwen3.8
- AtomicChat GGUF: https://huggingface.co/AtomicChat/Qwen3.8-27B-GGUF
- AtomicChat metrics dataset: https://huggingface.co/datasets/AtomicChat/Qwen3.8-27B-GGUF-metrics
- AtomicChat metrics raw: https://huggingface.co/datasets/AtomicChat/Qwen3.8-27B-GGUF-metrics/raw/main/results.json
- AtomicChat comparison post: https://huggingface.co/Qwen/Qwen3.8-27B/discussions/65
- AtomicChat collection: https://huggingface.co/collections/AtomicChat/qwen-38-27b-6a7c86fe00e317b78f572767
- AtomicChat MLX DWQ 3.50 bpw: https://huggingface.co/AtomicChat/Qwen3.8-27B-MLX-AD-3.50bpw-DWQ-12.7GB
- AtomicChat MLX DWQ 3.70 bpw: https://huggingface.co/AtomicChat/Qwen3.8-27B-MLX-AD-3.70bpw-DWQ-13.4GB
- ISTA-DASLab GSQ-RCO GGUF: https://huggingface.co/ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF
- ISTA-DASLab 3-bit GSQ, vLLM only: https://huggingface.co/ISTA-DASLab/Qwen3.8-27B-3Bit-GSQ
- GSQ paper: https://arxiv.org/abs/2604.18556
- RCO paper: https://arxiv.org/abs/2605.00649
- mlx-community 4-bit: https://huggingface.co/mlx-community/Qwen3.8-27B-4bit
- mlx-community MTP 4-bit: https://huggingface.co/mlx-community/Qwen3.8-27B-MTP-4bit
- lmstudio-community MLX 4-bit: https://huggingface.co/lmstudio-community/Qwen3.8-27B-MLX-4bit
- llama.cpp issue 27756: https://github.com/ggml-org/llama.cpp/issues/27756
- llama.cpp discussion 27164, getting this model to run: https://github.com/ggml-org/llama.cpp/discussions/27164
- llama.cpp discussion 5617, IQ quant speed on Apple Silicon: https://github.com/ggml-org/llama.cpp/discussions/5617
- mlx-lm issue 1043, no quantized KV in the server: https://github.com/ml-explore/mlx-lm/issues/1043
- Agentic index and effort levels: https://www.mindstudio.ai/blog/qwen-3-27b-local-benchmark
- "This model cannot stop thinking": https://huggingface.co/Qwen/Qwen3.8-27B/discussions/113
- "A crazy thinking model": https://huggingface.co/Qwen/Qwen3.8-27B/discussions/97
