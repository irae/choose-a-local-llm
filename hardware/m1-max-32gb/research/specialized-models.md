# Specialized models for personal-life work on this machine

Status: draft 2026-09-06. Needs hardware: yes, the M1 Max at wired limit 24000, with llama-server, mlx_lm.server, a Python MLX runtime (mlx-vlm, mlx-audio) and whisper.cpp installed, plus five real inputs (below).

## Why

The coding seats are covered by the reports. Personal-life work needs other model types: document OCR for receipts and bank statements, speech recognition in English and Brazilian Portuguese, email reading, spreadsheet and SQL help, and search. Most of this work fits in models under 2 GB, so it can sit beside a coding server if the memory arithmetic holds. This item picks candidates from primary sources and writes the measurement the Mac must do. Every candidate here serves an HTTP API, or a wrapper that does exists; candidates without one are marked.

Memory at load in the tables is an estimate from file sizes unless marked "measured". Nothing in this file was measured on this machine. "Fits beside coder" means: file plus projector plus a small cache under 4 GB. A 25 GB coding server leaves about 4 GB for the kernel wire and every app, so beside it only the sub-2 GB rows are worth a try, and the procedure measures whether even those hold. Beside the Bonsai desktop profile (9.8 GB) every row under 8 GB fits.

## OCR and document to table

Two layers exist. Layout-aware document models read a page image and emit markdown with tables. Plain OCR emits text lines only; the table structure is then lost for statements. The document models below are all under 1 GB of weights and run on llama-server with `--mmproj`, so they are the first pick.

| candidate | format and size | memory at load | runtime and API | languages | quality, source | license |
|---|---|---|---|---|---|---|
| GLM-OCR (0.9B) | GGUF `ggml-org/GLM-OCR-GGUF`: Q8_0 950 MB, f16 1.79 GB, mmproj Q8_0 484 MB | about 2 GB (estimate) | llama-server `-hf ggml-org/GLM-OCR-GGUF:Q8_0`, `--flash-attn off` reported necessary; mlx-vlm guide in the repo | "8 languages", names not listed on the card; Portuguese not verified | OmniDocBench v1.5 94.62, model card | MIT, layout component Apache-2.0 |
| PaddleOCR-VL-1.5 (1.0B) | GGUF `PaddlePaddle/PaddleOCR-VL-1.5-GGUF`: model 936 MB, mmproj 882 MB | about 2.5 GB (estimate) | llama-server `-m ... --mmproj ... --temp 0` from the card; the ggml blog notes "may have degraded performance" in llama.cpp | multilingual; the v1.0 card claims 109 languages, v1.5 card does not list them; Portuguese not verified | OmniDocBench v1.5 94.5, model card; olmOCR-bench 80.0 (v1.0), olmocr README | Apache-2.0 |
| Granite-Docling-258M | GGUF `ibm-granite/granite-docling-258M-GGUF`: bf16 332 MB, mmproj f16 190 MB; MLX `granite-docling-258M-mlx` | under 1 GB (estimate) | llama-server; docling VlmPipeline with MLX; docling-serve HTTP API `/v1/convert/source` | English; ja, ar, zh experimental; Portuguese not claimed | table TEDS 0.97, full-page OCR F1 0.84, model card; no OmniDocBench or olmOCR-bench number found | Apache-2.0 |
| DeepSeek-OCR-2 (3B) | GGUF `SandLogicTechnologies/DeepSeek-OCR-2-GGUF`: IQ4_XS 1.64 GB, IQ4_NL 1.7 GB, mmproj bf16 929 MB | about 3.5 GB (estimate) | llama.cpp with the deepseekocr2 projector (PR 20975); vLLM OpenAI-compatible | "multilingual", not listed | OmniDocBench 73.01 overall, model card (a different score scale than v1.5 above; not comparable); DeepSeek-OCR v1 olmOCR-bench 75.7, olmocr README | Apache-2.0 |
| Chandra 2 (5B, Qwen3.5 base) | GGUF community only (`SandLogicTechnologies/chandra-ocr-2-GGUF`, F16 9.7 GB, Q2_K 2.12 GB; Q4 about 3.5 GB, not verified) | 5 to 6 GB at Q4 (estimate) | vLLM and transformers officially; llama.cpp via community GGUF, not verified working | 90+ languages, Portuguese among the 43 benchmarked | olmOCR-bench 85.8 +/- 0.8, chandra README | code Apache-2.0; weights modified OpenRAIL-M, free for personal use; the HF card is gated (401) |
| Apple Vision OCR via `ocrmac` | no weights to download, system framework | small, not measured | Python library only, no HTTP API; docling can use it as an OCR engine, and docling-serve gives the API | per-language packs by IANA code, pt-BR available in macOS; not verified here | no public benchmark number found | MIT (wrapper) |
| Gemma-4-E4B-it (general VLM fallback) | GGUF `unsloth/gemma-4-E4B-it-GGUF`: Q4_K_M 4.98 GB, mmproj F16 990 MB | about 6.5 GB (estimate) | llama-server; mlx-vlm server; LM Studio | 35+ languages, Portuguese included | no document-parsing benchmark on the card; MMLU-Pro 69.4 | Apache-2.0 |

