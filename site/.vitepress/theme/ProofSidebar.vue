<script setup>
import { withBase } from 'vitepress'
import stats from '../data/site-stats.json'

const scoredRuns = stats.breakdown.evalplusRuns + stats.breakdown.mendelLocalRuns
const toolCallsK = `${(stats.telemetry.toolCalls / 1000).toFixed(1)}k`
const href = withBase('/benchmarks/')
</script>

<template>
  <a class="proof-sidebar" :href="href">
    <span class="proof-sidebar-headline">
      <strong>{{ stats.displayHours }}</strong>
      <span>benchmarked</span>
      <svg aria-hidden="true" width="18" height="18" viewBox="0 0 18 18" fill="none">
        <path d="M4 9h10m-4-4 4 4-4 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
      </svg>
    </span>
    <span class="proof-sidebar-meta">
      {{ scoredRuns }} scored runs · {{ stats.counts.models }} models · {{ stats.counts.machines }} machines
    </span>
    <span class="proof-sidebar-meta">
      {{ toolCallsK }} agent tool calls · {{ stats.telemetry.commits }} commits
    </span>
  </a>
</template>
