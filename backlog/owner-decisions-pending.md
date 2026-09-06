# Owner decisions pending, 2026-09-05

One line per decision, the file or branch that holds the detail, and
what changes on each answer. The coordinator does nothing on these
until the owner answers; each answer becomes an edit or a rule.

## Reviews

- **Status-lines proposal.** Branch `status-lines`, worktree
  `../choose-a-local-llm-statuslines`, commit 5a1afc4:
  `docs/methodology/status-lines.md`, one template per update type in
  three sizes, the delta rule, the model short-id rule, the context
  budget rules. Two points to settle: the page names models against
  the rule that method pages never do (exempt the page, or move the
  short-id table to the setup page), and the branch predates the folder
  move (rebase after review).

## Rules

- **Pushing a run branch.** The rule in `AGENTS.md` and the checklist
  says never. Run 10 pushes `run10` after every block and the
  coordinator merges at each report, on the owner's instruction. Keep
  the new practice and rewrite the rule, or return to one merge at run
  close.
- **The shared-score rule's quant exception.** `docs/methodology.md`,
  "Score the quant, once per model": Gemma-4-12B's GGUF Q4_K_XL scored
  0.067 above its LM Studio MLX 4-bit (run 9), so two quants of one
  model can carry their own scores. The comparison page footnote says
  so; the method page needs the owner's wording.

## Configuration

- **Qwen3.6 GGUF entry at `contextWindow` 49152.** Set 2026-09-05 after
  run 9 found the published `-c 98304` fails at load under the 24000
  limit. The Mendel rows of late August ran at 98304 and peaked at 94K.
  Why 98304 loaded then and not now is a question in
  `hardware/m1-max-32gb/research/run3/AGENT.md`, Goal 3. Keep 49152 on
  the daily driver until that answer, or raise it back and accept a
  load failure risk.
- **Qwen3.8 MLX window.** Guided low is invalid after three attempts
  in run 9: the context grows past 26624 in agentic use and Metal OOMs.
  A smaller `contextWindow` or an earlier compaction, before any retry.
  Research 3 Goal 3 may answer it with a measured margin; the blind low
  row waits on the same decision.
- **Bonsai KV bias corpus.** Which corpus produced the scored KV bias
  file of the PrismML fork row. Blocks the fork's blind thinking-high
  retry and the q8_0 KV arm without the bias file.

## Older, still open (from 2026-09-04)

- **Devstral Small 2 download**, about 14 GB at Q4, the first
  coding-model candidate of research 3's container trials.
- **Budget for cloud re-runs and the polyglot tier.** Which Anthropic
  models get a Mendel re-run, and which models go to Aider polyglot.
- **The shared-worktree staging rule.** "Never `git add -A` in
  `../mendel-benchmark`" is practiced and in every agent prompt, but no
  rule file holds it. One line in `AGENTS.md` if the owner wants it
  formal.
