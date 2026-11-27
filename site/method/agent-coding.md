# Agent Coding Method

Real coding work requires reading a repository, running commands, editing multiple files, respecting build and lint checks, recovering from errors, and making clean commits across dozens of turns. Single-turn coding benchmarks do not test any of those skills.

## Stage 1: Tool-Calling Smoke Gate

Before launching a multi-hour full agent run, every new build passes a short, deterministic **tool-calling smoke**:

- **Task:** Swap one small dependency across two files in an isolated temporary git fixture, run checks, and create a clean commit under a 25-minute cap.
- **Pass criteria:** Valid tool calls parsed by the server, at least one clean commit on the fixture repository, clean working tree, and no repetition loop.
- **Immediate disqualifiers:** Stripped chat templates that print tool calls as raw text, truncated tool-call JSON from the server, deleting fixture `.git` metadata or mutating the outer workspace, or entering an infinite loop. Failed smokes are recorded and full runs are skipped.

## Stage 2: Full Repository Task (Mendel)

Passing configurations execute the full **Mendel** coding-agent benchmark inside an isolated git checkout using the `pi` coding harness:

- **Task scope:** Migrate eight real libraries across a monorepo while preserving build, test, formatting, and pre-commit checks, and avoiding deliberately embedded regression traps.
- **Two prompt modes (never mixed in one ranking):**
  - **Blind:** Standard issue description matching real-world developer requests.
  - **Guided:** Adds structured step guidance to separate planning failures from tool-execution failures.
- **Prompt version isolation:** Only runs on the current prompt revision appear in the primary leaderboards; earlier prompt revisions are archived separately.
- **Model default thinking level:** Every model's primary evaluation uses its published default reasoning effort rather than an arbitrary lowered setting.

## Harness Window, Compaction & Loop Detection

- **Context window:** Set from the measured clean depth ceiling (rounded down to a clean step; minus a 5% margin for dynamic-allocation runtimes).
- **Compaction keep budget:** Scaled by measured context window (`8,192` below `64K`, `16,384` from `64K` to `128K`, harness default `20,000` at `128K` and above) with no artificial `maxTokens` or `reserveTokens` overrides.
- **Live repetition-loop detection:** A sliding-window distinct-shape detector monitors the session log for identical repeated lines, counter loops, and short repeating tool-call cycles. When a loop triggers, the run stops and records the failure — the harness never injects rescue prompts or sampler hacks.
- **Active wall time:** Measures active agent execution excluding external pauses. Runs hit a hard wall cap (e.g., 300 minutes) or per-turn timeout (25 minutes) if they stall.

## Scoring Rubric & Defect Tracking

Every finished or partial run is graded on a **100-point rubric** against git diffs, test logs, and session telemetry:

- **Partial completion cap:** Displayed score is capped at `min(raw_score, 100 × libraries_done / 8)`, preventing a run that solves two libraries cleanly from outranking a complete eight-library solution.
- **Zero-commit rule:** Any run ending with zero commits is marked **`model-failed` (0/100)**.
- **Defect ledger:** Bugs introduced by the agent are classified as `critical`, `medium`, or `minor` alongside full session telemetry (output tokens, billed cache tokens, peak context, compactions, tool calls/errors, commits, and nudges).
- **Cloud baselines:** Frontier cloud models run the exact same task and rubric to anchor where local hardware stands against hosted models.
