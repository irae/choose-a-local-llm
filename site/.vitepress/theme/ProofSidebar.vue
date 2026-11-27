<script setup>
import { withBase } from 'vitepress'
import stats from '../data/site-stats.json'

const scoredRuns = stats.breakdown.evalplusRuns + stats.breakdown.mendelLocalRuns
const toolCallsK = `${(stats.telemetry.toolCalls / 1000).toFixed(1)}k`
const machines = Object.values(stats.byMachine)
const total = machines.reduce((s, m) => s + m.totalHours, 0)
const href = withBase('/benchmarks/')
</script>

<template>
  <a class="proof-card" :href="href">
    <span class="proof-card-figure">
      <span class="proof-card-hours">{{ stats.displayHours }}</span>
      <span class="proof-card-label">benchmarked</span>
    </span>
    <span class="proof-card-bar" aria-hidden="true">
      <span v-for="m in machines" :key="m.name" :style="{ width: `${(m.totalHours / total) * 100}%` }" />
    </span>
    <span v-for="m in machines" :key="m.name" class="proof-card-split">
      <span>{{ m.name }}</span><span>{{ Math.round(m.totalHours) }}h</span>
    </span>
    <dl class="proof-card-stats">
      <div><dt>scored runs</dt><dd>{{ scoredRuns }}</dd></div>
      <div><dt>models</dt><dd>{{ stats.counts.models }}</dd></div>
      <div><dt>machines</dt><dd>{{ stats.counts.machines }}</dd></div>
      <div><dt>agent tool calls</dt><dd>{{ toolCallsK }}</dd></div>
      <div><dt>commits</dt><dd>{{ stats.telemetry.commits }}</dd></div>
    </dl>
    <span class="proof-card-link">Compute ledger</span>
  </a>
</template>
