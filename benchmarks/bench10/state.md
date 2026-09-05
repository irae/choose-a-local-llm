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

### Coordinator note, mid-session

The coordinator sent word (via a peer session) that the checklist's
cold-start steps changed: `master` has `tools/preflight.sh` at commit
`0778404` or later. Next session: `git merge master` into `run10`
first, then run `preflight.sh` instead of the old manual app-quit /
`mac-services.sh turn-off` / reboot-ask sequence. Act only on its
`fix`/`ask` lines. Swap in use at start is a number to record, not a
reboot reason — only swap growth during a run matters. Keep every
commit inside `benchmarks/bench10/` and the Mendel kit; site pages and
`models.json` stay the coordinator's after the merge. Not acted on
mid-block; applies from the next cold-start.
