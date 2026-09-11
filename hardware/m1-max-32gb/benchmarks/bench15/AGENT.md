# Run 15 — complete the leading row, creep the f16 arm, first look at vision (Mac)

Ready to start, 2026-09-11. About sixteen hours of machine time.

You are the runner, on the Mac. Read this file, then the pages each
block names at its start, and nothing else. Write all prose in
ASD-STE100 Simplified Technical English.

## What this run is for

The comparison page now splits rows by completeness: a row with all
three of tok/s, EvalPlus and simulator(mendel) sits in the top table,
the rest below. The best local agent row, the 4-bit Qwen3.8 at effort
xhigh, lacks its EvalPlus; this run scores it. The Qwen3.6 f16 arm
without its drafter has never been laddered or creeped at wired
25000, and has no agent row; this run measures its window and scores
it. Last, two servers load their vision projector for the first time
on this machine, to learn what a page image costs in memory and in
context tokens. That last block is a measurement, not a gate.

## The order

**This list is the order.**

- `qwen36-f16-ladder-creep`
- `qwen36-f16-mendel-on`
- `vision-ladder`
- `vision-ladder-up`
- `vision-drafter-shallow`
- `vision-benchy`
- `bartowski-evalplus-xhigh` — **holds until the coordinator's word;
  its calibration is done, the budget is the coordinator's call**
- `retry-sweep`

The three vision blocks were added on 2026-09-11 after `vision-ladder`
closed, on the owner's order: they run before EvalPlus. EvalPlus is
the long block, about ten hours or more, and the owner may pause it
between problems and resume it.

## Essentials

- `bench15/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION:** `git worktree add ../choose-a-local-llm-run15 -b
  run15` (or `cd` into it if it exists), then `cd
  ../choose-a-local-llm-run15`. Verify with `pwd` and `git worktree
  list`. Every command of this run happens there.
- **Branches, exactly.** You work on `run15` and only on `run15`. The
  coordinator works on `master`. To take an update: `git fetch origin
  && git merge origin/master`, then push `run15`. Never check out
  `master`, never merge `run15` into `master`, never push `master`.
- Then `docs/methodology/checklist.md`, whole, once per session.
  `tools/preflight.sh` first, every line `ok` before a block starts.
  Never sudo, never reboot on your own.
- **Wired limit: 25000.** Verify with `sysctl -n iogpu.wired_limit_mb`.
  Any other value is stop and ask. Every note carries `wired 25000`.
- One model on the GPU at a time, port 8081. Before you start a
  server, `pgrep -fl llama-server` must be empty. Never kill a server
  you did not start. Quit the LM Studio app first and confirm with
  `pgrep -fl "LM Studio"`; its model cache is the owner's and is never
  touched.
- **No temperature and no sampling parameter is passed to any
  server** on a simulator(mendel) or a creep block. The server's own
  default is the serving sampling. EvalPlus runs at temperature 0,
  that test's own convention.
- **Effort medium is banned for Qwen3.8** (owner rule, 2026-09-09).
  No block names it.
- **No smoke in this run.** Every build below has met the simulator
  on this machine (`docs/methodology/mendel.md`, "The smoke").
- **Pull the sweep tool before this run's first creep**, record its
  short hash in `state.md` and beside every sweep result
  (`checklist.md` step 5b). Not a block, and no second pull inside one
  session.
- **Harness values are per run.** The worker builds its own pinned
  config. The pi alias `qwen3.6-35b-a3b-f16` is in the site data:
  after your first `git merge origin/master`, run `npm run pi:models`
  in the run worktree; it writes the entry and says which thinking
  map to copy by hand from the sibling entry of the same provider.
  Never edit `~/.pi/agent/models.json` in any other way.
- `gh auth status` must pass before the simulator(mendel) block.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says.
- **Scoring and publishing are one task.** One subagent on the best
  available model, per row, on a scratch path of its own that no
  other subagent shares, does all of it: scores per `PLAN.md`, writes
  the `results.json` entry with its matrix cells, regenerates
  `results.csv` and `report.html`, commits to `~/code/mendel-benchmark`
  on branch `benchmark` and pushes. A bug in a run tool goes to a
  subagent on the best model at once; the run does not wait for it.
- Commit on `run15` as results land. Push at every block close and
  message the coordinator session "local-llm
  manager/coordinator/orchestrator" with the block, the config, the
  result line and the commit id. Never run a bare `git stash`.
- Every gate and every stop-and-ask goes to the coordinator session
  with the block, the condition and your candidate answer. Keep the
  GPU busy with the next block that does not depend on it.
- Status lines follow `docs/methodology/status-lines.md`. Archive
  evidence before a session closes:
  `tools/archive-evidence.sh hardware/m1-max-32gb/benchmarks/bench15/results run15`.
- Nothing of an interrupted run is cleaned up mid-run
  (`docs/methodology/mendel.md`, "No cleanup mid-run").

## `qwen36-f16-ladder-creep`

Read `docs/methodology/context-creep.md`. The Qwen3.6 f16 KV arm
without its drafter. Fixed: `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`
rev `5bc3e23`, `--no-mmproj`, f16 KV, no drafter, `--parallel 1`,
wired 25000. Derived: `-c`, by the ladder below.

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b-f16 --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c <c> \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench15/results/server-qwen36-f16-c<c>.log
```