Top pick: GLM-OCR at Q8_0 on llama-server. Second: PaddleOCR-VL-1.5, same runtime, with the llama.cpp quality caveat. Granite-Docling is the smallest table extractor and plugs into docling-serve, which also handles PDF text layers without any model. For a PDF bank statement with a text layer, docling with no VLM is the first step; OCR only matters for scans and photos. Chandra 2 has the best olmOCR-bench number but its Q4 is too large beside a coding server and its llama.cpp path is not verified.

Not verified: Portuguese support in GLM-OCR and PaddleOCR-VL-1.5; whether the llama.cpp `-hf` flow loads the PaddleOCR projector on Metal; any memory number.

## Speech recognition

The bar is English with a non-native accent and Brazilian Portuguese. The Open ASR Leaderboard multilingual track (arXiv 2510.06961, table 4) reports Portuguese WER: Whisper large-v3 4.96, Parakeet TDT 0.6B v3 6.16, Canary 1B v2 6.33, Voxtral Small 24B average 3.70 across five languages. FLEURS Portuguese from model cards: Parakeet v3 4.76, Voxtral Mini 4B Realtime 5.03. None of these sets is Brazilian-accented English; that is why the procedure uses a real clip.

| candidate | format and size | memory at load | runtime and API | languages | quality, source | license |
|---|---|---|---|---|---|---|
| Whisper large-v3-turbo, whisper.cpp | `ggml-large-v3-turbo.bin` 1.62 GB; q5_0 574 MB; q8_0 874 MB; Core ML encoder zip 1.17 GB | about 1.5 to 2.5 GB (estimate; README gives large ~3.9 GB, turbo not listed) | whisper.cpp on Metal, optional Core ML encoder; `whisper-server` with an OpenAI-like API | 99 languages, pt included | English track WER 7.83, RTFx 200 on a GPU rig (arXiv 2510.06961 table 3); Portuguese only for large-v3 (4.96) | MIT (runtime); weights MIT |
| Whisper large-v3-turbo, mlx-whisper | `mlx-community/whisper-large-v3-turbo` 1.61 GB safetensors; 4-bit conversions exist | about 2 GB (estimate) | mlx-whisper CLI and Python only; mlx-audio `mlx_audio.server` serves `/v1/audio/transcriptions` | as above | same weights; 2.03x faster than whisper.cpp on one Mac in a 2026 blog run (billmill.org, chip not stated) | MIT |
| Parakeet TDT 0.6B v3 | `mlx-community/parakeet-tdt-0.6b-v3` 2.51 GB (fp32 safetensors) | about 2 GB (card says 2 GB RAM minimum) | parakeet-mlx CLI (no server); mlx-audio server; WhisperKit does not run it | 25 European languages, pt included; Portuguese variant not stated | Open ASR mean WER 6.34, RTFx 3332 on GPU; FLEURS pt 4.76, model card; multilingual track pt 6.16 | CC-BY-4.0 |
| Qwen3-ASR-1.7B | HF bf16 about 3.4 GB; `mlx-community/Qwen3-ASR-1.7B-8bit`; mlx-qwen3-asr 4-bit and 8-bit | 1.7B fp16 about 3.4 GB, 0.6B about 1.2 GB (mlx-qwen3-asr README) | mlx-qwen3-asr with a built-in OpenAI-compatible server; mlx-audio server; vLLM upstream | 30 languages, pt included | Fleurs multilingual average 4.90, LibriSpeech clean 1.63, model card; multilingual track average 5.11 | Apache-2.0 |
| Voxtral Mini 4B Realtime 2602 | `mlx-community/Voxtral-Mini-4B-Realtime-2602-4bit` 3.13 GB; community GGUF about 2.5 GB, llama.cpp support not upstream | about 3.5 GB (estimate) | mlx-audio server; vLLM upstream; llama.cpp not supported per the card | 13 languages, pt included | Open ASR mean WER 7.68, RTFx 93; FLEURS pt 5.03 at 480 ms delay, model card | Apache-2.0 |
| Canary 1B v2 | NeMo checkpoint, 978M params; no MLX or GGUF port found | not verified | NeMo only, no Apple Silicon runtime found | 25 languages; trained on European Portuguese per the card | Open ASR mean WER 7.15; multilingual track pt 6.33 | CC-BY-4.0 |
| WhisperKit (Argmax) | `large-v3-v20240930_626MB` compressed turbo | not verified | Core ML; `argmax-cli serve` implements the OpenAI Audio API | Whisper languages | no numbers on the README | MIT |

