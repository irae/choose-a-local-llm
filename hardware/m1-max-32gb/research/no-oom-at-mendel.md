# A config that reaches Mendel never runs out of memory

Research item of `m1-max-32gb`, opened as run 3 goal 3; attached files
in `no-oom-at-mendel/`. Owner rule to establish (2026-09-05): when a
config gets to a Mendel run, its window and budget values are safe, so
the run cannot end in a Metal OOM. Today they come from a creep
ceiling and a `maxTokens` rule; nothing tests the in-turn growth that
killed runs. This item derives the margin, tests it, writes the rule.

## Every memory incident in an agent run, from the committed records

All on `mlx_lm.server`; no llama-server agent run has an OOM anywhere.

| when | run and row | declared window / maxTokens | what happened | source |
| --- | --- | --- | --- | --- |
| 2026-09-02 | run 7, Qwen3.8 MLX blind low | 26624 / 16384 | eleven 1-token `length` stops, contexts 23566 to 23676, prompts 23565 to 23675: prompt plus budget did not fit the window; `tooling_budget_exhausted` at 89 percent. Not an OOM, the window arithmetic. No compaction fired in the whole session. | `../../../../mendel-benchmark/benchmark/runs/mlx-community-Qwen3.8-27B-4bit-low-issue-13-session.jsonl`, `run2/results/config-proposals.md` P1 |
| 2026-09-02 | run 7, Qwen3.8 MLX guided low v3 (invalid) | 26624 / 16384 | the context grew to 24138, 27421, 29062, 30333, 29640 and 30092 tokens, past the declared window, with 1-token stops between; then three generation-thread deaths, four error turns each. Peak 30333. Two compactions only, at 22313 and 22770; after the second the context climbed from 19529 to 30333 with none. | `.../runs/mlx-community-Qwen3.8-27B-4bit-low-guided-v3-issue-13-session.jsonl`; row in `benchmark/results-guided.json` |
| 2026-09-05 | run 9 block E, Qwen3.8 MLX guided low, three attempts (invalid) | 26624 / 8192 | eight 1-token stalls recovered by nudges; two Metal OOM crashes of the generation thread at prompts of 22892 and 27969 tokens, the second past the window, `/health` still 200. | `../benchmarks/bench9/results.md`, block E |
| 2026-09-04 | research run 2, Qwen3.8 MLX ceiling probe | no window, raw creep | the server thread died on the prompt-cache eval between 26708 and 28672 tokens at wired limit 24000; the last served row is 26708 at 15.4 tok/s. | `no-oom-at-mendel/inputs/qwen38-mlx-ceiling-sweep.log` and `.../qwen38-mlx-ceiling-server-tail.log` (copied from the Mac evidence `run2-qwen38-ceiling/`) |
| 2026-08-30 to 09-02 | Bonsai MLX, four scored rows | 57344 / 16384 | peaks 45850 to 51723, 80 to 89 percent of the window, no crash. The closest healthy runs to a ceiling. | `benchmark/results.csv`, `results-guided.csv`, `peak_context` |

llama-server, for contrast: Qwen3.6 GGUF peaked at 94448 of the 98304
window then declared and Gemma-12B thinking off at 125135 of 262144,
neither crashing, because llama preallocates the KV from `-c`. Run 9
found every published `-c` OOMs at load under the 24000 limit
(`../benchmarks/bench9/results.md` A1b), and run 10 that a `-c` which
loads and answers a trivial warmup can still fail on compute buffers
at the first 4096-token completion
(`../benchmarks/bench10/results.md` A1 and A2).

## What the numbers say

From the logs in `mendel-benchmark/benchmark/runs/` by the
`count-tool-calls.mjs` rule. Context is `usage.totalTokens`; a drop of
over 2000 tokens to the next prompt is a compaction; turn growth is
the largest `total_i - total_(i-1)`; cycle growth is the rise from a
compaction to that cycle's peak.

| Qwen3.8 session (`mlx-community-Qwen3.8-27B-4bit-...`) | peak | turn growth | cycle growth | largest one tool result |
| --- | --- | --- | --- | --- |
| `...-issue-13-session-1` | 22522 | 2609 | 19193, no compaction | 709 tok |
| `...-issue-13-session-2` | 23840 | 2420 | 20511, no compaction | 1016 tok |
| `...-low-issue-13-session` | 23676 | 2380 | 20083, no compaction | 2245 tok / 7292 chars |
| `...-low-guided-issue-13-session-1` | 22419 | 2538 | 18002, no compaction | 2281 tok / 7387 chars |
| `...-low-guided-issue-13-session-2` | 22539 | **3507** | 18122, no compaction | 2281 tok |
| `...-low-guided-v3-issue-13-session` | **30333** | 2649 | 17716, then 10804 (19529 to 30333) | 1826 tok |

