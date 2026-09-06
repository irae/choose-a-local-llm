# The shared-worktree staging rule for the Mendel kit

Status: pending owner decision. Filed 2026-09-05.
Needs hardware: no.

"Never `git add -A` in `../mendel-benchmark`" is practiced and is in
every agent prompt that touches the kit, because the `benchmark`
branch is a worktree of `../mendel` and a blanket add stages files
that belong to other branches. No rule file holds it. One line in
`AGENTS.md` standing rules makes it formal, if the owner wants it.