Top pick: whisper.cpp with large-v3-turbo q8_0 and `whisper-server`, because it is the only one with a verified server, Metal path and Portuguese number from the leaderboard. Runner-up for Portuguese: Parakeet TDT 0.6B v3 through the mlx-audio server (best FLEURS pt, but Brazilian versus European Portuguese is not stated). Qwen3-ASR-1.7B is the one to test for accented English, on mlx-qwen3-asr's server. Real-time factors on M1 class hardware were not found from a primary source for any of them; the blog runs cited are on unstated or newer chips. This is the main thing the Mac must measure.

Not verified: memory at load for every row; the Core ML encoder gain on M1 Max; whether Parakeet handles Brazilian Portuguese as well as its FLEURS number suggests.

## Reading and summarizing email

No current specialized open model exists for email. The only fine-tune found (`wordcab/t5-small-email-summarizer`, T5-small) is a 2023-class model with no comparable benchmark, and it does no reasoning, dates, or action items. Email work is instruction following plus summarization, so small general instruct models are the candidates.

| candidate | format and size | memory at load | runtime and API | languages | quality, source | license |
|---|---|---|---|---|---|---|
| Qwen3.5-4B | GGUF `unsloth/Qwen3.5-4B-GGUF`: Q4_K_M 2.74 GB, UD-Q4_K_XL 2.91 GB, Q8_0 4.48 GB | about 3.5 GB at Q4 with a 16K cache (estimate) | llama-server; mlx_lm.server; LM Studio | 201 languages, pt included | IFEval 89.8, MMLU-Pro 79.1, MMMLU 76.1, model card | Apache-2.0 |
| Gemma-4-E4B-it | GGUF Q4_K_M 4.98 GB, UD-Q4_K_XL 5.13 GB | about 6 GB (estimate) | llama-server; mlx-vlm server; LM Studio | 35+ languages | MMLU-Pro 69.4, MMMLU 76.6, model card; IFEval not extracted | Apache-2.0 |
| Gemma-4-12B-it (already on the machine) | as in the report | as measured there | llama-server, LM Studio | 35+ languages | see its report | Apache-2.0 |
| `wordcab/t5-small-email-summarizer` | about 240 MB HF weights | small | transformers only, no llama.cpp or MLX path, no server | English | no public benchmark | not verified |

