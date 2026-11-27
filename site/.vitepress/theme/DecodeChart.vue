<script setup>
import { computed } from 'vue'
import setups from '../data/curves.json'

const props = defineProps({
  model: { type: String, default: '' },
  hardware: { type: String, default: '' },
  servedOnly: { type: Boolean, default: false },
})

const MODEL_NAMES = {
  'arete-27b': 'Arete-27B',
  'bonsai-2-27b': 'Ternary-Bonsai-2-27B',
  'bonsai-27b': 'Ternary-Bonsai-27B',
  'gemma-4-12b-it': 'Gemma-4-12B',
  'gemma-4-26b-a4b': 'Gemma-4-26B-A4B',
  'qwen3.6-35b-a3b': 'Qwen3.6-35B-A3B',
  'qwen3.8-27b': 'Qwen3.8-27B',
  's5-nano': 'S5-nano',
}

const TRACES = ['var(--t1)', 'var(--t2)', 'var(--t3)', 'var(--t4)', 'var(--t5)', 'var(--t6)', 'var(--t7)', 'var(--t8)', 'var(--t9)']
const MODEL_COLOR = {
  'qwen3.8-27b': 'var(--t1)',
  'qwen3.6-35b-a3b': 'var(--t2)',
  'gemma-4-26b-a4b': 'var(--t3)',
  'gemma-4-12b-it': 'var(--t4)',
  'bonsai-2-27b': 'var(--t5)',
  'bonsai-27b': 'var(--t6)',
  's5-nano': 'var(--t7)',
  'arete-27b': 'var(--t8)',
}
const ARM_DASH = ['', '7 3', '2 2.4', '9 3 2 3']
const CREEP_DASH = ['6 3.5', '2 2.2', '10 3 2 3', '1.4 2.6']

const W = 640
const H = 308
const PAD = { l: 44, r: 36, t: 16, b: 32 }

function pointsOf(curve) {
  return Object.entries(curve.points || {})
    .map(([depth, value]) => ({ t: Number(depth), v: Number(value) }))
    .filter((point) => Number.isFinite(point.t) && Number.isFinite(point.v) && point.t > 0)
    .sort((a, b) => a.t - b.t)
}

function niceMax(value) {
  const padded = Math.max(16, value * 1.08)
  const step = padded > 48 ? 10 : padded > 24 ? 8 : 4
  return Math.ceil(padded / step) * step
}

function yTicks(yMax) {
  const step = yMax <= 20 ? 4 : yMax <= 48 ? 8 : 10
  const ticks = []
  for (let value = 0; value <= yMax + 1e-6; value += step) ticks.push(Math.round(value))
  if (ticks[ticks.length - 1] !== yMax) ticks.push(yMax)
  const kept = ticks.filter((value) => value === 0 || value === yMax || Math.abs(value - 8) / yMax > 0.055)
  if (!kept.includes(8) && 8 < yMax) kept.push(8)
  return [...new Set(kept)].sort((a, b) => a - b)
}

function xTicks(x0, x1) {
  const ticks = []
  for (let t = x0; t <= x1 + 0.5; t *= 2) ticks.push(t)
  return ticks
}

function fmtK(tokens) {
  const k = tokens / 1024
  if (k < 1) return String(tokens)
  return Number.isInteger(k) ? `${k}K` : `${Math.round(k)}K`
}

