# Run 10 — state

Created 2026-09-05 by the coordinator. No sessions yet.

Start here: read `AGENT.md`. Log every session below with a
handing-over section at the end.

## Session 1, 2026-09-05

Worktree `../choose-a-local-llm-run10` on branch `run10`, verified with
`git worktree list`. Mendel repo pulled to `d99ff4d` (`a41170a4` in).
GPU was free. LM Studio quit and confirmed gone. Background services
already off from a prior session. `iogpu.wired_limit_mb` already 24000
(no reboot needed to set it).

Deviation: swap in use at start (818.75M used, `Pages wired down`
113513), and this session runs Block A speed sweeps. The checklist's
reboot condition holds, but the owner chose to skip the reboot. Any
speed number from Block A carries this as a recorded deviation; watch
for swap growth during the sweeps as the invalidating signal.

Starting Block A.

### Block A1 — gemma-4-12b-4x, f16

`-c` search (published 1048576 does not load): 524288 loads, 786432
OOMs at load ("model loaded" but `Insufficient Memory` in the log),
655360 loads, 720896 OOMs, 688128 loads clean, 704512 OOMs. Settled at
**-c 688128** (172032/slot), the largest that loads at this bisection
resolution (4096/slot). Verified each loading candidate with one real
chat completion.

Deviation: the trivial warmup completion (22-token prompt) was not
enough to catch a real ceiling. `-c 688128` loaded clean and served a
trivial completion, then OOM'd on compute buffers at the sweep's first
real depth (4114 tokens, `ggml_metal_synchronize` /
`Insufficient Memory`). Re-verified with a realistic 4096-token
completion instead of a trivial one before committing to a value.
`655360` (163840/slot) passed the 4096-token check cleanly (327 tok/s
prefill) and is the config used for the full creep. `688128` and above
are dropped as candidates.

Full creep running on this slot: `creep-gemma12-gguf-4x-f16.tsv`,
depths 4096..163840.

### Coordinator note, mid-session (retracted)

The coordinator sent word about a `preflight.sh` cold-start change,
then retracted it: run 10 continues on its original runbook, no
change to startup or branch. Not acted on either way. The only
remaining coordinator instruction is at run close, about moving the
run folder before the final merge.

### Block A2 — gemma-4-26b-a4b-2x, f16

`-c` search (published `376832` does not load, per AGENT.md; searched
from `425984` = 212992/slot x2): `425984` OOMs at load, `212992` loads
clean but OOMs on compute buffers at a real 4096-token completion (the
A1 false-positive pattern, checked every candidate this way from the
start), `131072` passes, `172032` passes, `192512` passes, `202752`
passes, `208896` OOMs on the 4096-token check. Final: **-c 202752**
(101376/slot).

Starting full creep on this slot.

Creep result: verdict **window** — the sweep's own request at depth
98338 exceeded the allocated `101376`-token slot before speed or
memory stopped it. Reported ceiling: depth 81958 at 33.56 tok/s.
Server killed, wired memory recovered to 90862 pages (below session
baseline). Full numbers in `results.md`.

Starting Block A3 (LM Studio, gemma-4-12b-it-mlx).

Block A3 done: local key is `google/gemma-4-12b`, not
`gemma-4-12b-it-mlx` (same file). Prefill jump 4096->131072 took 1013s
(one queued stall probe failed while the step was still live, then it
answered). Result: depth 131098, wired_mb 17249, but swap grew 443MB
at this row — mem verdict right at the target depth. `wired_mb 17249`
is the number this block asked for. LM Studio quit after. Block A
closed.

Run folder moved to `hardware/m1-max-32gb/benchmarks/bench10/` per
coordinator instruction (commit `de902ba`). `git merge origin/master`
(to bring in the folder-move fix on master and the run-watch.sh
signature fixes) was blocked by the auto-mode classifier; the owner
chose to skip it for now rather than approve or run it manually.
Deviation: run10 does not have the master-side watcher fixes (bare
`[ERROR]` no longer a false death signature, split-signature
detection) for the rest of this session. Watch the run watcher output
more carefully during Block C/D/E scoring runs as a result — a
manual read of the server log is the fallback if a death signature
looks ambiguous.

Starting Block B (Mendel smoke, Qwen3.8 GGUF f16).

Owner pushed `run10` to origin and had the coordinator merge it into
master (merge commit `bce6d98`) rather than wait on the earlier
classifier block; the coordinator also added a checklist rule
forbidding `AskUserQuestion` mid-run. Merged `origin/master` back into
`run10` clean (fast-forward, commit `4d5793f`), picking up that rule
and the run-watch.sh fixes the earlier deviation note flagged as
missing — that deviation is resolved now. From here: push `run10`
after every block commit, and the coordinator merges at each report.

Block B smoke: pass (`SMOKE-MENDEL model=qwen3.8-27b level=medium
calls=8 distinct=8 longest_run=1 loop=ok:1.00 commits=1 clean=yes
end=stop wall_s=62`). Qwen3.8 GGUF continues to Block E. Mendel Daemon
killed after. Block B closed.

Starting Block C (Gemma-26B GGUF f16, EvalPlus thinking on).

Deviation: `benchmarks/calibrate.py` needs the EvalPlus pipx venv's
Python (`~/.local/pipx/venvs/evalplus/bin/python3`), not the system
`python3` — plain `python3` fails with `ModuleNotFoundError: No module
named 'openai'`. `run-humaneval.sh` already resolves this itself via
`evalplus.codegen`'s shebang, so only the standalone calibrate.py call
needed the explicit venv python.

Calibration confirms the same 2-problem non-convergence as the old
run. Scored EvalPlus run launched at `EVALPLUS_MAX_NEW_TOKENS=30000`
per AGENT.md. Run watcher + both sunset scripts started. Full numbers
in `results.md`.

EvalPlus done: pass@1 base 0.884, plus 0.860, empty 18/164, wall
3:47:00. Gate pass, well above 0.800. Watcher comparison: the sunset
`liveness-watch.sh` called SERVER DEAD once on a false positive (a
probe queued behind a live turn); `run-watch.sh` never did, correctly
waiting for a second failed probe. Not a match yet — `sunset/` stays
through the rest of the run. Run watcher and sunset scripts stopped.
Continuing to the Mendel smoke on the same server.

Mendel smoke pass (level high, 11 calls, 1 clean commit, wall 31s).
Starting Mendel blind now (night block, GPU stays busy).

Mendel blind done and scored: 47.5/100 (Fable subagent per PLAN.md),
mendel-benchmark commit `80c4c13`. Watcher trial: this run's two
watchers agreed (no stall/death on either side) — the first block-C
sub-run to match. Worker worktree removed, run branch
`gemma-4-26b-a4b-high-issue-13` pushed, Mendel Daemon killed, run
watcher + sunset scripts stopped. Block C closed.

Starting Block D (Bonsai MLX thinking off: smoke, then guided).
