<script setup>
import { computed, onMounted, onBeforeUnmount, ref } from 'vue'
import data from '../data/decode-curves.json'

const props = defineProps({
  model: { type: String, default: '' },
  machine: { type: String, default: '' },
})

if (!props.model === !props.machine) throw new Error('DecodeChart: pass exactly one of model or machine')

const FLOOR = 8
const modelTitle = new Map(data.models.map((m) => [m.slug, m.title]))
const machineName = new Map(data.machines.map((m) => [m.slug, m.name]))
const kLabel = (d) => `${Math.round(d / 1024)}K`

const byModel = Boolean(props.machine)
const groupKey = (c) => (byModel ? c.model : c.machine)
const groupOrder = byModel ? data.models.map((m) => m.slug) : data.machines.map((m) => m.slug)
const groupName = (k) => (byModel ? modelTitle.get(k) : machineName.get(k)) || k
const colorOf = (k) => (byModel ? groupOrder.indexOf(k) % 8 : [0, 2, 3, 4][groupOrder.indexOf(k) % 4])

const series = data.curves
  .filter((c) => (byModel ? c.machine === props.machine : c.model === props.model))
  .filter((c) => c.points.length)
  .map((c, i) => ({ ...c, id: i, group: groupKey(c), color: colorOf(groupKey(c)) }))
  .sort((a, b) => Number(a.served) - Number(b.served))

if (!series.length) throw new Error(`DecodeChart: no curves for ${props.model || props.machine}`)

const groups = groupOrder
  .filter((k) => series.some((s) => s.group === k))
  .map((k) => ({ key: k, name: groupName(k), color: colorOf(k) }))

const hasCreep = series.some((s) => s.creep)
const maxDepth = Math.max(...series.flatMap((s) => s.points.map((p) => p[0])))
const maxSpeed = Math.max(...series.flatMap((s) => s.points.map((p) => p[1])))
const xStep = maxDepth > 160 * 1024 ? 32 * 1024 : 16 * 1024
const xMax = Math.ceil(maxDepth / xStep) * xStep
const yStep = maxSpeed > 40 ? 10 : 5
const yMax = Math.ceil((maxSpeed + 2) / yStep) * yStep

const root = ref(null)
const width = ref(720)
const height = computed(() => (width.value < 560 ? 240 : 300))
const pad = computed(() => ({ top: 26, right: 12, bottom: 40, left: 40 }))
const plotW = computed(() => width.value - pad.value.left - pad.value.right)
const plotH = computed(() => height.value - pad.value.top - pad.value.bottom)
const x = (d) => pad.value.left + (d / xMax) * plotW.value
const y = (v) => pad.value.top + plotH.value - (v / yMax) * plotH.value

const xTicks = computed(() => {
  const every = plotW.value / (xMax / xStep) < 44 ? 2 : 1
  const ticks = []
  for (let d = 0, i = 0; d <= xMax; d += xStep, i++) ticks.push({ d, label: i % every === 0 })
  return ticks
})
const yTicks = computed(() => {
  const ticks = []
  for (let v = 0; v <= yMax; v += yStep) ticks.push(v)
  return ticks
})

const plotted = computed(() =>
  series.map((s) => ({
    ...s,
    line: s.points.map(([d, v]) => `${x(d).toFixed(1)},${y(v).toFixed(1)}`).join(' '),
    dots: s.points.map(([d, v]) => ({ cx: x(d), cy: y(v) })),
  })),
)

const hoverSeries = ref(null)
const pinnedGroup = ref(null)
const hoverGroup = ref(null)
const activeGroup = computed(() => hoverGroup.value ?? pinnedGroup.value)
const isFocus = (s) => (hoverSeries.value != null ? hoverSeries.value === s.id : activeGroup.value != null && activeGroup.value === s.group)
const hasFocus = computed(() => hoverSeries.value != null || activeGroup.value != null)

const describe = (s) => {
  const first = s.points[0]
  const last = s.points[s.points.length - 1]
  const who = byModel ? modelTitle.get(s.model) : machineName.get(s.machine)
  return {
    who,
    arm: `${s.arm}${s.c ? `, -c ${kLabel(s.c)}` : ''}${s.creep ? ' †' : ''}`,
    run: `${first[1]} tok/s at ${kLabel(first[0])} → ${last[1]} tok/s at ${kLabel(last[0])}`,
    served: s.served,
  }
}