Top pick: Qwen3.5-4B at UD-Q4_K_XL, thinking off, on llama-server; it is the smallest model with a strong IFEval number and fits beside the Bonsai seat. Gemma-4-12B already on the machine is the quality reference when a coding seat is not loaded.

## Spreadsheets and database queries for graphs

| candidate | format and size | memory at load | runtime and API | languages | quality, source | license |
|---|---|---|---|---|---|---|
| Arctic-Text2SQL-R1-7B (Qwen2.5-Coder-7B base) | GGUF `mradermacher/Arctic-Text2SQL-R1-7B-GGUF`: Q4_K_M 4.68 GB | about 5.5 GB (estimate) | llama-server | English prompts, SQL out | BIRD-dev 68.9, BIRD-test 68.5, Spider-test 88.8, model card; BIRD leaderboard lists 70.70 / 70.43 for the same model | Apache-2.0 |
| OmniSQL-7B | HF bf16, 3 community quantizations, sizes not verified | about 5.5 GB at Q4 (estimate) | llama-server if a GGUF loads; not verified | English, SQL | BIRD leaderboard dev 69.04, test 67.97 | Apache-2.0 |
| BIRD-Talon-7B | HF bf16 only, no model card | not verified | none verified | not stated | no score on the card; released with BIRD-Critic-SQLite | not stated |
| Qwen3.8-27B, Gemma-26B, Bonsai (already on the machine) | as in the reports | as measured | llama-server, mlx | multilingual | no text-to-SQL score measured here | as in the reports |

Top pick: none. The coding models already on the machine cover this; see the next section. Arctic-Text2SQL-R1-7B is the only well-scored specialist, and its Q4 does not fit beside a 25 GB coder, so it competes with the coder for the seat, not beside it. Spreadsheet building has no local specialist: SpreadsheetBench-class work is agentic, and open-weight scores on it range 0.05% to 23.65% (spreadsheetbench.github.io), so the coding agent with openpyxl or a CSV is the tool.

## What the coding models already cover

Spreadsheet building, formulas, CSV cleaning, openpyxl scripts, SQLite and DuckDB queries, and chart scripts are coding tasks. Qwen3.8-27B on llama-server is the seat for them, and Gemma-26B is the deep secondary; both finish the agent task on this machine. A text-to-SQL specialist at 7B scores about 70 on BIRD-dev, and a 27B coder is expected to match or pass it on the owner's small schemas, but that is not measured. The coding seats also read email and summarize a statement that already has a text layer. What they do not do: read a page image (Qwen3.8 GGUF has no projector loaded here), transcribe audio, or run under 4 GB. That is the whole reason for the OCR, speech, and 4B rows above. Online research needs a search backend (SearXNG through Vane or a tool-calling loop), and the coding seats already have the tool-calling ability; gpt-oss-20b (MXFP4 12.1 GB, Apache-2.0, built-in browsing tool) adds nothing here that Qwen3.8 with a search tool lacks, and it cannot share the machine with a coding server. Jan-nano-128k (4B, Apache-2.0) is a search-tool fine-tune; its SimpleQA number is published only as an image and is not verified.

## What the Mac must measure

Wired limit 24000, `sysctl iogpu.wired_limit_mb` re-run after any reboot. No sudo inside the procedure itself. Servers on 8081 as usual; whisper-server and mlx-audio take the next free port and the run notes it. Read wired MB from `vm_stat` and the server RSS before and after each item. Every model runs alone first, then the sub-2 GB winners run beside the Bonsai desktop profile (9.8 GB), then beside Qwen3.8 llama at `-c 49152`.

