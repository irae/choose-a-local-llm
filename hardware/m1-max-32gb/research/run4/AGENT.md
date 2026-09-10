# Research run 4 (Mac): validate llama-benchy on the ISTA build

Ready to start, 2026-09-10. One item, about one hour of machine time.

You are the executor, on the Mac. Read this file and `index.md`, then
`../benchy-ab.md` when the item starts. Write all prose in ASD-STE100
Simplified Technical English.

## Essentials

- `state.md` holds what earlier sessions of this run did. Resume where
  its handing-over section says.
- **FIRST ACTION:** `EnterWorktree` with path
  `../choose-a-local-llm-research4`, branch `research4` (or `cd` into
  it if it exists). Verify with `pwd` and `git worktree list`. Every
  command of this run happens there.
- **Branches, exactly.** You work on `research4` and only on
  `research4`. The coordinator works on `master`. To take an update:
  `git fetch origin && git merge origin/master`, then push
  `research4`. Never check out `master`, never merge into it, never
  push it.
- Then `docs/methodology/checklist.md`, whole, once per session.
  `tools/preflight.sh` first, every line `ok` before the item starts.
  Never sudo, never reboot on your own.
- **Wired limit: 25000.** Verify with `sysctl -n iogpu.wired_limit_mb`.
  Any other value is stop and ask. Every note carries `wired 25000`.
- **Research publishes no number.** No site edit, no `models.json`
  edit. The coordinator writes the outcome up.
- **This run may install and download two small things**, approved by
  the owner when the run starts: `llama-benchy` through `pipx`, and
  the tokenizer files it needs from Hugging Face (a few MB). Nothing
  else. A model file that is not on disk is stop and ask.
- **No temperature and no sampling parameter is passed to the server**,
  on any request. The server's own default is the serving sampling.
  Do not pass `--extra-body` to benchy.
- **Another agent may be working on this machine in a second
  worktree.** One model on the GPU at a time, port 8081. Before you
  start a server, `pgrep -fl llama-server` must be empty; if it is not,
  stop and ask the coordinator, do not kill it. Quit the LM Studio app
  first and confirm with `pgrep -fl "LM Studio"`; its model cache is
  the owner's and is never touched.
- Commit on `research4` as results land. Push at the item's close and
  message the coordinator session with the item, the verdict line and
  the commit id. Never run a bare `git stash`.
- Every stop-and-ask goes to the coordinator session with the
  condition and your candidate answer.
- Status lines follow `docs/methodology/status-lines.md`. Archive
  evidence before the session closes:
  `tools/archive-evidence.sh hardware/m1-max-32gb/research/run4/results research4`.

## `benchy-ab`

Read `../benchy-ab.md`, whole. It owns the two arms, the depths, the
benchy command, the pass criteria and the corpus rule.

Fixed: `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, rev
`d562806`, `--no-mmproj`, f16 KV, `--parallel 1`, wired 25000. Derived:
none; the two `-c` values are the ones the creeps on disk served, and
this item compares against those creeps, so it serves the same values.

Serve each arm with the published command shape and its own flags:

```bash
llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp \
  --alias qwen3.8-27b --no-mmproj \
  <arm's drafter flags> --parallel 1 \
  -ngl 999 -fa on -c <arm's -c> \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/research/run4/results/server-benchy-<arm>.log
```

Confirm the server serves with one real completion, then run benchy
as the item says, `none` first, then `n3`. Stop the server between
arms and wait for the wired recovery. For every cell, read the
`draft acceptance` line of the matching request in the server log and
put it beside the cell.

Done: in `results.md`, one table per arm with depth, benchy tok/s and
its standard deviation, the creep's tok/s at the same depth, the
difference in percent, and acceptance; then the verdict line, `pass`
or `fail`, per the item's criteria. In `state.md`, the values below.
Then the handing-over section, push, and the message to the
coordinator.

## Values this run sets

| name | what |
| --- | --- |
| `benchy_version` | the installed version string |
| `benchy_tokenizer` | the `--tokenizer` value that worked |
| `benchy_corpus` | the corpus used, default or the URL swapped in |
| `benchy_invocation` | the exact command line that passed, minus the depths |
| `benchy_pass` | `yes` or `no`, with the failing criterion when `no` |

Benchmark run 14 reads these from this file before its benchy blocks.

## After the run

Update `state.md` with a handing-over section: what ran, the verdict,
machine state left behind, evidence archived. The coordinator writes
the method rule and the site changes.
