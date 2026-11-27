# Site v2 — Working Directory

Temporary research, critique, architecture diagrams, feedback logs, and handoff documents for the `site-v2` redesign. This directory is excluded from production publishing and may be rebased out once the rewrite lands.

## End goals

1. **Readable, concise, useful website** — highlight real findings and winning configs up front, keep all raw evidence linked one click deeper, and make the scale of real benchmark compute unmistakable from any page (e.g., total benchmark hours live in the sidebar).
2. **Clean `docs/agents/` separation** — move every rule, workflow, and procedure that agents read into `docs/agents/`, separate from both the published website and human repository docs.
3. **Clone-and-run reusability** — anyone can clone this repository, clear our hardware setups, follow the guide, and generate an identically structured site for their own machines.
4. *(Optional, proposed in Step 2)* **Split repo docs from the published site** — keep the public site focused on benchmark findings and methodology, while repo docs guide humans who run benchmarks on their own hardware.

## Plan & status

| Step | Scope | Status | Artifact |
| --- | --- | --- | --- |
| Step 1 | Gather and judge what is wrong (site, data, workflows, agent sessions) | Complete | [01-audit.md](./01-audit.md) |
| Step 2 | Visual information architecture: current (as-is) vs. proposed (v2) | Complete | [02-information-architecture.md](./02-information-architecture.md) |
| Review 1 | Owner feedback, locked decisions (D0–D6), Pass 1 / Pass 2 split | Complete | [03-decisions.md](./03-decisions.md) |
| Step 3 (Pass 1) | Fact-check with raw data and write concrete rewrite plan (`site/` priority) | Complete | [04-rewrite-plan.md](./04-rewrite-plan.md) |
| Step 4 (Pass 1) | Rewrite public site content (concise, verified; iterative review cycles) | Complete | [step4-checklist.md](./step4-checklist.md) · [handoff-cycle-1.md](./handoff-cycle-1.md) |
| Step 5 (Pass 1) | Redesign visual layout and components around the new structure | Next | — |
| Pass 2 | Full-rigor `docs/agents/` overhaul (writer vs. strict reviewer guides) & revisit cloneability | Scheduled after Pass 1 publish | — |

## Handoff

- Current session handoff (ready for Step 5): [handoff-cycle-1.md](./handoff-cycle-1.md)
- Previous handoff (Steps 1–2): [handoff-step-1-2.md](./handoff-step-1-2.md)
