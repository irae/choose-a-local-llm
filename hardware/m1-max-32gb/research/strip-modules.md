# Strip modules the coding task does not use

Status: draft 2026-09-06. Needs hardware: yes, one load pair per GGUF
model on llama-server (with and without the mmproj), about ten minutes
each; nothing on MLX or LM Studio.

Every trusted model ships a vision tower next to the text model. The
coding task never sends an image, so the tower is dead weight if the
runtime loads it. This item answers, from the files and the runtime
sources, which of our rows still carry a module they do not use, what
the drop saves, and whether the drop can move decode speed. The
outcome: every GGUF row already drops the tower with `--no-mmproj`; no
MLX package we serve carries a tower on disk; the LM Studio row has
nothing to drop. The only open number is the size of the saving the
GGUF rows already take, which the Mac procedure measures.

## What the desk part found

Sizes are the Hugging Face file sizes, in MB (10^6 bytes). "Text path
loads it" says whether the serving command on the report page loads
the module today.

| model | backend | module | text path loads it | switch | saving MB | speed effect | source |
|---|---|---|---|---|---|---|---|
| Qwen3.8-27B | llama-server, `bartowski/Qwen3.8-27B-GGUF:Q4_K_M` | vision tower + projector, `mmproj-Qwen3.8-27B-f16.gguf` (928 MB; bf16 931 MB) | no, `--no-mmproj` is in the command | `--no-mmproj`; without it `-hf` downloads and loads the mmproj on the GPU at start | 928 weights + projector compute buffers (unmeasured; the community range is 500 to 1000 MB) | memory only; the projector is not in the text decode graph | [S1] [S2] [S6] [S7] [S8] |
| Qwen3.8-27B | llama-server, same file | MTP head, embedded, stored at Q4_0 | yes, and it pays (12.44 to 16.93 tok/s on the report page) | leave `--spec-type draft-mtp` out; llama.cpp skips the MTP tensors at load since commit 82dbc4f (2026-07-31) | about 200 to 300, estimate: the head is about 800 MB in bf16 for the 27B Qwen3.5 sibling, so about a quarter of that at Q4_0 | none; the head is only read when the drafter runs | [S2] [S9] [S10] |
| Qwen3.8-27B | mlx_lm.server, `mlx-community/Qwen3.8-27B-4bit` | vision tower | no; the weight map holds no `visual` or `vision_tower` key (16,054 MB of text weights only); `config.json` keeps a `vision_config`, but the loader's `sanitize` drops `vision_tower`, `model.visual` and `mtp.` keys anyway | none needed | 0 | none | [S11] [S12] [S13] |
| Qwen3.6-35B-A3B | llama-server, `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` | vision tower + projector, `mmproj-F16.gguf` (899 MB; BF16 903 MB; F32 1,786 MB) | no, `--no-mmproj` is in the command; the card says `--mmproj` and MTP do not work together | `--no-mmproj` | 899 + compute buffers | memory only | [S3] [S6] [S7] |
| Qwen3.6-35B-A3B | llama-server, same file | MTP head, embedded | yes, and it pays (68 to 74 tok/s shallow) | leave `--spec-type draft-mtp` out; skipped at load | not stated by the vendor; small against the 22,854 MB file | none | [S3] [S10] |
| Qwen3.6-35B-A3B | mlx_lm.server, `mlx-community/Qwen3.6-35B-A3B-4bit` | vision tower | no; no `visual` key in the weight map (20,402 MB text weights only); `qwen3_5_moe` loader drops vision and `mtp.` keys | none needed | 0 | none | [S12] [S13] |
| Gemma-4-26B-A4B | llama-server, `unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL` | vision encoder (about 550M params) + projector, `mmproj-F16.gguf` (1,193 MB; BF16 1,195 MB; F32 2,291 MB) | no, `--no-mmproj` is in the command | `--no-mmproj` | 1,193 + compute buffers | memory only | [S4] [S14] [S6] |
| Gemma-4-26B-A4B | llama-server, same repo | MTP drafter, separate file `MTP/mtp-gemma-4-26B-A4B-it.gguf` (462 MB) | yes, and it pays (60.3 tok/s at 4K) | leave `--spec-type draft-mtp` out; the file is not loaded | 462 | none at load; the drafter only costs depth (the floor arrives shallower) | [S4] |
| Gemma-4-26B-A4B | mlx_lm.server, `mlx-community/gemma-4-26b-a4b-it-4bit` | vision encoder | no; the weight map holds only three `embed_vision.embedding_projection.*` keys (a linear layer, a few MB) and no `vision_tower` (15,341 MB total); `gemma4` loader drops `vision_tower`, `multi_modal_projector`, `audio_tower`, `embed_audio`, `embed_vision`, `vision_embedder` | none needed | 0 to a few MB | none | [S15] [S16] |
| Gemma-4-12B | llama-server, `unsloth/gemma-4-12b-it-GGUF:Q4_K_XL` | image and audio projections, `mmproj-F16.gguf` (175 MB; F32 210 MB); the 12B is encoder-free, raw patches and waveforms go through linear layers | no, `--no-mmproj` is in the command | `--no-mmproj` | 175 + compute buffers | memory only | [S5] [S17] |
| Gemma-4-12B | llama-server, same repo | MTP drafter, separate `MTP/mtp-gemma-4-12b-it.gguf` (465 MB) | only in the MTP rows; the usable agent row (#2) has no drafter | as above | 465 | none | [S5] |
| Gemma-4-12B | LM Studio MLX engine, `lmstudio-community/gemma-4-12B-it-MLX-4bit` (`gemma4_unified`) | image and audio projections | the weight map holds only `embed_vision.embedding_projection.*` and `embed_audio.embedding_projection.*` (three keys each) in 6,741 MB; no tower exists to drop. LM Studio has no text-only load switch (`lms load` has none; feature request open since 2026-04-06) | none exists, none needed | about 0 | none | [S18] [S19] [S20] [S21] |
| Ternary Bonsai-27B | mlx_lm.server, `prism-ml/Ternary-Bonsai-27B-mlx-2bit` | vision tower (the card: about 0.46B params, "HQQ 4-bit", 0.63 GB, loaded only with images) | no; the weight map holds no `visual` key (8,491 MB text weights); the `qwen3_5` loader drops vision keys anyway | none needed | 0 | none | [S22] [S13] |
| Ternary Bonsai-27B | prism fork llama-server, `Ternary-Bonsai-27B-Q2_g64.gguf` | vision tower, `Ternary-Bonsai-27B-mmproj-Q8_0.gguf` (629 MB; BF16 931 MB) | no; the command loads a local file with `-m` and no `--mmproj`; auto-load applies to `-hf` only | none needed | 0 against today's row (629 if someone adds `--mmproj`) | none | [S23] [S7] |
| Ternary Bonsai-27B | prism fork, same repo | DSpark drafter, separate `Ternary-Bonsai-27B-dspark-Q4_1.gguf` (1,946 MB) | no; the scored row has no drafter (it helps only at shallow depth) | leave the drafter file out | 1,946 against a drafter row | none at load; depth cost as with every drafter | [S23] |
| all five | all | audio encoder | none of the five carries one; the Gemma 12B audio path is the projection above | - | 0 | - | [S4] [S17] |
| the two MoE (Qwen3.6, Gemma-26B) | all | unused experts | every expert stays on disk and in memory; llama-server, mlx-lm and LM Studio have no switch that drops experts at load; a pruned checkpoint is a different model | none | 0 | - | [S6] [S12] |

How the estimate is built: the weight part of the saving is the mmproj
file size, because llama-server maps the projector into GPU memory at
start when it is given (`-hf` fetches it unless `--no-mmproj` is
passed). The compute-buffer part is unknown for Metal; llama.cpp only
fixed its fit estimator to count the projector's GPU memory in
2026 (issue 19980, closed by PR 21489), and the on-demand-load
proposal quotes 500 MB to 1 GB for "VRAM/RAM" as a whole. One user
reports 885 MiB of VRAM for `mmproj-F16` next to a Qwen3.8-27B Q6_K.
A Mac-specific note for this exact model on an M1 Max 32 GB puts the
`mmproj-F16` at 0.93 GB "file and runtime" and says not to load it
for text work; it gives no tok/s. No source measures decode speed
with and without the tower on Apple Silicon. The design says the
effect is zero: the projector is a separate `mtmd` context that runs
only when a prompt holds an image, and the contributor in discussion
20246 counts only the LLM prefill of the image embeddings as decode
cost. The one indirect path is memory: about 900 to 1,200 MB more
wired memory near the 24000 limit means an earlier compaction start
and, on a GGUF row at its largest `-c`, an OOM at load.

What this means for the seed item (`qwen38-configs.md`, step 1): the
llama row is already vision-free; the MLX container never had the
tower on disk; LM Studio does not serve Qwen3.8 here. The step closes
on the desk, and the Mac part below only writes the number down.

## Mac procedure

Goal: put a wired-MB number on the saving each GGUF row already takes,
and confirm the decode speed does not move. The pair runs on the same
`-c`, KV type and drafter setting. Run the Qwen3.8 pair first; the
other two are optional and follow the same steps. Gemma-12B's 175 MB
is below the noise of `vm_stat` between runs; skip it.

1. Prepare the machine as the checklist says (wired limit 24000, no
   other server up). Note the idle wired pages:
   `vm_stat | grep "Pages wired down"` (pages of 16384 bytes;
   MB = pages × 16384 / 10^6).
2. Start the "without" server: the report page's command for the row,
   unchanged. For Qwen3.8:

   ```bash
   llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
     --alias qwen3.8-27b --no-mmproj \
     --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
     -ngl 999 -fa on -c 49152 \
     --cache-type-k f16 --cache-type-v f16 \
     --jinja --port 8081 2>&1 | tee /tmp/qwen38-nommproj.log
   ```

3. When the server answers `/health`, read wired pages again and
   subtract the idle value: that is `wired_without`. Also keep the
   log's `Metal_Mapped model buffer size` and `compute buffer size`
   lines.
4. Send one warmup completion (the py prompt, 256 tokens,
   temperature 0, raw `/completion`) and read
   `.timings.predicted_per_second`, with `draft_n_accepted`. Send it
   once more and keep the second value: `tok_s_without`.
5. Run one depth step of the creep at the row's deepest clean depth:
   `DEPTH_LIST=32768 MODEL=qwen3.8-27b SWEEP_BASE=http://127.0.0.1:8081
   python3 tools/sweeps/creep_llama.py > /tmp/qwen38-nommproj-creep.tsv 2>&1`.
   Keep the tok/s and the memory column: `creep_without`.
6. Stop the server. Wait for the wired recovery the machine file
   describes.
7. Start the "with" server: the same command with `--no-mmproj`
   removed. `-hf` downloads the repo's mmproj on the first run; the
   log names the file, write its name down. If the server refuses the
   projector together with the drafter (the Qwen3.6 card says the two
   do not combine), remove `--spec-type draft-mtp --spec-draft-n-max N`
   from both sides of the pair and start again from step 2.
8. If the "with" server fails to load at the row's `-c`, that is the
   result: record the failure and the largest `-c` that loads with the
   projector, in 8192 steps down. Otherwise repeat steps 3 to 5 for
   `wired_with`, `tok_s_with`, `creep_with`.
9. Pass rule. The item closes as "memory only, already taken" when
   `wired_with − wired_without` is at least the mmproj file size
   (928 MB for Qwen3.8, 899 for Qwen3.6, 1,193 for Gemma-26B) and the
   two tok/s values at step 4 and at step 5 are within 3% of each
   other. A tok/s gap above 3% with the projector loaded is a finding
   in its own right: log it in the benchmarks with both server logs,
   because the design says it should not happen. Record
   `wired_with − wired_without − mmproj MB` as the projector's compute
   buffer cost on Metal; the report pages carry that number next to
   `--no-mmproj`.

Optional pairs, same steps: Gemma-26B on
`unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL` at `-c 212992` (expect an
OOM at load on the "with" side; then step 8 applies), and Qwen3.6 on
`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` at `-c 49152` with the
drafter removed on both sides.

## Sources

- [S1] bartowski/Qwen3.8-27B-GGUF file list, mmproj sizes:
  https://huggingface.co/api/models/bartowski/Qwen3.8-27B-GGUF/tree/main
- [S2] bartowski/Qwen3.8-27B-GGUF model card ("MTP layers are
  included in these quants", "stored at Q4_0"; "`-hf` downloads the
  mmproj automatically"): https://huggingface.co/bartowski/Qwen3.8-27B-GGUF
- [S3] unsloth/Qwen3.6-35B-A3B-MTP-GGUF file list and card
  ("`-np > 1` and `--mmproj` are not yet supported with MTP"):
  https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF
- [S4] unsloth/gemma-4-26b-a4b-it-GGUF file list (mmproj, `MTP/`):
  https://huggingface.co/api/models/unsloth/gemma-4-26b-a4b-it-GGUF/tree/main
- [S5] unsloth/gemma-4-12b-it-GGUF file list:
  https://huggingface.co/api/models/unsloth/gemma-4-12b-it-GGUF/tree/main
- [S6] llama.cpp server README, `--mmproj`, `--no-mmproj`,
  `--no-mmproj-offload`, "mmproj is also downloaded automatically if
  available. to disable, add --no-mmproj":
  https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md
- [S7] llama.cpp docs/multimodal.md (auto-download with `-hf`,
  projector offloaded to GPU by default):
  https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal.md
- [S8] llama.cpp discussion 20246 (885 MiB VRAM for mmproj-F16 next to
  Qwen3.8-27B Q6_K; only the LLM prefill of image embeddings is decode
  cost): https://github.com/ggml-org/llama.cpp/discussions/20246
- [S9] NodeNestor, MTP for Qwen3.5-27B in llama.cpp (MTP tensors
  about 800 MB download):
  https://github.com/NodeNestor/qwen3.5-27b-mtp-llamacpp
- [S10] llama.cpp issue 26765 (commit 82dbc4f "load MTP tensors only
  if they are really used", `TENSOR_SKIP` when `--spec-type draft-mtp`
  is absent): https://github.com/ggml-org/llama.cpp/issues/26765
- [S11] mlx-community/Qwen3.8-27B-4bit config and weight map:
  https://huggingface.co/mlx-community/Qwen3.8-27B-4bit/raw/main/config.json
  and https://huggingface.co/mlx-community/Qwen3.8-27B-4bit/raw/main/model.safetensors.index.json
- [S12] mlx-community/Qwen3.6-35B-A3B-4bit weight map:
  https://huggingface.co/mlx-community/Qwen3.6-35B-A3B-4bit/raw/main/model.safetensors.index.json
- [S13] mlx-lm `qwen3_5.py`, `sanitize` skips `vision_tower`,
  `model.visual` and `mtp.` keys:
  https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/models/qwen3_5.py
- [S14] google/gemma-4-26b-a4b-it model card (vision encoder about
  550M, no audio): https://huggingface.co/google/gemma-4-26b-a4b-it
- [S15] mlx-community/gemma-4-26b-a4b-it-4bit weight map:
  https://huggingface.co/mlx-community/gemma-4-26b-a4b-it-4bit/raw/main/model.safetensors.index.json
- [S16] mlx-lm `gemma4.py`, `sanitize` skips `vision_tower`,
  `multi_modal_projector`, `audio_tower`, `embed_audio`,
  `embed_vision`, `vision_embedder`:
  https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/models/gemma4.py
- [S17] google/gemma-4-12b-it model card (encoder-free, linear
  projections for image and audio): https://huggingface.co/google/gemma-4-12b-it
- [S18] lmstudio-community/gemma-4-12B-it-MLX-4bit config and weight
  map: https://huggingface.co/lmstudio-community/gemma-4-12B-it-MLX-4bit/raw/main/model.safetensors.index.json
- [S19] LM Studio, `lms load` flags (no vision flag):
  https://lmstudio.ai/docs/cli/load
- [S20] LM Studio bug tracker 1760, text-only load request, open since
  2026-04-06, workaround is to move the mmproj file:
  https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/1760
- [S21] LM Studio blog, unified MLX engine ("conditionally load a
  `VisionAddOn`"): https://lmstudio.ai/blog/unified-mlx-engine
- [S22] prism-ml/Ternary-Bonsai-27B-mlx-2bit card and weight map:
  https://huggingface.co/prism-ml/Ternary-Bonsai-27B-mlx-2bit
- [S23] prism-ml/Ternary-Bonsai-27B-gguf file list (mmproj Q8_0 and
  BF16, dspark drafter):
  https://huggingface.co/api/models/prism-ml/Ternary-Bonsai-27B-gguf/tree/main
- [S24] llama.cpp issue 19980 (fit estimate did not count mmproj GPU
  memory; closed by PR 21489):
  https://github.com/ggml-org/llama.cpp/issues/19980
- [S25] llama.cpp discussion 20855 (on-demand mmproj load, "up to
  500MB to 1GB of VRAM/RAM"):
  https://github.com/ggml-org/llama.cpp/discussions/20855
- [S26] thomjiji/qwen-on-mac, Qwen3.8-27B GGUF on an M1 Max 32 GB
  (mmproj-F16 is 0.93 GB "file and runtime", do not load for text):
  https://github.com/thomjiji/qwen-on-mac/blob/main/docs/research/2026-08-20-unsloth-qwen3-8-27b-dynamic-v3-gguf.md