**Estimate before you probe.** With the drafter this arm served
`-c 40960` at 25.1 GB wired and failed at 44032; without the drafter
it read 24.0 GB at `-c 40960`, about 1.1 GB lower. Probe once at
`-c 65536`, then bisect against 40960 in 8192 steps. Each rung is a
real 4096-token completion, never a one-token probe; a `-c` that
loads and fails the first real request is not a rung.

Then the full creep at the largest `-c` that served:

```bash
DEPTH_LIST="4096,8192,16384,24576,32768,40960,49152,57344,65536" \
N_CONTEXTS=1 MODEL=qwen3.6-35b-a3b-f16 \
  python3 ~/code/local-llm-eval-tools/slow-context-creep/creep.py llama \
  | tee hardware/m1-max-32gb/benchmarks/bench15/results/creep-qwen36-f16-nodrafter.tsv
```

Cut the depth list at the served `-c`. Done: the ladder table, then
the creep as a table with one row per step: depth, tok/s, wired MB,
free MB, swap delta. A sweep that ends with no stop condition records
`gatedBy: untested`, and its deepest step is a list end and not a
ceiling. Write `qwen36_f16_c` (the served `-c`) and `qwen36_f16_clean`
(the deepest clean depth) in `state.md`.

## `qwen36-f16-mendel-on`

simulator(mendel) blind at **thinking on**, the level whose q8_0 row
scored 63, the higher of that row's two levels. Fixed: the server of
the block above at `qwen36_f16_c`, prompt blind v1.1, base commit
`2652ed6`. Derived: window = the largest multiple of 8192 at or under
`qwen36_f16_clean` (run 14 used 81920 for a clean depth of 81958 the
same way). The task needs about 46K of context; if the window is
smaller, the harness compacts, and that is the measurement.

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<window> ./run-worker.sh qwen3.6-35b-a3b-f16 pi blind on
```

Branch `qwen3.6-35b-a3b-f16-on-issue-13`; no branch of that name
exists. Row `model` value: `qwen3.6-35b-a3b-f16 (unsloth UD-Q4_K_XL,
no drafter, on)`. The config note carries the files, revision, `f16
KV`, the `-c`, no drafter, the window, the compaction count, `wired
25000`, and the temperature and top_p from the run's `meta.json`.
Verify `peak_context` with the counter before the row commits. A row
that ends on the model's own repetition loop is a valid partial. The
300-minute wall gives a partial, which is a row and not a failure.
Write `qwen36_f16_on` in `state.md`.

## `vision-ladder`

A measurement, no gate and no verdict. Two servers load their vision
projector and answer one request that carries a page image. The
numbers wanted: the largest `-c` that serves such a request, wired
memory at load and after the request, the prompt token count the
image costs, and decode tok/s.

**The page image.** Build it on the Mac from macOS tools only, once,
and record its sha256 in `results.md`:

```bash
mkdir -p hardware/m1-max-32gb/benchmarks/bench15/results/vision
cd hardware/m1-max-32gb/benchmarks/bench15/results/vision
printf 'ACME UTILITIES  -  STATEMENT  -  AUGUST 2026\n\nDescription                 Qty    Unit     Amount\nElectricity supply          412   0.2150    88.58\nDistribution charge           1  31.4000    31.40\nGas supply                  118   0.0930    10.97\nStanding charge, gas         31   0.2800     8.68\nLate payment fee              1   5.0000     5.00\n\nSubtotal                                    144.63\nVAT 5%%                                        7.23\nTOTAL DUE                                   151.86\n' > page.txt
textutil -convert pdf -font Menlo -fontsize 13 page.txt -output page.pdf
qlmanage -t -s 1400 -o . page.pdf
mv page.pdf.png page.png
shasum -a 256 page.png
```

If `qlmanage` writes no PNG, `sips -s format png page.pdf --out
page.png` is the fallback. The image must show the whole table.

**The request.** One text part and one image part, no sampling
parameter, `max_tokens` 400. The text part is this exact prompt, and
the prefix text below the prompt is 4096 tokens of the creep tool's
own filler so the request has the size of real work:

```bash
IMG=$(base64 -i page.png | tr -d '\n')
python3 - "$IMG" <<'EOF' > request.json
import json, sys
img = sys.argv[1]
filler = ("The quick brown fox jumps over the lazy dog. " * 700)
prompt = ("Read the statement page in the image. Return JSON with one "
          "object per line item, fields description and amount, then a "
          "field total. No prose.\n\nContext:\n" + filler)