Inputs, kept under `hardware/m1-max-32gb/research/specialized-models/inputs/` and not committed if they carry personal data: one phone photo of a paper receipt; one two-page bank statement PDF with a text layer and the same statement printed and scanned to an image PDF; one one-minute English clip spoken with a Brazilian accent; one one-minute Brazilian Portuguese clip; one email thread of five messages exported as text. Write the reference for each once by hand: the receipt's total and line count, the statement's row count and closing balance, a verbatim transcript for each clip, and a five-line summary with the action items for the thread.

1. OCR. Load GLM-OCR Q8_0, PaddleOCR-VL-1.5, Granite-Docling on llama-server, each alone. Send the receipt image and each page of the scanned statement through `/v1/chat/completions` with the model's prompt from its card. Read wired MB, seconds per page, and decode tok/s from the server log. Pass: the receipt total matches, and the statement rows come back as a markdown table with the closing balance right and no more than one row wrong per page. Then run docling-serve with no VLM on the text-layer PDF and record the same pass rule; if it passes, the OCR step is for scans only.
2. Speech. Load whisper.cpp large-v3-turbo q8_0 under `whisper-server` (Metal, then with the Core ML encoder), Parakeet v3 and Qwen3-ASR-1.7B under `mlx_audio.server`, Voxtral Realtime 4-bit under the same. Send both clips to `/v1/audio/transcriptions`. Read wired MB, seconds per clip, and the real-time factor (seconds / 60). Score WER against the hand transcript with `jiwer`. Pass: WER under 10 on both clips and real-time factor under 0.5.
3. Email. Load Qwen3.5-4B UD-Q4_K_XL thinking off on llama-server, then Gemma-4-12B as the reference. Ask for the summary and action items of the thread. Read wired MB, decode tok/s, and seconds to the last token. Pass: every action item in the hand reference is present, and no invented one; under 30 s total.
4. Spreadsheet and SQL. Point the Qwen3.8 seat, then Arctic-Text2SQL-R1-7B Q4_K_M alone, at a SQLite of the statement rows from step 1. Ask for a monthly totals query and a chart script. Read decode tok/s. Pass: the query runs and the totals match the hand reference. If Qwen3.8 passes, Arctic is dropped.
5. Sharing. Bring up Bonsai at the desktop profile, then the OCR and speech winners one at a time beside it, and repeat one item each. Read wired MB and free MB. Pass: no OOM, item time within 1.5x of the alone number. Repeat beside Qwen3.8 llama at `-c 49152` only for the rows under 2 GB, and record which ones survive.
6. Search, low priority. Only if steps 1 to 5 close. Run Vane with SearXNG against the Qwen3.8 seat; one product-search question; read seconds to answer and whether the sources are real. No pass rule; record only.

## Sources