- **Qwen3.8 MLX**: in-turn growth never passed **3507** and one tool
  result never passed **2281**; the v3 session's three
  generation-thread deaths follow turns at **29062, 29640, 29475**.
  Run 9 block E crashed at prompts 22892 and 27969
  (`../benchmarks/bench9/results.md`), run 2's creep between 26708 and
  28672 (`no-oom-at-mendel/inputs/`).
- **The worst case is not on Qwen3.8.** Bonsai MLX grew **17440** in
  one turn from one `bash` result of 51339 characters
  (`prism-ml-Ternary-Bonsai-27B-mlx-2bit-low-...`, peak 51723). pi
  truncates a bash result at 50 KB (finding 3) and these logs run 3.2
  characters per token, so **one tool result can add about 16000
  tokens** and a turn adds that plus the output up to `maxTokens`. A
  margin from Qwen3.8 alone is five times too small.
- **The window must sit below the ceiling by at least the in-turn
  growth.** Qwen3.8's MLX ceiling is 26708 to 28672 at wired limit
  24000 and the declared window 26624 sat 84 tokens under the last
  served depth, so growth past it lands in the dead band and no server
  check refuses it (finding 1). Compaction will not save it: none
  fired in five of the six sessions, twice in the sixth.

## Findings — the research is done, read it before you start

**Finding 1. `mlx_lm.server` cannot refuse a request it cannot serve.**
Source tag `v0.31.3`, the version the crash log names, at
https://raw.githubusercontent.com/ml-explore/mlx-lm/v0.31.3/mlx_lm/ .

- **No `--max-kv-size` on the server**: it is on `mlx_lm.generate`
  only (`generate.py:173`). `BatchGenerator.__init__` accepts
  `max_kv_size` (`:1510`) and would build a `RotatingKVCache` with it
  (`:1657`), but `server.py` omits it, so the KV is always unbounded.
  No prompt-length bound either, no truncation, no 4xx.
- **The crash path, and our traceback's lines**: `server.py:853`
  `batch_generator.next()` runs in `ResponseGenerator._generate` with
  **no `try` around it**; `next` (`generate.py:1855`) calls `_next`,
  which calls `self._prompt_batch.prompt(prompts)` (`:1841`), which
  materializes the KV at `:1161`, `mx.eval(...)`, where a Metal OOM
  surfaces. **The thread dies**; the HTTP side then blocks forever on
  `response_queue.get()` (`:1048`).
- **`--prompt-cache-size` is an entry count, not a memory cap**
  (`LRUPromptCache`, `models/cache.py:1623`); `--prompt-cache-bytes`
  caps the reuse pool only. Our ceiling log shows that pool at 3.47 GB
  with `--prompt-cache-size 2` just before the death, so **`1` is a
  real lever**; the only other prefill levers are
  `--prompt-concurrency` (8) and `--prefill-step-size` (2048).

**Finding 2. llama-server does check the fit at load, and `-ngl 999`
turns the check off.** From `common/arg.cpp`, `common/fit.cpp`,
`src/llama-context.cpp`, `src/llama-kv-cache.cpp`,
`ggml/src/ggml-metal/ggml-metal-device.m` and issues 21801 and 14836,
at https://github.com/ggml-org/llama.cpp .

