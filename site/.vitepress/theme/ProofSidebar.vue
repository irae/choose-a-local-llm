<script setup>
import { withBase } from 'vitepress'
import stats from '../data/site-stats.json'

const scoredRuns = stats.breakdown.evalplusRuns + stats.breakdown.mendelLocalRuns
const toolCalls = stats.telemetry.toolCalls.toLocaleString('en-US')
const href = withBase('/benchmarks/')
const facts = [
  ['Scored runs', String(scoredRuns)],
  ['Models', String(stats.counts.models)],
  ['Machines', String(stats.counts.machines)],
  ['Tool calls', toolCalls],
]
</script>

<template>
  <a class="proof" :href="href">
    <span class="proof-hours">{{ stats.displayHours }}</span>
    <span class="proof-hours-label">benchmarked</span>
    <dl class="proof-grid">
      <div v-for="[label, value] in facts" :key="label">
        <dt>{{ label }}</dt>
        <dd>{{ value }}</dd>
      </div>
    </dl>
    <span class="proof-foot">{{ stats.telemetry.commits }} commits</span>
  </a>
</template>