function buildChart(setup) {
  const curves = (setup.curves || []).filter((curve) => {
    if (props.model && curve.model !== props.model) return false
    if (props.servedOnly && !curve.served) return false
    return pointsOf(curve).length > 0
  })
  if (!curves.length) return null

  const dashCount = new Map()
  const prepared = curves.map((curve, index) => {
    const pts = pointsOf(curve)
    const seen = dashCount.get(curve.model) || 0
    dashCount.set(curve.model, seen + 1)
    const creep = curve.method === 'creep'
    const dashSet = creep ? CREEP_DASH : ARM_DASH
    return {
      curve,
      pts,
      served: Boolean(curve.served),
      creep,
      color: props.model
        ? TRACES[index % TRACES.length]
        : MODEL_COLOR[curve.model] || TRACES[index % TRACES.length],
      dash: props.model && !creep ? '' : dashSet[seen % dashSet.length],
    }
  })

  const all = prepared.flatMap((series) => series.pts)
  const yMax = niceMax(Math.max(...all.map((point) => point.v)))
  let x0 = Math.pow(2, Math.floor(Math.log2(Math.min(...all.map((point) => point.t)))))
  let x1 = Math.pow(2, Math.ceil(Math.log2(Math.max(...all.map((point) => point.t)))))
  if (x1 <= x0) x1 = x0 * 2
  const plotW = W - PAD.l - PAD.r
  const plotH = H - PAD.t - PAD.b
  const xOf = (tokens) => PAD.l + ((Math.log2(tokens) - Math.log2(x0)) / (Math.log2(x1) - Math.log2(x0))) * plotW
  const yOf = (value) => PAD.t + (1 - value / yMax) * plotH

  const series = prepared
    .slice()
    .sort((a, b) => Number(a.served) - Number(b.served))
    .map((series) => ({
      key: `${series.curve.model}-${series.curve.arm}`,
      label: props.model
        ? series.curve.arm
        : `${MODEL_NAMES[series.curve.model] || series.curve.model}: ${series.curve.arm}`,
      served: series.served,
      creep: series.creep,
      color: series.color,
      dash: series.dash,
      points: series.pts.map((point) => `${xOf(point.t).toFixed(1)},${yOf(point.v).toFixed(1)}`).join(' '),
      dots: series.pts.map((point) => ({ x: xOf(point.t), y: yOf(point.v) })),
    }))

  const floorY = yOf(8)
  return {
    slug: setup.hardwareSlug,
    name: setup.hardwareName || setup.hardwareSlug,
    hasCreep: series.some((item) => item.creep),
    hasUnserved: series.some((item) => !item.served),
    yTicks: yTicks(yMax).map((value) => ({ value, y: yOf(value), label: String(value) })),
    xTicks: xTicks(x0, x1).map((tokens, index, all) => ({
      x: xOf(tokens),
      label: fmtK(tokens),
      anchor: index === 0 ? 'start' : index === all.length - 1 ? 'end' : 'middle',
    })),
    floorX: PAD.l + plotW - 4,
    floorY,
    plotTop: PAD.t,
    plotBottom: PAD.t + plotH,
    plotLeft: PAD.l,
    plotRight: PAD.l + plotW,
    series,
    legend: series.slice().sort((a, b) => Number(b.served) - Number(a.served) || a.label.localeCompare(b.label)),
  }
}

const charts = computed(() =>
  setups
    .filter((setup) => !props.hardware || setup.hardwareSlug === props.hardware)
    .map(buildChart)
    .filter(Boolean),
)

const viewBox = `0 0 ${W} ${H}`
</script>

<template>
  <figure v-for="chart in charts" :key="chart.slug" class="decode-chart">
    <figcaption :id="`decode-${chart.slug}`">
      <span class="decode-chart-title">{{ chart.name }}</span>
      <span class="decode-chart-note">
        Decode speed against context depth. Horizontal line: 8 tok/s floor.
        <template v-if="chart.hasCreep"> Dashed: earlier context-creep tool.</template>
        <template v-if="chart.hasUnserved"> Filled swatch: served configuration.</template>
      </span>
    </figcaption>
    <div class="decode-chart-plot">
      <svg :viewBox="viewBox" role="img" :aria-labelledby="`decode-${chart.slug}`">
        <line
          v-for="tick in chart.yTicks.filter((tick) => tick.value !== 8)"
          :key="`y-${tick.value}`"
          :x1="chart.plotLeft"
          :x2="chart.plotRight"
          :y1="tick.y"
          :y2="tick.y"
          class="decode-grid"
        />
        <polyline
          v-for="series in chart.series"
          :key="series.key"
          :points="series.points"
          fill="none"
          :stroke="series.color"
          :stroke-width="series.served ? 2.25 : 1.35"
          :stroke-dasharray="series.dash || undefined"
          stroke-linejoin="round"
          stroke-linecap="round"
        />
        <line
          :x1="chart.plotLeft"
          :x2="chart.plotRight"
          :y1="chart.floorY"
          :y2="chart.floorY"
          class="decode-floor"
        />
        <template v-for="series in chart.series" :key="`${series.key}-dots`">
          <circle
            v-for="(dot, index) in series.dots"
            :key="`${series.key}-${index}`"
            :cx="dot.x"
            :cy="dot.y"
            r="2.2"
            :fill="series.color"
          />
        </template>
        <text
          v-for="tick in chart.yTicks"
          :key="`yl-${tick.value}`"
          :x="chart.plotLeft - 8"
          :y="tick.y + 4"
          class="decode-axis"
          text-anchor="end"
        >
          {{ tick.label }}
        </text>
        <text
          v-for="tick in chart.xTicks"
          :key="tick.label"
          :x="tick.x"
          :y="chart.plotBottom + 18"
          class="decode-axis"
          :text-anchor="tick.anchor"
        >
          {{ tick.label }}
        </text>
        <text :x="chart.floorX" :y="chart.floorY - 6" class="decode-floor-label" text-anchor="end">8 tok/s</text>
      </svg>
    </div>
    <ul class="decode-legend">
      <li v-for="series in chart.legend" :key="`leg-${series.key}`" :class="{ served: series.served }">
        <i :class="{ hollow: !series.served }" :style="{ '--swatch': series.color }" />
        <span>{{ series.label }}</span>
      </li>
    </ul>
  </figure>
</template>
