# Agent guide

This repo answers one question for one computer: which local model, runtime,
and configuration should I code with? It holds the measurements, the process
that produced them, and a static site that publishes both.

Read the file that matches your task before you change anything.

| Your task | Read this |
|---|---|
| Change any page, wording, or layout | [EDITOR.md](./EDITOR.md) |
| Run a benchmark, or record a result | [docs/methodology.md](./docs/methodology.md) |
| Change the site structure or deploy it | [docs/website-plan.md](./docs/website-plan.md) |

## EDITOR.md — content and the site

The owner's editorial choices, and how to update the site. It covers the
page shape every page must follow, the vocabulary rules, the build and
preview commands, where each file lives, and the checks to run before you
commit. Start here for any content work.

## docs/methodology.md — the measurement law

The flow for every test cycle: measurement rules, runtime policy, the
quality gate, the KV cache policy, and the server failures that will recur.
Rule 7 is the one that catches people — a result is not recorded until every
surface agrees.

## docs/website-plan.md — the site itself

Why the site is built with VitePress, the target layout, and the phases.
Phases 1 and 2 are done. Phase 3 is the GitHub Pages deploy, which is not
set up and needs the owner's explicit go.

## Standing rules

- **Do not push, deploy, or enable GitHub Pages** without the owner saying
  so. Local work is committable; publishing is not.
- **No superseded number on a current page.** Not in a table, not in prose.
  Old figures move to the setup's `historical.html`, which opens with a red
  warning telling readers not to use them. Only the `benchmarks/*.md` pages
  keep the full archive. See EDITOR.md.
- **Write prose in ASD-STE100 Simplified Technical English.** Short
  sentences, active voice, one idea per sentence.
- **Do not write code comments** unless the owner asks for them.
- **Commit before you ask for review.**
- **Verify before you claim.** `npm run docs:build` then
  `npm run docs:check`. Quote the result.
- The working directories `night1/`, `night2/`, `night3/` keep their names,
  but prose calls them **benchmark runs**, numbered. Never "night runs".
- `HANDOFF.md` is the owner's working context and is not committed.

## Quick start

```bash
npm install
npm run docs:dev     # http://localhost:5173
```

Nothing outside `docs/` reaches the published site.