print(json.dumps({"model": "vision", "max_tokens": 400, "messages": [
  {"role": "user", "content": [
    {"type": "text", "text": prompt},
    {"type": "image_url", "image_url": {"url": "data:image/png;base64," + img}}]}]}))
EOF
curl -s http://127.0.0.1:8081/v1/chat/completions -H 'Content-Type: application/json' \
  --data-binary @request.json | tee reply-<mnemonic>-c<c>.json
```

Read `usage.prompt_tokens` from the reply and, from the server log,
the `prompt eval` count and the decode tok/s of that request. Send
the same request once more with the filler removed, so the image's
own token cost is the difference between the two prompt counts.

**Server A, Qwen3.6 f16 KV, no drafter, projector on.** The model
card says the projector and the MTP drafter do not work together, so
this arm is the only Qwen3.6 vision arm. Start at `qwen36_f16_c` from
the ladder above and step down 8192 until the request serves with
real content:

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias vision --parallel 1 \
  -ngl 999 -fa on -c <c> \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench15/results/server-vision-qwen36-c<c>.log
```

**Server B, Gemma-26B f16 KV, no drafter, projector on.** Start at
`-c 204800`, the largest that loaded with the projector on this
machine, and step down 8192 until the request serves:

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias vision --parallel 1 \
  -ngl 999 -fa on -c <c> \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench15/results/server-vision-gemma26-c<c>.log
```

`--offline` on an uncached projector fails silent: the server starts
without it and answers text only. Confirm in the server log that the
projector loaded (a `mmproj` or `clip` load line) before you read
anything. A projector that is not in the cache is a download, which
is a stop and ask for the owner; never drop `--offline` on your own.
The Gemma-26B projector was fetched on 2026-09-08 and the Qwen3.6
projector restored on 2026-09-10, so both should be cached.

Done, per server: a table with `-c`, loaded yes or no, request served
yes or no, wired MB at load, wired MB after the request, prompt
tokens with and without the filler, image tokens (the difference),
decode tok/s, and the reply saved to its file. The replies are kept
and not judged. Write `vision_qwen36_c` and `vision_gemma26_c` in
`state.md`.

## `vision-ladder-up`

`vision-ladder` served both servers at their first `-c` and never
looked higher, so neither value is a ceiling. This block climbs.
Same two servers as `vision-ladder`, projector on, no drafter, f16
KV, `--parallel 1`, wired 25000, Gemma-26B with `--ubatch-size 2048`.
The rung test is the `vision-ladder` request with the filler (the
page image plus 4096 tokens of text), served with real content.

- **Qwen3.6**: start at `-c 73728` and climb in 8192 steps until a
  `-c` fails to load or fails the request; the served `-c` is the
  largest that passed. Do not climb past 131072.
- **Gemma-26B**: probe `-c 212992` once. Research run 3 saw the
  projector OOM there with the drafter on; this arm has no drafter.
  If it serves, the served `-c` is 212992, the row's own text `-c`,
  and the climb stops there (the model's own window is near). If it
  fails, 204800 stands.

A `-c` that loads and fails the request is not a rung. Record every
rung: `-c`, loaded, served, wired MB at load and after, and the
image token count (it should stay 7005). Write `vision_qwen36_c` and
`vision_gemma26_c` again in `state.md` with the new values.

## `vision-drafter-shallow`

Five cells per model at depth 256, the shape of run 13's shallow
drafter sweep: no drafter, then `--spec-type draft-mtp
--spec-draft-n-max` 1, 2, 3, 4. Each cell is a fresh server at the
`vision_*_c` from the block above, projector on, f16 KV; the request
is the `vision-ladder` request without the filler (page image plus
the prompt), `max_tokens` 256, three requests per cell, the first a
warmup. Read decode tok/s and, on the drafter cells, the `draft
acceptance` line from the server log per counted request.

The Qwen3.6 model card says the projector and the MTP drafter do not
work together. If a Qwen3.6 drafter cell refuses to load or the
request fails, record it as such and stop that model's drafter
cells; its benchy drafter arm is then "none, the server refuses".

Done: one table per model, one row per cell: n-max, tok/s per
counted request, mean, acceptance, wired MB at load. **A table and
no pick.** The coordinator names each model's drafter arm for the
next block; message it with the two tables and wait, the GPU is idle
for minutes only.

## `vision-benchy`

Vanilla `llama-benchy` 0.4.0, the run 14 invocation, on each vision
server: the code corpus over the local `http.server`, `--cache-ram
0` on the server, no sampling parameter, no image in the benchy
prompts (benchy sends text; the projector is loaded and idle). Two
arms per model: no drafter, and the drafter arm the coordinator
named after `vision-drafter-shallow`. Four servers at most, each at
its model's `vision_*_c`, Gemma-26B with `--ubatch-size 2048`.

Depths per model: 4096, half of `vision_*_c` rounded down to a
multiple of 8192, and `vision_*_c` minus 1024 (a benchy request
adds 768 tokens over the depth).

```bash
llama-benchy --base-url http://127.0.0.1:8081/v1 --model vision \
  --tokenizer <tokenizer> \
  --book-url http://127.0.0.1:8089/corpus-mendel-js.txt \
  --pp 512 --tg 256 --depth <depths> \
  --runs 2 \
  --post-run-cmd 'sleep 60; vm_stat | head -12 >> hardware/m1-max-32gb/benchmarks/bench15/results/benchy-<mnemonic>-vm.log; sysctl vm.swapusage >> hardware/m1-max-32gb/benchmarks/bench15/results/benchy-<mnemonic>-vm.log' \
  --format md --save-result hardware/m1-max-32gb/benchmarks/bench15/results/benchy-<mnemonic>.md
