# Agent guide

This repo answers one question for one computer: which local model, runtime,
and configuration should I code with? It holds the measurements, the process
that produced them, and a website that publishes both.

**You only need to care about two things: the content, and the commands
below.** Everything else — the base path, the sitemap, the deploy workflow,
the Pages settings — is already wired and needs no thought.

## Commands

```bash
npm install                      # once
npm run dev                      # write and preview, http://localhost:5173
npm run verify                   # build + link check. Run before every commit.
npm run deploy -- "what changed" # build, verify, commit. Stops before pushing.
```

`npm run deploy` never pushes. It prints the push command for the owner to
run. Publishing is the owner's step, always.

If another agent is already serving on 5173, add a port:
`npm run dev -- --port 5174`.

## What to read

| Your task | Read this |
|---|---|
| Change any page, wording, or layout | [EDITOR.md](./EDITOR.md) |
| Run a benchmark, or record a result | [docs/methodology.md](./docs/methodology.md) |
| Change the site structure or the deploy | [docs/website-plan.md](./docs/website-plan.md) |

**EDITOR.md** is the one to open for content work. It holds the page shape
every page follows, the vocabulary rules, where each file lives, and how to
record a measurement across every surface.

**docs/methodology.md** is the law for measurements. Rule 7 is the one that
catches people: a result is not recorded until every surface agrees.

**docs/website-plan.md** covers the site build and the deploy. You should not
need it for content work.

## Standing rules

- **Do not push.** The owner pushes, always.
- **Only the agent whose worktree has master checked out may merge into
  master.** Git enforces this: a branch lives in one worktree at a time, so
  from any other worktree the merge is refused. If you are not on master,
  commit on your branch and stop.
- **No superseded number on a current page.** Not in a table, not in prose.
  Old figures move to the setup's `historical.md`, which opens with a red
  warning telling readers not to use them. Only the `benchmarks/*.md` pages
  keep the full archive. See EDITOR.md.
- **Write prose in ASD-STE100 Simplified Technical English.** Short
  sentences, active voice, one idea per sentence.
- **Do not write code comments** unless the owner asks for them.
- **Commit before you ask for review.**
- **Verify before you claim.** Run `npm run verify` and quote the result.
- The working directories `night1/`, `night2/`, `night3/` keep their names,
  but prose calls them **benchmark runs**, numbered. Never "night runs".
- `HANDOFF.md` is the owner's working context and is not committed.

Nothing outside `docs/` reaches the published site.
