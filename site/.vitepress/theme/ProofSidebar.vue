<script setup>
import { withBase } from 'vitepress'
import stats from '../data/site-stats.json'

const scoredRuns = stats.breakdown.evalplusRuns + stats.breakdown.mendelLocalRuns
const toolCallsK = `${(stats.telemetry.toolCalls / 1000).toFixed(1)}k`
const href = withBase('/benchmarks/')
</script>

<template>
  <a class="proof-sidebar" :href="href">
    <strong class="proof-sidebar-headline">{{ stats.displayHours }} benchmarked</strong>
    <span class="proof-sidebar-meta">
      {{ scoredRuns }} scored runs · {{ stats.counts.models }} models · {{ stats.counts.machines }} machines
    </span>
    <span class="proof-sidebar-meta">
      {{ toolCallsK }} agent tool calls · {{ stats.telemetry.commits }} commits
    </span>
  </a>
</template>
