# Run 33: Arete and S5-nano on arrietty

## Wakeup

Schedule a wakeup every 1200 seconds from the first action until the
run ends. Use T3 `schedule_task` with an interval of 1200000 ms,
bound to this runner thread. Check real output growth at each wakeup.
Send the short status line from `docs/methodology/status-lines.md`
in this thread. Disable the scheduled task at close.

## Essentials

The owner requested this run on 2026-11-08. Test only these new
models. Give early feedback on both before the long quality and
simulator(mendel) tests. Keep one model loaded for adjacent short
tests. Do not take work from an older run.

T3 creates this thread with an isolated worktree on `run33`, based on
the coordinator's local `master`. Before any machine action, verify
`pwd`, `git branch --show-current` and `git worktree list`. Never run
in the main worktree. Record the actual worktree path in `state.md`.
The app creates the checkout; do not create another checkout in bash.

Read `CONVENTIONS.md`, this run's `state.md`,
`docs/methodology/checklist.md` and `docs/methodology/status-lines.md`.
Write short, active sentences. Do not read `HANDOFF.md` or
`benchmarks/PLANNING.md`.

Commit only this run's folder on `run33`. Run `npm run verify` before
each commit. Push `run33` after each block commit. Report only at a
block push, a gate or a stop condition. Send the coordinator the block,
result, commit and branch through T3 `t3_thread_send`, thread
`32cfbd7e-56fd-4ce3-981b-42b6d914e035`. Never merge or push `master`.
Never edit shared files, the owner's pi config or installed packages.
The coordinator imports results and handles shared changes and scoring.

A blocked block is recorded and skipped. Start the next independent
block in the same turn. Retry recoverable machine failures inside the
block. A model loop is a result; do not alter prompts to rescue it.
Money, sudo, reboot and a runtime outside the allowed publishers go to
the coordinator. Keep worktrees and sessions on a credit interruption.
Do not remove a model file. Ask the coordinator for disk space.
No run artifact goes under `/tmp`.

## The order

- `machine-setup`
- `s5-kv-feedback`
- `arete-kv-feedback`
- `arete-depth`
- `arete-tool-smoke`
- `s5-depth`
- `s5-tool-smoke`
- `s5-quality-think`
- `s5-guided`
- `s5-blind`
- `s5-quality-instruct`
- `arete-quality-xhigh`
- `arete-guided`
- `arete-blind`
- `arete-quality-off`
- `retry-sweep`

The short KV comparisons include the fixed EvalPlus smoke for both
cache types. They are the first feedback on coding answers. Finish
both before a full quality run. The depth and tool-smoke blocks retain
Arete after its KV block, then retain S5 for its long tests. All speed
work runs before any full simulator(mendel) row.

## Fixed identities

| field | Arete | S5-nano |
|---|---|---|
| repository | `bartowski/NousResearch_Arete-27B-GGUF` | `maritaca-ai/S5-nano-GGUF` |
| revision | `9762c8502a79bd2b8634735d75f426b9febe092c` | `5fd041274829d60aeeba1e2edc4aabb621a432e4` |
| file | `NousResearch_Arete-27B-Q3_K_M.gguf` | `S5-nano-Q8_0.gguf` |
| bytes | 13165067264 | 4610580032 |
| tokenizer | `NousResearch/Arete-27B` | `maritaca-ai/S5-nano` |
| tokenizer revision | `108f0afbdcfaa1ceeda4a635004304dfff6d4da2` | `ae981dc208f3bba2939c4cf242fab3e9a83e4938` |
| final pi id | `arete-27b-q3km` | `s5-nano-q8` |
| thinking level | `xhigh` | `high`, binary Think mode |
| request extra body | `{"chat_template_kwargs":{"enable_thinking":true,"reasoning_effort":"xhigh"}}` | `{"chat_template_kwargs":{"enable_thinking":true}}` |
| depth cap | 65536 | 262144 |

Arete uses the quant publisher's xhigh prompt. Never use medium.
Its checkpoint allows 262144 positions, but the publisher reports 64K
training. This run stops at 65536 and does not claim tested extension.
S5's published default is Think. Q8_0 keeps its weights near full
precision while leaving room for context on this card.

Sources, checked 2026-11-08:

- https://huggingface.co/bartowski/NousResearch_Arete-27B-GGUF
- https://huggingface.co/NousResearch/Arete-27B
- https://huggingface.co/maritaca-ai/S5-nano
- https://huggingface.co/maritaca-ai/S5-nano-GGUF

