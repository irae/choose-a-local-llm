# Web check — upstream status (coordinator, 2026-09-04)

Verified 2026-09-04 with WebFetch/WebSearch. "Open" = open on that day.

## 1. mlx-lm

- Latest release: v0.31.3, 2026-04-22. No later tag; PyPI latest is
  0.31.3. https://github.com/ml-explore/mlx-lm/tags
- Issue 1505 (uncaught exception in `_generate`, /health stays 200):
  open, filed 2026-07-09. Issue 1390 (Metal OOM after prompt cache
  grows to 23-26 GB): open, 2026-06-10. Issue 854 (crash on Metal OOM
  instead of HTTP error): open, 2026-02-07.
  https://github.com/ml-explore/mlx-lm/issues/1505 /1390 /854
- PR 1513 (keep loop alive): open, last activity 2026-08-24. PR 1514
  (fail fast, /health 503): open, 2026-08-31. PR 1791 (/health 503 on
  thread exit): open, "changes requested", 2026-09-01.
  https://github.com/ml-explore/mlx-lm/pull/1513 /1514 /1791
- `main` server.py: /health writes `{"status": "ok"}` with no thread
  check. `--prompt-cache-size` (default 10) and `--prompt-cache-bytes`
  exist. `--max-kv-size` is not a server flag.
  https://raw.githubusercontent.com/ml-explore/mlx-lm/main/mlx_lm/server.py
- Meaning: 0.31.3 is current; the dead-thread green-health bug is
  unfixed in any release and on main. Keep the external watchdog.

## 2. llama.cpp

- PR 23485 (`-fit` margin for draft model): merged 2026-05-24, commit
  83eebe9d. PR 20817 (httplib dynamic threads, issue 20684): merged
  2026-03-23, commit 31a5cf4c. Exact b-number of each: not found.
  https://github.com/ggml-org/llama.cpp/pull/23485 and /20817
- Homebrew formula: stable 0.3.0, tag v0.3.0, revision c1d0e7a0,
  formula data generated 2026-09-04.
  https://formulae.brew.sh/api/formula/llama.cpp.json
- v0.3.0 dated 2026-08-25 is the first semver "Latest" release;
  nightlies keep the b#### scheme (b10793 on 2026-09-03; v0.3.0 notes
  reference b10621). Both merges predate v0.3.0 by 3-5 months.
  https://github.com/ggml-org/llama.cpp/releases/tag/v0.3.0
- Server request params: `dry_multiplier` (0.0), `dry_base` (1.75),
  `dry_allowed_length` (2), `dry_penalty_last_n` (64),
  `dry_sequence_breakers`; `xtc_probability` (0.0), `xtc_threshold`
  (0.10); `repeat_penalty` (1.1), `repeat_last_n` (64).
  https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md
- Meaning: run `brew info llama.cpp`. If it is 0.3.0, both fixes are
  in the local build, so re-run the drafter OOM repro before filing.

## 3. LM Studio

- App: 0.4.23, 2026-08-28 (0.4.22 same day; 0.4.21 2026-08-12; 0.4.20
  2026-07-22; 0.4.19 2026-07-07). Changelogs 0.4.18-0.4.23 do not
  mention Gemma 4, MLX context, or stop sequences.
  https://lmstudio.ai/changelog/lmstudio
- Bug tracker, all open, no fix version: 2012 (Gemma 4 template
  `format_type_argument` missing) 2026-06-05; 2110 (context resets
  after tool call) 2026-06-27; 2250 (MLX auto-fit overrides context
  length) 2026-08-08; 1829 (output capped at ~10-16K tokens)
  2026-04-20; 2013 (reasoning delimiters default to `<think>` instead
  of `<|channel>thought`/`<channel|>`) 2026-06-05.
  https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/2012
- mlx-engine issue 337 (Gemma 4 reasoning never ends on MLX): open,
  2026-06-14. https://github.com/lmstudio-ai/mlx-engine/issues/337
- mlx-engine has no releases. Newest main commits: 2026-08-21 "Add
  MLX disk cache control" and "Increase autofitted context length";
  2026-07-31 "Add MLX context AutoFit load toggle (#355)".
  https://github.com/lmstudio-ai/mlx-engine/commits/main
- requirements.txt pins `mlx==0.32.0`, `mlx-metal==0.32.0`, and
  `mlx-lm @ git+...@2c008fd0`, which is 13 commits ahead of v0.31.3
  (unreleased main; includes server 404 fix #1327, Gemma 4 sanitize
  fix #1240).
  https://raw.githubusercontent.com/lmstudio-ai/mlx-engine/main/requirements.txt
- Meaning: every LM Studio issue in the plan stays open. An AutoFit
  toggle exists on mlx-engine main since 2026-07-31; check whether
  0.4.23 shows it. LM Studio's MLX path runs a newer mlx-lm than
  homebrew, so its results are not the same engine.

## 4. Gemma 4 repetition collapse and `<|channel>`

- gemma issues 622 (2026-04-11) and 610 (2026-04-04): open, no
  maintainer reply. https://github.com/google-deepmind/gemma/issues/622
- HF discussion 41 (12B "thought\n thought\n" loop, ~60%): closed.
  Google reproduced it, called it a "weight-level attractor" in full
  precision, and pointed to the template fix in discussion 35, merged
  2026-07-15 (null handling, keeps reasoning across tool-call chains,
  balanced turn tags).
  https://huggingface.co/google/gemma-4-12B-it/discussions/41 and /35
- `<|channel>` (open) and `<channel|>` (close) are the documented
  Gemma 4 tokens for "a model's internal process"; `<|channel>` is
  "always followed by the word 'thought'". No token is spelled
  `<|channel|>`. Same pattern for `<|turn>`/`<turn|>`,
  `<|tool_call>`/`<tool_call|>`, `<|tool_response>`/`<tool_response|>`.
  https://ai.google.dev/gemma/docs/core/prompt-formatting-gemma4
- `<|channel>` emitted as literal text (not the special id) is
  reported on vLLM (unsloth issue 5386). llama.cpp PR 21343 (merged
  2026-04-03) fixed Gemma 4 newline tokenization (`\n\n` = token 108).
  A "truncated" `<|channel>` token report: not found.
  https://github.com/ggml-org/llama.cpp/pull/21343
- Meaning: the local note "malformed `<|channel>` missing the closing
  pipe" is wrong; the token is correct. The failure is a thought
  channel that opens and floods newlines, which matches issue 337 and
  discussion 41. Check the local model's template date against the
  2026-07-15 fix, and GGUF conversion date against 2026-04-03.

## 5. `frequency_penalty` / `presence_penalty` per request

- llama-server: `/completion` documents both (default 0.0).
  `/v1/chat/completions` copies every unknown body key into
  `llama_params` ("allows user to use llama.cpp-specific params like
  mirostat via OAI endpoint"), so both pass through per request.
  https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md
  https://raw.githubusercontent.com/ggml-org/llama.cpp/master/tools/server/server-common.cpp
- mlx_lm.server: reads `frequency_penalty`, `presence_penalty`,
  `repetition_penalty` and `*_context_size` from the body and passes
  them to `make_logits_processors(...)`. Honoured per request.
  https://raw.githubusercontent.com/ml-explore/mlx-lm/main/mlx_lm/server.py
- Meaning: both servers accept the penalties per request. Only
  llama-server has DRY and XTC.