- **`--fit` is on by default but only adjusts arguments you did not
  set**: an explicit `-c` gives `"context size set by user to ... ->
  no change"` (`fit.cpp:454`), and an explicit `-ngl` **aborts the
  whole fit** (`:463`, issue #21801) with a warning only (`:893`). Our
  commands all pass `-ngl 999` (now spelled `-ngl all`), so **every
  one runs with no fit check**.
- **The hard check is `sched_reserve()`** (`llama-context.cpp:582`,
  called at 461): it reserves the worst-case graph at load and throws
  `failed to allocate compute pp buffers`, and KV is allocated at load
  too (`llama-kv-cache.cpp:288`), so compute buffers are **not** lazy.
  Run 10 still saw a load pass and a first request fail because Metal
  reports `recommendedMaxWorkingSetSize` as total and a process can
  allocate past it: the reserve overcommits, the request cannot.
- **The compute buffer scales with `-ub`, not `-c`**:
  `n_tokens = min(n_ctx, n_ubatch)` in the reserve, and `-b` only caps
  `-ub` (`:245`); defaults `-b 2048`, `-ub 512`. **`-ub 256` or `128`
  is the largest reduction and costs prompt speed only.** With
  non-unified KV a slot gets `-c / -np` padded to 256 (`:291`);
  `-np auto` means 4 slots plus `--kv-unified` (`server.cpp:152`),
  under which `n_ctx_seq == n_ctx`, and `--kv-unified-per-slot N` caps
  per-request context while `-c` stays unset. Skip `-nkvo` (unified
  memory; it also gates off flash-attention offload, `:432`) and
  `--swa-full` (full-size SWA cache, `llama-kv-cache-iswa.cpp:73`).
  **A fixed `-c` that dies cleanly at load**: `-c <N> -np 1 -kvu
  -ub 256 --fit off -ngl all`; `llama-fit-params -m <model>` prints
  the projection with no server, `-fitt <MiB>` raises the margin.

**Finding 3. pi never enforces the window on a request, and its tool
results are capped at 50 KB.** From the published tarballs of
`@earendil-works/pi-coding-agent@0.84.4` and `pi-ai@0.84.4`, npm.

- **The trigger is as documented**: `shouldCompact` is
  `contextTokens > contextWindow - settings.reserveTokens`
  (`compaction/compaction.js:160`), where `contextTokens` is
  `usage.totalTokens` of the last assistant message, or a chars/4
  estimate when it has no usage (`:85`, `:131`). It **does** compact
  inside a run, which corrects the old note here:
  `_compactBeforeNextAssistantResponse` (`agent-session.js:273`) is
  installed as `prepareNextTurnWithContext` and runs before every
  assistant response, tool results included (also `:805` and `:895`).
- **Nothing caps the outgoing request.** The one request-side use of
  `contextWindow` shrinks the output cap only:
  `clampMaxTokensToContext` (`pi-ai/dist/api/simple-options.js`) sets
  `max_tokens = min(maxTokens, contextWindow - estimate - 4096)`, down
  to 1. **That is the 1-token `length` stop in every incident above**,
  and the oversized request is still sent in full.
- **`reserveTokens` and `maxTokens` are independent**: `reserveTokens`
  is a settings key in `~/.pi/agent/settings.json`, default **16384**
  (`settings-manager.js:560`, beside `keepRecentTokens` 20000);
  `maxTokens` is a model field in `~/.pi/agent/models.json`, default
  16384 (`provider-composer.js:73`), sent as the API `max_tokens`. On
  `reserveTokens < maxTokens` nothing corrects it; work moves to
  `isRecoverableLength`, one overflow compaction and one retry.
- **Tool results are truncated by hardcoded limits, no config key**:
  `DEFAULT_MAX_LINES = 2000` and `DEFAULT_MAX_BYTES = 50 * 1024`
  (`tools/truncate.js:9`), whichever comes first, in `read`, `bash`,
  `grep`, `find` and `ls`. That is the cap behind the 51339-character,
  17305-token result above. **Trap for step 3**: `mendel-smoke.sh`
  writes its own `settings.json` with no `reserveTokens`, so a smoke
  runs at pi's default 16384, not the owner's 8192. Fix that first.

## What to test on the Mac, in order

Run `tools/preflight.sh` first, and back up `~/.pi/agent/models.json`
and `settings.json` to `~/.config/choose-a-local-llm/` before step 2.
Server commands are the rows' exact commands in
`docs/setups/m1-max-32gb/models.json`, by `id`; steps 0 to 3 share
`~/.cache/choose-a-local-llm/noom/`.

**Step 0 — the growth blobs and the driver.** The synthetic tool is
pi's own `bash` tool reading a file of known size; the file name is a
target, the next turn's prompt jump is the measurement. The runner
keeps one pi session alive across `length` stops; read every turn of
`s1-session.jsonl` by the `count-tool-calls.mjs` rule for prompt
tokens, output tokens, context and `stopReason`.

```
mkdir -p ~/.cache/choose-a-local-llm/noom && cd $_
python3 - <<'EOF'
import random; random.seed(3)
for n in (2000, 4000, 8000, 12000, 16000):
    w = [f"w{random.randrange(10**6):06d}" for _ in range(n)]
    open(f"blob-{n}.txt", "w").write((" ".join(w))[: n * 3])
EOF
node ~/code/mendel-benchmark/benchmark/run-pi-rpc.mjs \
  --model mlx-community/Qwen3.8-27B-4bit --thinking low \
  --prompt ./prompt.txt --out ./s1 --cwd . --max-tooling 4 --wall-min 40
```

**Step 1 — template overhead.** Start row `qwen38-gguf-medium` and
send one pi turn that cats `blob-4000.txt`. **Record** `prompt_n` from
the server timings, pi's prompt tokens for the same turn, and the
difference. **Decision**: that difference is the per-model template
and tool-definition overhead, added to every margin below; above 2000
tokens, check the tool definitions first. mlx_lm.server has no such
counter, so MLX carries the GGUF number.

**Step 2 — in-turn growth on MLX.** Start row `qwen38-mlx-low`
(`mlx_lm.server ... --prompt-cache-size 2 --port 8081`) and leave
`contextWindow` 26624, `maxTokens` 6656 and `reserveTokens` 8192 as
they are. Write a `prompt.txt` that tells it to `cat blob-2000.txt`
once per turn until told to stop. When the context reaches 85 percent
of the window (22630), send one turn that cats `blob-8000.txt`, then
repeat with `blob-16000.txt`; repeat both at 90 percent (23962) and 95
percent (25293). **Record** at each point: context before, the prompt
jump the next turn reports, context after, whether pi compacted,
whether the server log shows `RuntimeError: [METAL] Command buffer
execution failed`, and whether `/health` still returns 200 while the
request hangs. **Decision**: the largest growth the server survives at
each starting context is the margin candidate; a death at 85 percent
with `blob-8000.txt` means the margin is above 8000 and the window
must drop, not the reserve; a compaction before the blob turn is a
pass, so record it and go one level up. Then repeat the step that
killed the server with `--prompt-cache-size 1`, and with
`--prompt-concurrency 1 --prefill-step-size 512` (finding 1): a lever
that moves the death by over 2000 tokens joins this row's command.

**Step 3 — the rule under test.** In `~/.pi/agent/models.json` set
`contextWindow = ceiling_low - maxTokens - margin` and
`reserveTokens = maxTokens + margin`, where `ceiling_low` is the
lowest depth at which the creep saw the server die (26708 here, not
the last good row) and `margin` is step 2's number plus step 1's
overhead. **Fix `mendel-smoke.sh` first** (finding 3), then:

```
SMOKE_MENDEL_BASE=http://127.0.0.1:8081/v1 benchmarks/mendel-smoke.sh \
  mlx-community/Qwen3.8-27B-4bit low   # three times
```

**Record** each `SMOKE-MENDEL` line, each session's peak context, and
the server log after each. **Decision**: three smokes with no Metal
OOM and no hung request is the pass, and the rule goes to
`docs/methodology/mendel.md`. One crash means the margin is too small:
raise it to that crash's growth plus 25 percent and run three more.
Two rounds that both crash means the rule shape is wrong; write that
this model cannot be made safe at this ceiling, not a rule.

**Step 4 — llama load check.** For every llama row in `models.json`,
after load, send one real completion whose prompt is
`contextWindow - maxTokens` tokens, built from the blobs. **Record**
pass or fail and the `-c` per row. **Decision**: a row that fails
becomes a `-c` search like bench 10 A1 and A2, and the check becomes a
line in `tools/preflight.sh` or the Mendel worker, as a bench item. On
one row also compare the `llama-fit-params` projection (finding 2)
with the `-c` the search found; agreement within 10 percent makes
`kv-cache-pick.md` adopting it a bench item.

**Note, 2026-09-06, the reserve in force.** The Mendel worker and the
smoke now pin `reserveTokens` 8192 in their private pi config, the
output budget rule's value; every row before that date ran at pi's
default 16384. That is `maxTokens` with a margin of zero, so step 3's
rule is not yet applied: a turn can grow by the answer plus its tool
results (one bash result up to about 16000 tokens, finding 3), and a
turn that starts just under `contextWindow - 8192` can overshoot the
window. On llama-server the overshoot is a rejected request and a
tooling nudge; on `mlx_lm.server` it is the dead thread. The chance
per turn does not grow with the window, but a longer task has more
compaction cycles, so review the value before a long task on a large
window (Gemma-12B f16 at 262K) and before any MLX row that sits close
to its ceiling. Step 3 replaces the fixed 8192 with
`maxTokens + margin` once step 2 measures the margin.

Output: the rule as a sentence for `docs/methodology/mendel.md` and
`kv-cache-pick.md`, the margin per backend with its evidence, the
preflight or worker change as a bench item. Fix tools and search
online when a result surprises you.