Runtime is the official `ggml-org/llama.cpp` stable v0.9.0, commit
`cd959bae99ff4bed22bef2604f45241c09bbb8c8`, build b12110.
The stable release's `nightly-tag.txt` names b12110. Use the mise
installation with the official Ubuntu x64 CUDA 12.8 assets. No
compilation and no third-party runtime. A load failure goes to the
coordinator with the exact error while the other model runs.

Both models use one slot, full GPU offload, no vision and no drafter.
An MTP experiment is outside this baseline run. Record whether the S5
file contains the head, but do not enable it or download a drafter.

## `machine-setup`

Read `docs/methodology/server-lore.md` and
`docs/methodology/common-rules.md` before touching the server.
Run `bash tools/preflight.sh` first and save its output. On this Linux
machine, macOS-only failures are recorded as inapplicable. Check GPU
use, free disk, `MemAvailable`, swap and `gh auth status` directly.
Record the starting GPU memory as `vram_start_mb`; there is no wired
limit or fixed VRAM reserve. Do not quit the desktop.

Use `mise which llama-server`, then that absolute binary's `--version`
and `--list-devices`. Require build b12110 and CUDA0. Require the
reasoning-budget, Jinja and router flags in its help. Record pi and
llama-benchy versions. Apply the checklist's pi update if required.

Fetch each named model with `hf download REPO FILE --revision REV`.
Use the default HF cache. Record sha256, revision and byte count.
Fetch tokenizer metadata only, not the source safetensors. Pin its
revision and pass its local snapshot path to llama-benchy.

Stop the idle official router through `bash tools/llama-router.sh stop`.
Stop Prism only if it is running and idle. A busy server is a gate to
the coordinator, not permission to kill another task.

Set these variables in each new shell:

```bash
export KIT=hardware/arrietty/benchmarks/bench33
export BUDGET_MSG="Thinking budget reached. Give the final answer now."
export BIN="$(mise which llama-server)"
export EVALPLUS_PYTHON="$(head -1 "$(command -v evalplus.codegen)" | sed 's/^#!//; s/ -E$//')"
```

The corpus is `hardware/kamaji/research/run4/results/corpus-mendel-js.txt`,
sha256 `f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`.
Serve that directory with `python3 -m http.server 8089 --bind 127.0.0.1`.
Keep its PID and stop it at close.

## Serving and ports

Use the existing router interface with a run-owned preset file,
`$KIT/results/router.ini`. This file contains only the active config.
It is evidence and may be committed in this run folder. Each section
is named by the alias used in the request. Its keys are:

```ini
[ALIAS]
model = ABSOLUTE_PINNED_GGUF_PATH
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = DERIVED_C
cache-type-k = DERIVED_KV
cache-type-v = DERIVED_KV
jinja = true
cache-ram = 0
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

Replace the uppercase fields from the identity table and `state.md`.
For Arete add `chat-template-kwargs` with its request JSON's inner
object. For S5 add `chat-template-kwargs = {"enable_thinking":true}`.
The Instruct/off blocks set `enable_thinking` false and remove the
reasoning-budget keys. Keep all other flags fixed. Record every preset.

Start one router with the existing helper's `serve` action:

```bash
ROUTER_BIN="$BIN" ROUTER_PRESET="$PWD/$KIT/results/router.ini" \
  ROUTER_PORT=8080 ROUTER_HOST=127.0.0.1 \
  bash tools/llama-router.sh serve > "$KIT/results/server-ACTIVE.log" 2>&1
```

Run it as a background process with its PID recorded. Use a distinct
log name per configuration. Forward the EvalPlus port with
`socat TCP-LISTEN:8081,bind=127.0.0.1,reuseaddr,fork TCP:127.0.0.1:8080`
as a second background process. It holds no model. All clients then
reach the same router; changing clients does not reload a model.
Stop only these recorded PIDs at a configuration change or close.
Restart the router when its preset changes. Wait for GPU memory to
return to the measured starting level before the next load.

Warm up with a real completion and verify the log says all layers
offloaded. Check the actual alias and reasoning field with a chat
request. No CPU fallback, automatic fit, context shrinking or extra
sampling changes are permitted. Record the server's resolved settings.

## Short speed readings

Read `docs/methodology/kv-cache-pick.md` and
`docs/methodology/context-creep.md`. The checked-in external creep
tool still requires `vm_stat`, so use the existing Linux benchy
method, as run 17 did. Record that method with the data. Never label
benchy output as a slow-context-creep measurement.

For each depth D, run a separate call so a failed deep cell does not
lose the earlier cells:

```bash
llama-benchy --base-url http://127.0.0.1:8081/v1 --model ALIAS \
  --tokenizer PINNED_TOKENIZER_DIRECTORY \
  --book-url http://127.0.0.1:8089/corpus-mendel-js.txt \
  --pp 512 --tg 256 --depth D --runs 2 \
  --post-run-cmd 'sleep 5' --format md \
  --save-result "$KIT/results/BLOCK-KV-D.md"
