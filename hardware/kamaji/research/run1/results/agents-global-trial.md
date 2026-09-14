# Trial draft — tool-call rules for agents-global (coordinator, 2026-09-03)

Status: PROPOSAL ONLY. `agents-global.md` stays at v1.0. Changing that
file mid-bench invalidates comparability with every scored row, so the
draft below is trial material: the Mac agent tests it OUTSIDE the
scored benchmark, and the results tell the owner whether v1.1 ships
(most likely with a fresh bench, not inside runs 7/8 data).

## Motivation (scored failures this section targets)

- Bonsai-PrismML: ~100 identical failing `ls` calls on a typo'd path
  until the wall clock died.
- Gemma-12B: newline flood right after the first failed edit, 3/3
  runs.
- Bonsai mlx: the `qwen3_coder` parser crash on a multi-line edit
  argument with embedded quotes.
- pi documents itself offline (`pi --help`, the `docs/` directory next
  to the pi binary — verified present, includes tool-calling notes)
  and supports `--skill`; the models never use any of it.

## Draft section (verbatim, for the trial)

> ## Tool calls
>
> When a tool call fails, do not repeat the same call unchanged. Read
> the error, then change something: smaller arguments, a different
> tool, or a different approach. After two failures of the same call,
> stop and rethink the step. Verify a path exists before you loop on
> it.
>
> Prefer several small edits over one large edit. Do not put long
> multi-line text with embedded quotes into tool-call arguments; write
> a file instead of editing when the change is large.
>
> Your harness (pi) documents itself offline: `pi --help`, and the
> docs directory next to the pi binary. Consult them when a tool
> behaves in a way you do not expect.

## Trial design alternatives (Mac agent + owner filter these)

1. Unscored A/B: run a failure-prone model (Bonsai-prism, or Gemma if
   run 2 unblocks it) on the bench task with and without the section
   (for example via pi `--append-system-prompt` or a `--skill`), in a
   scratch worktree, never recorded as a bench row. Compare loop
   counts and parser crashes in the session logs.
2. Same content as a pi skill instead of AGENTS.md text — measures
   whether skills reach small local models better than global context.
3. A cheaper probe first: replay the exact failing situations (the
   typo'd path, the giant edit) as short prompts against the local
   models, with and without the rules, before spending full runs.

If the trial wins, shipping = agents-global v1.1 + run-worker
`pinned_env` bump + a results note; old rows stay v1.0 and the report
notes the env split. That decision is the owner's.
