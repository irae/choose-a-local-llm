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
| Review 1 | Owner feedback & locked architecture decisions | Complete | [03-decisions.md](./03-decisions.md) |
| Step 3 | Fact-check with raw data and write concrete rewrite plan | Next | `04-rewrite-plan.md` (pending) |
| Step 4 | Rewrite content (concise, verified; iterative review cycles) | Pending | — |
| Step 5 | Redesign visual layout and components around the new structure | Pending | — |

## Handoff

- Current session handoff: [handoff-step-1-2.md](./handoff-step-1-2.md)