```

Sample `nvidia-smi` memory, temperature and power, `free -m`, and swap
before and after each cell into the matching `*-memory.log`. Save the
server timings and errors. Watch output growth and CUDA death signals
while the call runs. This speed block has no second run watcher.

## `s5-kv-feedback` and `arete-kv-feedback`

The fixed parameters are the identity table, runtime and no drafter.
The cache type and later serving context are derived from this block.

Research model-specific KV evidence. No direct cache-quality result
for either fine-tune was found in planning. Do not turn evidence on
the parent model into proof for this fine-tune.

For each cache type, start at `-c 34816`. Read depths 4096, 8192,
16384, 24576 and 32768 with the short speed command. Run the fixed
four-problem EvalPlus smoke immediately while that cache stays loaded:

```bash
SMOKE_BASE=http://127.0.0.1:8081 \
  SMOKE_OUT="$PWD/$KIT/results/BLOCK-KV-smoke" \
  "$EVALPLUS_PYTHON" benchmarks/evalplus-smoke.py BLOCK-KV ALIAS 'EXTRA_BODY'
```

Use the thinking extra body from the identity table. Use the full
watcher described below for each smoke. A type that cannot load 34816
with full offload is infeasible at the method's 32K minimum. Record
the error. Do not lower the quant or move layers to host RAM.

Report the speed table, VRAM, the two SMOKE lines and the feasible
types to the coordinator. The coordinator applies the KV method's
fit, speed and quality rules. When the 32K speeds are within 10% and
both types fit, the candidate is q8_0. A worse smoke moves the pick
to the other type. A missing comparator is explicitly unconfirmed,
not a LEVEL result. The full quality gate still runs on a feasible
candidate. If both types fail 32K, skip that model's dependent blocks.

At block close the coordinator records the selected type as MODEL_kv
and prepares that model's pending site row and pi entry on `master`.
The runner can continue the other model's KV or depth work while that
shared change is prepared. No runner chooses a serving recommendation.

## `arete-depth` and `s5-depth`

Use MODEL_kv from the coordinator's recorded KV decision. If it has
not arrived, work on the other model's independent block and report
the gate. Do not idle with independent work queued.

Find the largest serving `-c`, up to the identity table's depth cap.
Start at that cap. Halve on allocation failure. Bisect the pass/fail
interval in multiples of 8192. A pass requires all GPU layers and a
real benchy request at `-c` minus 1024. Step down by 8192 and retry
after a deep OOM. Save every load and error. This is a measured
allocation ceiling, not a planning estimate.

Read 4096, 24576, 32768, then 65536, 131072, 196608 and 245760 where
below `-c`, plus `-c` minus 1024. Stop extending after a cell falls
under 8 tok/s or swap grows. Record the deepest clean cell at or above
8 tok/s as MODEL_clean. Set MODEL_window to that depth rounded down
to 4096, no larger than MODEL_c. A window under about 46K is a known
partial task condition, not an automatic rejection.

If both KV types remain candidates because of a crossed curve or fit
uncertainty, run this block for both before the coordinator decides.
Record MODEL_c, MODEL_clean, MODEL_window, memory and curve in
`state.md` and `results.md`. Report and retain the selected model
for its adjacent tool smoke when possible.

## Watcher for every quality or simulator(mendel) call

Read `docs/methodology/checklist.md` at the start of a resumed session.
Start one watcher immediately after warmup. Set RUNWATCH_SERVER_LOG
to the active router log, RUNWATCH_OUTPUT to the growing samples or
session file, RUNWATCH_MODEL to the active alias,
RUNWATCH_BASE_URL to `http://127.0.0.1:8080`, RUNWATCH_SILENCE to 2700,
and RUNWATCH_MEM_LOG to a distinct file in this run's results.
Set RUNWATCH_SIGNATURES to
`CUDA error|out of memory|cudaMalloc|Segmentation fault|Aborted|Traceback`.
Run `bash benchmarks/run-watch.sh` as a background task. Exit 42
requires log inspection, server restart and block resume. A queued
probe alone is not proof that a busy one-slot server died. Stop the
watcher after the call. Record UTC start and end for every active part.

## `arete-tool-smoke` and `s5-tool-smoke`

Read `docs/methodology/mendel.md`. Use the measured MODEL_c and
MODEL_window. The coordinator must first supply the new row and
thinking map on `master`. On its instruction only, take that change
with `git fetch origin` and `git merge origin/master` on `run33`.
Record the source commit. Do not improvise a copy of the owner's config.