- GLM-OCR model card: https://huggingface.co/zai-org/GLM-OCR
- GLM-OCR repo (mlx-vlm guide): https://github.com/zai-org/GLM-OCR
- GLM-OCR GGUF files: https://huggingface.co/ggml-org/GLM-OCR-GGUF/tree/main
- GLM-OCR in llama.cpp, flags: https://github.com/ggml-org/llama.cpp/discussions/19721
- OCR models with llama.cpp: https://huggingface.co/blog/ggml-org/using-ocr-models-with-llama-cpp
- PaddleOCR-VL-1.5 model card: https://huggingface.co/PaddlePaddle/PaddleOCR-VL-1.5
- PaddleOCR-VL-1.5 GGUF files: https://huggingface.co/PaddlePaddle/PaddleOCR-VL-1.5-GGUF/tree/main
- DeepSeek-OCR-2 model card: https://huggingface.co/deepseek-ai/DeepSeek-OCR-2
- DeepSeek-OCR-2 GGUF files: https://huggingface.co/SandLogicTechnologies/DeepSeek-OCR-2-GGUF/tree/main
- Chandra 2 README and olmOCR-bench table: https://github.com/datalab-to/chandra
- Chandra 2 community GGUF: https://huggingface.co/SandLogicTechnologies/chandra-ocr-2-GGUF
- olmOCR README with the olmOCR-bench table: https://github.com/allenai/olmocr
- Granite-Docling model card: https://huggingface.co/ibm-granite/granite-docling-258M
- Granite-Docling GGUF files: https://huggingface.co/ibm-granite/granite-docling-258M-GGUF/tree/main
- docling-serve: https://github.com/docling-project/docling-serve
- docling VLM pipeline and M3 Max timings: https://docling-project.github.io/docling/usage/vision_models/
- ocrmac (Apple Vision wrapper): https://github.com/straussmaximilian/ocrmac
- mlx-vlm server: https://github.com/Blaizzy/mlx-vlm
- Open ASR Leaderboard paper, tables 3 and 4: https://arxiv.org/html/2510.06961v4
- Open ASR Leaderboard space: https://huggingface.co/spaces/hf-audio/open_asr_leaderboard
- whisper.cpp README (memory table, whisper-server, Core ML): https://github.com/ggml-org/whisper.cpp
- whisper.cpp model files: https://huggingface.co/ggerganov/whisper.cpp/tree/main
- mlx-whisper: https://github.com/ml-explore/mlx-examples/tree/main/whisper
- mlx-community whisper-large-v3-turbo: https://huggingface.co/mlx-community/whisper-large-v3-turbo/tree/main
- mlx_whisper vs whisper.cpp run: https://notes.billmill.org/dev_blog/2026/01/updated_my_mlx_whisper_vs._whisper.cpp_benchmark.html
- Parakeet TDT 0.6B v3 model card: https://huggingface.co/nvidia/parakeet-tdt-0.6b-v3
- Parakeet MLX weights: https://huggingface.co/mlx-community/parakeet-tdt-0.6b-v3/tree/main
- parakeet-mlx: https://github.com/senstella/parakeet-mlx
- mlx-audio (server, STT models): https://github.com/Blaizzy/mlx-audio
- Qwen3-ASR-1.7B model card: https://huggingface.co/Qwen/Qwen3-ASR-1.7B
- mlx-qwen3-asr (M4 Pro numbers, server): https://github.com/moona3k/mlx-qwen3-asr/
- Voxtral Mini 4B Realtime model card: https://huggingface.co/mistralai/Voxtral-Mini-4B-Realtime-2602
- Voxtral Realtime MLX 4-bit: https://huggingface.co/mlx-community/Voxtral-Mini-4B-Realtime-2602-4bit/tree/main
- Canary 1B v2 model card: https://huggingface.co/nvidia/canary-1b-v2
- WhisperKit / Argmax OSS: https://github.com/argmaxinc/WhisperKit
- Qwen3.5-4B model card: https://huggingface.co/Qwen/Qwen3.5-4B
- Qwen3.5-4B GGUF files: https://huggingface.co/unsloth/Qwen3.5-4B-GGUF/tree/main
- Gemma-4-E4B-it model card: https://huggingface.co/google/gemma-4-E4B-it
- Gemma-4-E4B-it GGUF files: https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF/tree/main
- T5 email summarizer: https://huggingface.co/wordcab/t5-small-email-summarizer
- BIRD leaderboard: https://bird-bench.github.io/
- Arctic-Text2SQL-R1-7B model card: https://huggingface.co/Snowflake/Arctic-Text2SQL-R1-7B
- Arctic-Text2SQL-R1-7B GGUF: https://huggingface.co/mradermacher/Arctic-Text2SQL-R1-7B-GGUF
- OmniSQL-7B: https://huggingface.co/seeklhy/OmniSQL-7B
- BIRD-Talon-7B: https://huggingface.co/birdsql/BIRD-Talon-7B
- SpreadsheetBench: https://spreadsheetbench.github.io/
- gpt-oss-20b model card: https://huggingface.co/openai/gpt-oss-20b
- gpt-oss-20b GGUF: https://huggingface.co/ggml-org/gpt-oss-20b-GGUF
- Jan-nano-128k: https://huggingface.co/Menlo/Jan-nano-128k
- Vane (formerly Perplexica), SearXNG front end: https://github.com/ItzCrazyKns/Perplexica
