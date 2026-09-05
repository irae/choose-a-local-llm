# Web research — serving failure modes (coordinator, 2026-09-03)

Sources gathered by a web-research sub-agent. Leads, not verified
truth: confirm versions and claims locally before acting.

## Gemma-4-12B newline flood (LM Studio MLX + agent harness)

Confirmed upstream:

- Model-level repetition collapse in Gemma 4 itself, across backends
  and seeds; `repeat_penalty` 1.0-1.5 has no effect; Gemma 3 27B does
  not show it. https://github.com/google-deepmind/gemma/issues/622
  and /610.
- Gemma-4-12B specific: deterministic "thought\n thought\n" loop on
  long agent prompts with many tool definitions, 44-60% repro, present
  in full F16 (not a quant artifact).
  https://huggingface.co/google/gemma-4-12B-it/discussions/41
- LM Studio's bundled Gemma-4 Jinja template crashes on tool calls
  (`format_type_argument` undefined); a fix macro is in the issue.
  https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/2012
  (also /1749, and /2110 — context silently resets after a tool call).
- MLX engine: thinking never terminates and `enable_thinking:false`
  is ignored. https://github.com/lmstudio-ai/mlx-engine/issues/337
- MLX engine ignores the set context length and mishandles stop
  sequences. lmstudio-bug-tracker issues 2250 and 1829;
  https://github.com/ml-explore/mlx-examples/issues/524
- mlx-lm ships with repetition penalty off by default.
  https://github.com/ml-explore/mlx-lm/issues/1669
- The 26B-A4B MoE build reportedly shows zero loops under the same
  test that loops 12B 44-60% of the time.
- Research curiosity: a locatable "repetition neuron" (arXiv
  2410.13497) — not production-safe, but the circuit is real.

## mlx_lm.server Metal OOM dead thread

Confirmed open bug, unfixed through v0.31.3:

- The generation thread dies on an uncaught exception; /health keeps
  returning 200 — the handler never checks the thread.
  https://github.com/ml-explore/mlx-lm/issues/1505
- OOM cause: unbounded prompt/KV cache growth (issues 1390, 854);
  allocator fragmentation after long uptime (1015); kernel-panic
  variant (883); livelock variant (1493).
- Unmerged fix PRs: 1513 (keep loop alive), 1514 (fail fast 503),
  1791 (make /health reflect thread death).
- Levers: `--prompt-cache-bytes` (aggregate cap) and
  `--prompt-cache-size` (sequence count); neither bounds one long
  conversation. `--max-kv-size` exists in the library but is not
  exposed by the server (request: issue 615). `MLX_GPU_MEMORY_LIMIT`
  did not prevent a reporter's crash.
- Field-proven workaround: a `threading.excepthook` wrapper that
  calls `os._exit()` so the supervisor restarts the process honestly.

## llama.cpp -ngl 999 / MTP drafter

- `--fit` (auto layer fit) is unreliable; UMA (Apple unified memory)
  accounting is admitted broken.
  https://github.com/ggml-org/llama.cpp/issues/22592
- `-fit on` ignoring the MTP drafter's memory need → OOM crash: fixed
  by https://github.com/ggml-org/llama.cpp/pull/23485 (issue 23472).
  On the fixed build the process EXITS instead of lingering broken —
  check our brew build's vintage against this PR.
- /health previously did not reflect true state; fixed by PR 20817
  (issue 20684).
- Drafter/main context-size mismatch causes a separate crash
  (issue 22554).
- Our exact symptom (drafter alloc fails, /health green, every
  request 500s, Metal) has NO confirmed upstream issue — a pinned
  minimal repro (research run 1, goal 3.4) is the input for filing
  one.
- Hardcoded `-ngl 999` bypasses fit entirely — usage problem, not a
  bug.