```

Tokenizers: Qwen3.6 uses `Qwen/Qwen3.6-35B-A3B`, Gemma-26B uses
`google/gemma-4-26b-a4b-it`, each the base model repo the quant's
card names; both are a tokenizer download of a few MB, approved for
this run. The corpus is
`hardware/m1-max-32gb/research/run4/results/corpus-mendel-js.txt`;
serve its directory with `python3 -m http.server 8089 --bind
127.0.0.1` and stop it after the block. A benchy block costs about
three times a creep: benchy re-prefills the full depth on every
request.

Done, per server: one table in `results.md` with depth, benchy tok/s
and its standard deviation, the text row's tok/s at the nearest
depth where one exists, and acceptance on drafter cells. Swap beside
every cell. **A table and no pick.**

## `bartowski-evalplus-xhigh`

Read `docs/methodology/evalplus.md`, including "Which serving config
to score". EvalPlus serves the fastest config at shallow depth, so
this block serves the 4-bit build with its drafter at a small `-c`,
as the ISTA build was served for its own EvalPlus. Fixed:
`bartowski/Qwen3.8-27B-GGUF:Q4_K_M` rev `f0eec4a`, `--no-mmproj`, f16
KV, drafter `--spec-type draft-mtp --spec-draft-n-max 3`, `--parallel
1`, `-c 32768`, wired 25000.

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 32768 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench15/results/server-bartowski-evalplus.log
```

Calibrate first, at **effort xhigh**, the model's own published
default. The extra-body argument is mandatory on the calibration and
on the full run; check that every calibration row's
`resolved_reasoning_effort` reads `xhigh` before you read the budget.

```bash
CALIBRATION_DIR=hardware/m1-max-32gb/calibrations benchmarks/calibrate.py qwen38-gguf-xhigh qwen3.8-27b '{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}'
```

Budget rule for this level: a calibration that converges on all ten
problems gives its budget as usual. One problem at the 30000-token
cap gives budget 30000, the value the ISTA build ran at this level.
Two or more at the cap is a stop and ask. Then the full set:

```bash
RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench15/results \
  EVALPLUS_MAX_NEW_TOKENS=<budget> \
  benchmarks/run-humaneval.sh bartowski-evalplus-xhigh qwen3.8-27b '{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}'
```

Expect about ten hours: at this level some completions run to the
cap. The `reliability_guard` fix for macOS from run 13 must be in
this run's EvalPlus venv before `evaluate.py`; a 0.000 on every
problem is that fix missing, not a score. Record base, plus, empty
count and wall in `results.md`. Write `bartowski_evalplus_xhigh` in
`state.md`.

## `retry-sweep`

The run's killed or interrupted rows, oldest first, in fresh
worktrees, while the owner is away. A row that ended on the model's
own repetition loop is a valid partial and is not retried.

## Not in this run

- Any repeat of a scored row. Polyglot, parked by the owner.
- Gemma-12B and Bonsai, on any block. Gemma-26B on any block but the
  vision ladder.
- The Qwen3.6 MLX server and the ISTA Qwen3.8 build, on any block.
- Any benchy reading.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
dropped and why, machine state left behind, evidence archived. The
coordinator adds the findings to
`hardware/m1-max-32gb/benchmarks/INDEX.md`, writes `report.md`, writes
the final derived values into `models.json` and the site, and
publishes.