const readout = computed(() => {
  if (hoverSeries.value != null) return describe(series.find((s) => s.id === hoverSeries.value))
  return null
})

const togglePin = (k) => {
  pinnedGroup.value = pinnedGroup.value === k ? null : k
  hoverGroup.value = null
}

const ariaLabel = `Decode speed against context depth for ${series.length} measured ${series.length === 1 ? 'curve' : 'curves'}${
  props.model ? ` of ${modelTitle.get(props.model) || props.model}` : ` on ${machineName.get(props.machine) || props.machine}`
}, with the ${FLOOR} tok/s usability floor marked. The table below lists every reading.`

let observer
onMounted(() => {
  const measure = () => {
    if (root.value) width.value = Math.max(300, Math.round(root.value.clientWidth))
  }
  measure()
  observer = new ResizeObserver(measure)
  observer.observe(root.value)
})
onBeforeUnmount(() => observer?.disconnect())
</script>

<template>
  <figure class="dc" :class="{ 'has-focus': hasFocus, 'is-single': hoverSeries != null }">
    <ul class="dc-legend">
      <li v-for="g in groups" :key="g.key">
        <button
          type="button"
          :class="`dc-c-${g.color}`"
          :aria-pressed="pinnedGroup === g.key"
          @click="togglePin(g.key)"
          @mouseenter="hoverGroup = g.key"
          @mouseleave="hoverGroup = null"
          @focus="hoverGroup = g.key"
          @blur="hoverGroup = null"
        >
          <span class="dc-swatch" />{{ g.name }}
        </button>
      </li>
    </ul>
    <div ref="root" class="dc-plot">
      <svg :width="width" :height="height" :viewBox="`0 0 ${width} ${height}`" role="img" :aria-label="ariaLabel">
        <g class="dc-grid">
          <line v-for="v in yTicks" :key="`gy${v}`" :x1="pad.left" :x2="width - pad.right" :y1="y(v)" :y2="y(v)" />
        </g>
        <g class="dc-floor">
          <rect :x="pad.left" :y="y(FLOOR)" :width="plotW" :height="y(0) - y(FLOOR)" />
          <line :x1="pad.left" :x2="width - pad.right" :y1="y(FLOOR)" :y2="y(FLOOR)" />
          <text :x="width - pad.right" :y="y(FLOOR) - 5" text-anchor="end">{{ FLOOR }} tok/s floor</text>
        </g>
        <g class="dc-axis">
          <text v-for="v in yTicks" :key="`ty${v}`" :x="pad.left - 8" :y="y(v) + 4" text-anchor="end">{{ v }}</text>
          <template v-for="t in xTicks" :key="`tx${t.d}`">
            <text v-if="t.label" :x="x(t.d)" :y="height - pad.bottom + 17" text-anchor="middle">{{ t.d ? kLabel(t.d) : '0' }}</text>
          </template>
          <text class="dc-title" :x="pad.left - 8" :y="pad.top - 10" text-anchor="end">tok/s</text>
          <text class="dc-title" :x="width - pad.right" :y="height - 4" text-anchor="end">context depth (tokens)</text>
        </g>
        <g
          v-for="s in plotted"
          :key="s.id"
          class="dc-series"
          :class="[`dc-c-${s.color}`, { 'is-served': s.served, 'is-creep': s.creep, 'is-focus': isFocus(s) }]"
        >
          <polyline :points="s.line" />
          <circle v-for="(p, i) in s.dots" :key="i" :cx="p.cx" :cy="p.cy" :r="s.served ? 2.6 : 2" />
          <polyline class="dc-hit" :points="s.line" @mouseenter="hoverSeries = s.id" @mouseleave="hoverSeries = null" />
        </g>
      </svg>
    </div>
    <p class="dc-readout" aria-live="polite">
      <template v-if="readout">
        <b>{{ readout.who }}</b> {{ readout.arm }}<template v-if="readout.served"> (served)</template>: {{ readout.run }}
      </template>
      <template v-else-if="series.length > 1">Point at a line, or pick a {{ byModel ? 'model' : 'machine' }}, to isolate it.</template>
    </p>
    <figcaption class="dc-key">
      Heavy lines are served configs; light lines are other arms<template v-if="hasCreep">; dashed lines are † earlier-method curves</template>. Shaded band: below the {{ FLOOR }} tok/s floor.
    </figcaption>
  </figure>
</template>
