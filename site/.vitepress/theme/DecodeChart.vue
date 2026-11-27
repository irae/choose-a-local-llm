<script setup>
import { computed, onBeforeUnmount, onMounted, reactive } from 'vue'
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
const MARKERS = ['circle', 'square', 'diamond', 'triangle']
const CREEP_DASH = '6 3.5'

const W = 640
const H = 308
const PAD = { l: 44, r: 36, t: 16, b: 32 }

const plotState = reactive({})
const plotEls = new Map()
let plotObserver
let plotFrame = 0

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
  let guard = 0
  for (let t = x0; t <= x1 + 0.5 && guard < 16; t *= 2) {
    ticks.push(t)
    guard += 1
  }
  return ticks
}

function fmtK(tokens) {
  const k = tokens / 1024
  if (k < 1) return String(tokens)
  return Number.isInteger(k) ? `${k}K` : `${Math.round(k)}K`
}

function baseLabel(series) {
  return props.model
    ? series.curve.arm
    : `${MODEL_NAMES[series.curve.model] || series.curve.model}: ${series.curve.arm}`
}

function uniqueLabels(items) {
  const counts = new Map()
  for (const item of items) counts.set(item.label, (counts.get(item.label) || 0) + 1)
  const seen = new Map()
  return items.map((item) => {
    if ((counts.get(item.label) || 0) < 2) return item
    const n = (seen.get(item.label) || 0) + 1
    seen.set(item.label, n)
    return n === 1 ? item : { ...item, label: `${item.label} (${n})` }
  })
}

function buildChart(setup) {
  const curves = (setup.curves || []).filter((curve) => {
    if (props.model && curve.model !== props.model) return false
    if (props.servedOnly && !curve.served) return false
    return pointsOf(curve).length > 0
  })
  if (!curves.length) return null

  const armIndex = new Map()
  const prepared = curves.map((curve, index) => {
    const seen = armIndex.get(curve.model) || 0
    armIndex.set(curve.model, seen + 1)
    const creep = curve.method === 'creep'
    return {
      curve,
      pts: pointsOf(curve),
      served: Boolean(curve.served),
      creep,
      color: props.model
        ? TRACES[index % TRACES.length]
        : MODEL_COLOR[curve.model] || TRACES[index % TRACES.length],
      dash: creep ? CREEP_DASH : '',
      marker: MARKERS[seen % MARKERS.length],
    }
  })

  const bases = prepared.map(baseLabel)
  const baseCounts = new Map()
  for (const base of bases) baseCounts.set(base, (baseCounts.get(base) || 0) + 1)

  const labeled = uniqueLabels(
    prepared.map((series, index) => {
      const base = bases[index]
      const markCreep = series.creep && (baseCounts.get(base) || 0) > 1
      return {
        ...series,
        key: `${series.curve.model}|${series.curve.arm}|${series.curve.method || ''}|${index}`,
        label: markCreep ? `${base} †` : base,
      }
    }),
  )

  const all = labeled.flatMap((series) => series.pts)
  const yMax = niceMax(Math.max(...all.map((point) => point.v)))
  let x0 = Math.pow(2, Math.floor(Math.log2(Math.min(...all.map((point) => point.t)))))
  let x1 = Math.pow(2, Math.ceil(Math.log2(Math.max(...all.map((point) => point.t)))))
  if (!(x1 > x0)) x1 = x0 * 2
  const plotW = W - PAD.l - PAD.r
  const plotH = H - PAD.t - PAD.b
  const xOf = (tokens) => PAD.l + ((Math.log2(tokens) - Math.log2(x0)) / (Math.log2(x1) - Math.log2(x0))) * plotW
  const yOf = (value) => PAD.t + (1 - value / yMax) * plotH

  const series = labeled
    .slice()
    .sort((a, b) => Number(a.served) - Number(b.served))
    .map((series) => ({
      key: series.key,
      label: series.label,
      served: series.served,
      creep: series.creep,
      color: series.color,
      dash: series.dash,
      marker: series.marker,
      points: series.pts.map((point) => `${xOf(point.t).toFixed(1)},${yOf(point.v).toFixed(1)}`).join(' '),
      dots: series.pts.map((point) => ({ x: Number(xOf(point.t).toFixed(1)), y: Number(yOf(point.v).toFixed(1)) })),
    }))

  const floorY = yOf(8)
  return {
    slug: setup.hardwareSlug,
    name: setup.hardwareName || setup.hardwareSlug,
    hasCreep: series.some((item) => item.creep),
    hasBench: series.some((item) => !item.creep),
    hasUnserved: series.some((item) => !item.served),
    yTicks: yTicks(yMax).map((value) => ({ value, y: yOf(value), label: String(value) })),
    xTicks: xTicks(x0, x1).map((tokens, index, allTicks) => ({
      x: xOf(tokens),
      label: fmtK(tokens),
      anchor: index === 0 ? 'start' : index === allTicks.length - 1 ? 'end' : 'middle',
    })),
    floorX: PAD.l + plotW - 4,
    floorY,
    plotTop: PAD.t,
    plotBottom: PAD.t + plotH,
    plotLeft: PAD.l,
    plotRight: PAD.l + plotW,
    series,
    legend: series.slice().sort((a, b) => Number(b.served) - Number(a.served) || (a.label < b.label ? -1 : a.label > b.label ? 1 : 0)),
  }
}

const charts = computed(() =>
  setups
    .filter((setup) => !props.hardware || setup.hardwareSlug === props.hardware)
    .map(buildChart)
    .filter(Boolean),
)

