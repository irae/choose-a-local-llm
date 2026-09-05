# Conventions for markdown and tooling

Read this before you write a page, a runbook, a backlog item, or a
script. It is the index of the writing rules. The detail stays in the
file that owns it. All prose is ASD-STE100 Simplified Technical
English: short sentences, active voice, one idea per sentence.

## Markdown

Which file governs which kind of page:

| Kind | Where | Rules live in |
| --- | --- | --- |
| Site pages (`docs/`) | reports, comparison, benchmarks data, methodology | `EDITOR.md`: page shape, vocabulary, generated blocks, no superseded number on a current page, record everywhere |
| Method pages (`docs/methodology/`) | how to measure | `EDITOR.md`, plus one rule: never name a model, vendor fork or Hub repo. Say "one dense 12B model on the reference setup" and link the setup page. The models of one machine live under `docs/setups/<setup>/`. |
| Run kits (`benchmarks/bench<N>/`) | `AGENT.md`, `state.md`, `results.md`, `results/` | `benchmarks/PLANNING.md`: exact commands, executable conditions, failure paths, no approval gates; `AGENTS.md` standing rules for the kit shape |
| Research kits (`research/run<N>/`) | same shape, goals not blocks | `benchmarks/PLANNING.md`; a research run brings findings and options, not decisions |
| Backlog (`backlog/<mnemonic>.md`) | one item per file | opens with status, filing date, origin, and whether it needs hardware; restates the situation so nobody digs old runs; lists entry points and evidence files; is not a prompt. `backlog/index.md` lists every item in priority order with a checkbox the owner marks (legend in that file). When the work lands on `master`, the file is deleted in the same commit and its line moves to the index's Changelog |
| `HANDOFF.md` | coordinator state, gitignored | `benchmarks/PLANNING.md`: small, pointers only, desired next state |

Rules that apply to every markdown file:

- Sharp conclusions first, evidence after (`EDITOR.md`, "Sharp
  conclusions, not stories").
- Numbers carry their conditions: wired limit, KV type, rate, build.
  A number without them is not comparable and does not get published.
- Later text wins. A correction is a dated section that says what it
  supersedes. The old text stays, marked.
- Terminology follows the community: repetition loop, degeneration,
  tool-call loop. Never "collapse" for repetition
  (`research/run2/results/terminology.md`).
- No planning mechanics in commit messages or docs (no "step 3 of
  phase 2"). Say what was done.

## Tooling

Shared scripts live in two places and nowhere else: `benchmarks/`
(tools every benchmark run uses) and `tools/` (site build, sweeps,
machine helpers). A run folder never holds a tool. Improve the shared
one in place (`AGENTS.md`, "Improve shared tools in place"). When you
add or move a tool, index it in `AGENTS.md` in the same commit.

Shape of a measurement tool. `tools/sweeps/creep.py` with its
per-backend files is the reference:

- **One module owns the method; thin adapters own the backend.** The
  method module carries what the methodology page defines: depth
  ladder, pause, append-only growth, stop conditions, output format.
  An adapter carries only what differs per backend: endpoint, request
  shape, how speed is read, liveness signal.
- **Defaults encode the method.** A pause the method says is 25 s
  defaults to 25 s and warns when set lower. A script whose name
  promises a behaviour its defaults do not implement is a bug we have
  had (`docs/methodology/context-creep.md`, "Do not try these").
- **Configuration through environment variables.** Document them in
  the header with their defaults. No hardcoded machine paths; a path
  from a dead session broke two scripts. Machine state reads from the
  three directories `AGENTS.md` names, never from the repo.
- **The evidence rides in the output.** One record per step, one
  format (tab-separated to stdout). The columns carry what a verdict
  needs: depth, tokens per second, and the memory counters (wired
  first; free and swap delta beside it), so a suspect step is visible
  in the data without a second log.
- **Watch the real signal.** A server can answer `/health` after its
  generation thread died. Liveness comes from the server log or from
  one real completion, never from a health route. A detected death
  exits non-zero (the sweep tools use 42) so a monitor can act.
- **Print events, one per line**, including what was skipped. Silence
  hides a wrong label.
- **Standard library only.** A tool that needs a package the machine
  does not have is rewritten, not installed (`gguf-meta.py` exists for
  that reason).
- **Header, not comments.** The file opens with a docstring or header
  comment that says why the tool exists, what it changes on the
  machine (and how to reverse it), usage, and the environment
  variables. Inside the code, no comments unless the owner asks; the
  one exception is a hidden cross-file behaviour or an external gotcha.
- **A script that changes the owner's Mac is read before it is run.**
  Data first, one function per action, one command per line, a state
  file for the reverse direction. `tools/mac-services.sh` is the
  reference; the full rule is in `AGENTS.md`.
- **No unit tests unless the owner asks.** Validate a tool against a
  known result instead, and say so in its header (`count-events.py`
  reproduces run 1's published numbers, for example).
- **Name the file for what it does**, in the folder's existing style:
  `creep_<backend>.py`, `<thing>-watch.sh`, `<verb>-<object>.mjs`.

Before a commit: `npm run verify` for anything under `docs/` or
`tools/gen-tables.mjs`. For anything under `benchmarks/` or
`tools/sweeps/`, run the tool once against a live target and quote the
output.
