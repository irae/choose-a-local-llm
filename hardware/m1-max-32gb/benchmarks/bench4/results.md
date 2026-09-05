# Night 4 EvalPlus results

One row per block: budget used, pass@1 base/plus, empty count, incidents.
Carried over from `benchmarks/bench3/results.md` — see that file for every block
completed before night 4 started.

| block | model | budget | pass@1 base | pass@1 plus | empty | incidents |
|---|---|---|---|---|---|---|
| 1 | bonsai-prism (prism fork, q4_0 KV + calibration bias) | 10240 | 0.927 | 0.890 | 4/164 | none; resumed cleanly from 72/164 |

## Block 2: gemma-12b LM Studio ceiling confirmation sweep (not EvalPlus, no table row here)

Depth sweep, `--parallel 4`, watcher at 20 s interval, `DEPTH_LIST`
41000/49000/57000/65000/74000 (comma-separated). Clean through 65,094
tokens (29.29 tok/s); compression/swap onset inside the 74,099-token
step. Ceiling = onset between 65K and 74K. Full table in
`docs/setups/m1-max-32gb/reports/gemma-4-12b-it.md`. Site tables
(`comparison.md`, `docs/index.md`) updated via `models.json` +
`node tools/gen-tables.mjs`.

## Not yet run

Gemma-12B thinking-on EvalPlus, Qwen3.8-27B thinking-low, bonsai-off,
Aider polyglot (see `benchmarks/bench4/AGENT.md`).