const viewBox = `0 0 ${W} ${H}`

function markerStyle(series) {
  if (series.served) return { fill: series.color, stroke: series.color, strokeWidth: 1 }
  return { fill: 'var(--vp-c-bg)', stroke: series.color, strokeWidth: 1.25 }
}

function diamond(dot) {
  return `${dot.x},${dot.y - 2.7} ${dot.x + 2.5},${dot.y} ${dot.x},${dot.y + 2.7} ${dot.x - 2.5},${dot.y}`
}

function triangle(dot) {
  return `${dot.x},${dot.y - 2.6} ${dot.x + 2.5},${dot.y + 2.2} ${dot.x - 2.5},${dot.y + 2.2}`
}

function legendDiamond() {
  return diamond({ x: 7, y: 5 })
}

function legendTriangle() {
  return triangle({ x: 7, y: 5 })
}

function measurePlot(slug) {
  const el = plotEls.get(slug)
  if (!el) return
  const max = el.scrollWidth - el.clientWidth
  const overflowing = max > 2
  const atStart = !overflowing || el.scrollLeft <= 2
  const atEnd = !overflowing || el.scrollLeft >= max - 2
  const prev = plotState[slug]
  if (prev && prev.overflowing === overflowing && prev.atStart === atStart && prev.atEnd === atEnd) return
  plotState[slug] = { overflowing, atStart, atEnd }
}

function measurePlots() {
  for (const slug of plotEls.keys()) measurePlot(slug)
}

function schedulePlots() {
  cancelAnimationFrame(plotFrame)
  plotFrame = requestAnimationFrame(measurePlots)
}

function bindPlot(slug, el) {
  const prev = plotEls.get(slug)
  if (typeof Element !== 'undefined' && el instanceof Element) {
    if (prev === el) return
    if (prev) plotObserver?.unobserve(prev)
    plotEls.set(slug, el)
    plotObserver?.observe(el)
    if (plotObserver) schedulePlots()
    return
  }
  if (!prev) return
  plotObserver?.unobserve(prev)
  plotEls.delete(slug)
}

function plotClass(slug) {
  const state = plotState[slug]
  if (!state?.overflowing) return {}
  return {
    'is-overflowing': true,
    'is-scrolled-start': state.atStart,
    'is-scrolled-end': state.atEnd,
  }
}

function onPlotScroll(slug) {
  measurePlot(slug)
}

onMounted(() => {
  plotObserver = new ResizeObserver(schedulePlots)
  for (const el of plotEls.values()) plotObserver.observe(el)
  schedulePlots()
})

onBeforeUnmount(() => {
  cancelAnimationFrame(plotFrame)
  plotObserver?.disconnect()
  plotObserver = undefined
  plotEls.clear()
})
</script>

<template>
  <figure v-for="chart in charts" :key="chart.slug" class="decode-chart">
    <figcaption :id="`decode-${chart.slug}`">
      <span class="decode-chart-title">{{ chart.name }}</span>
      <span class="decode-chart-note">
        Decode speed against context depth. Horizontal line: 8 tok/s floor.
        <template v-if="chart.hasCreep">
          Dashed: earlier context-creep tool<template v-if="chart.hasBench">, not directly comparable to solid lines</template>.
        </template>
        <template v-if="chart.hasUnserved"> Filled marker: served configuration.</template>
      </span>
    </figcaption>
    <div class="decode-chart-plot" :class="plotClass(chart.slug)" :ref="(el) => bindPlot(chart.slug, el)" @scroll.passive="onPlotScroll(chart.slug)">
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
          :style="{ stroke: series.color }"
          :stroke-width="series.served ? 2.25 : 1.35"
          :stroke-dasharray="series.dash || null"
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
          <template v-for="(dot, index) in series.dots" :key="`${series.key}-${index}`">
            <circle v-if="series.marker === 'circle'" :cx="dot.x" :cy="dot.y" r="2.3" :style="markerStyle(series)" />
            <rect
              v-else-if="series.marker === 'square'"
              :x="dot.x - 2.1"
              :y="dot.y - 2.1"
              width="4.2"
              height="4.2"
              :style="markerStyle(series)"
            />
            <polygon v-else-if="series.marker === 'diamond'" :points="diamond(dot)" :style="markerStyle(series)" />
            <polygon v-else :points="triangle(dot)" :style="markerStyle(series)" />
          </template>
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
          v-for="(tick, index) in chart.xTicks"
          :key="`x-${index}`"
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
      <li v-for="series in chart.legend" :key="series.key" :class="{ served: series.served }">
        <svg class="decode-marker" viewBox="0 0 14 10" aria-hidden="true">
          <line
            x1="0.5"
            y1="5"
            x2="13.5"
            y2="5"
            :style="{ stroke: series.color }"
            :stroke-width="series.served ? 2.4 : 1.3"
            :stroke-dasharray="series.dash || null"
          />
          <circle v-if="series.marker === 'circle'" cx="7" cy="5" r="2.2" :style="markerStyle(series)" />
          <rect v-else-if="series.marker === 'square'" x="4.8" y="2.8" width="4.4" height="4.4" :style="markerStyle(series)" />
          <polygon v-else-if="series.marker === 'diamond'" :points="legendDiamond()" :style="markerStyle(series)" />
          <polygon v-else :points="legendTriangle()" :style="markerStyle(series)" />
        </svg>
        <span>{{ series.label }}</span>
      </li>
    </ul>
  </figure>
</template>