Verify `gh auth status`. Run with the identity table's pi id and level:

```bash
SMOKE_MENDEL_OUT="$PWD/$KIT/results/MODEL-tool-smoke" \
  SMOKE_MENDEL_SITE_ID=PI_ID \
  SMOKE_MENDEL_CONTEXT_WINDOW=MODEL_window \
  bash benchmarks/mendel-smoke.sh PI_ID LEVEL
```

Use the watcher. Record the full SMOKE-MENDEL line. Fail skips that
model's full simulator(mendel) blocks. It does not skip its EvalPlus
run. A missing auth or entry skips this block until the coordinator
resolves it; other independent blocks run meanwhile.

## Quality blocks

Read `docs/methodology/evalplus.md` for every quality block.
Use the selected cache, no drafter, the same model's measured serving
context, thinking budget 8192 and output budget 16384. No calibration
and no optional proof rerun. Keep the adjacent model loaded.

`s5-quality-think` uses Think. `arete-quality-xhigh` uses xhigh.
The Instruct/off blocks pass
`{"chat_template_kwargs":{"enable_thinking":false}}` explicitly,
remove the server thinking budget, and retain output budget 16384.

```bash
RESULTS_BASE="$KIT/results" EVALPLUS_MAX_NEW_TOKENS=16384 \
  bash benchmarks/run-humaneval.sh BLOCK PI_ID 'EXTRA_BODY'
```

Keep the watcher active and use existing samples to resume after a
server failure. Keep `finish.jsonl`, raw and sanitized samples and
the evaluator output. Run
`python3 benchmarks/thinking-budget.py count "$KIT/results/BLOCK" --message "$BUDGET_MSG"`
on the completed directory.
Report base/plus, actual empty and forced counts, completion, and
active wall minutes. Never report a partial score.

Base pass@1 at least 0.800, a clean speed cell at least 8 tok/s and
a passed tool smoke permit the thinking-on simulator(mendel) blocks.
Otherwise record the exact failed gate and skip those blocks. The
off score does not qualify a thinking-on agent row.

## `s5-guided`, `s5-blind`, `arete-guided` and `arete-blind`

Read `docs/methodology/mendel.md`, then
`~/code/mendel-benchmark/benchmark/PLAN.md` and its worker instructions.
Use the existing benchmark kit checkout, not `../mendel` on master.
The worker makes fresh per-model task worktrees. Record the benchmark
commit, frozen prompt version and resolved base tag before each row.
Use guided v3.0 or blind v1.1 as named by the block. Both are new
rows for these models. Never compare their scores across test types.

Gate on the thinking quality, tool smoke and speed results above.
Verify `gh auth status` immediately before each row. Serve the newest
MODEL_c. Use MODEL_window from this run's newest matching depth
measurement. Let the generator set keepRecentTokens by the method's
window curve. No maxTokens or reserveTokens overrides.

From `~/code/mendel-benchmark/benchmark`, run:

```bash
CHOOSE_REPO=ABSOLUTE_RUN33_WORKTREE \
  MENDEL_SITE_ID=PI_ID MENDEL_CONTEXT_WINDOW=MODEL_window \
  ./run-worker.sh PI_ID pi TEST LEVEL
```

TEST is `guided` or `blind`. LEVEL is xhigh for Arete, high for S5.
Use the watcher and save stdout, stderr, meta and all session events
under this run's results. Retain the pinned pi config. No prompt or
sampler rescue for a repetition loop. Stop only the run's Mendel
Daemon after a row. Verify tool calls and peak_context with
`benchmark/count-tool-calls.mjs` before reporting the row.

The runner does not score. Send the completed row to the coordinator
at block push. Scoring uses a separate best-tier agent under the
benchmark's scoring instructions. GPU work proceeds while it is scored.
The coordinator handles result imports in the benchmark repository
and on the site. Do not commit shared scoreboards on `run33`.

## `retry-sweep` and close

Retry only this run's blocks that needed an external action. Never
take a parked model or older plan item. If all remaining work is truly
blocked, record the condition and hand back to the coordinator.

Archive evidence with
`tools/archive-evidence.sh hardware/arrietty/benchmarks/bench33/results run33`.
Stop the recorded server, forwarder, corpus and watcher processes.
Disable the wakeup. Keep all worktrees, branches, pinned configs and
session files until the coordinator merges and closes the run.
Write the final handing-over section, verify, commit and push `run33`.
The coordinator restores the official router, scores and imports the
rows, writes the report and INDEX entry, and completes stop-and-sync.
