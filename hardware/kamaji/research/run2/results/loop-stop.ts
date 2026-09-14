import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { appendFileSync } from "node:fs";

/*
 * loop-stop.ts — research run 2, experiment T2.4 (AGENT.md section I).
 *
 * Ends a run that is repeating one tool call. It is a STOP, not a
 * rescue: it never edits a tool result and never tells the model
 * anything, because a detector that rescues a looping model changes
 * what the benchmark reports.
 *
 * The rule comes from the two reproduced Gemma-12B loops. Both began
 * with a malformed call that pi rejected, and the model re-emitted the
 * rejected call unchanged: `ls -F_r` 72 times in a row in the original,
 * `bash {"command": 4}` 37 times in a row in the replay. So the signal
 * is N identical consecutive calls, and it fires by call 11-40.
 *
 * Load it explicitly, never by discovery:
 *   pi -e research/run2/results/loop-stop.ts
 * `run-pi-rpc.mjs` spawns pi with `--no-extensions`, so a scored run
 * cannot pick this up by accident. That is deliberate.
 *
 * Environment:
 *   PI_LOOP_STOP_N       identical calls in a row that end the run
 *                        (default 8)
 *   PI_LOOP_STOP_MARKER  file to append the stop record to, one JSON
 *                        object per line. The runner reads it to record
 *                        an end reason of its own.
 */

const THRESHOLD = Number(process.env.PI_LOOP_STOP_N ?? 8);
const MARKER = process.env.PI_LOOP_STOP_MARKER;

function stableKey(toolName: string, input: unknown): string {
  return JSON.stringify([toolName, input], (_key, value) => {
    if (value && typeof value === "object" && !Array.isArray(value)) {
      const sorted: Record<string, unknown> = {};
      for (const key of Object.keys(value as object).sort()) {
        sorted[key] = (value as Record<string, unknown>)[key];
      }
      return sorted;
    }
    return value;
  });
}

export default function (pi: ExtensionAPI) {
  let previousKey: string | null = null;
  let streak = 0;
  let stopped = false;

  pi.on("tool_call", async (event, ctx) => {
    if (stopped) {
      return {
        block: true,
        reason: "Run already ended by loop-stop.",
        terminate: true,
      };
    }

    const key = stableKey(event.toolName, event.input);
    streak = key === previousKey ? streak + 1 : 1;
    previousKey = key;

    if (streak < THRESHOLD) {
      return;
    }

    stopped = true;
    const reason =
      `loop-stop: the same ${event.toolName} call was emitted ` +
      `${streak} times in a row. Ending the run.`;

    if (MARKER) {
      const record = {
        event: "loop_stop",
        at: new Date().toISOString(),
        toolName: event.toolName,
        input: event.input,
        streak,
        threshold: THRESHOLD,
      };
      appendFileSync(MARKER, JSON.stringify(record) + "\n");
    }

    ctx.ui.notify(reason, "error");
    return { block: true, reason, terminate: true };
  });
}
