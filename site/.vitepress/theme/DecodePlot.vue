<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'

const props = defineProps({
  series: { type: Array, required: true },
})

const selected = ref(Math.max(0, props.series.findIndex((curve) => curve.served)))
const curve = computed(() => props.series[selected.value])
const plot = ref(null)
const width = ref(680)
const height = 218
const left = 40
const right = computed(() => width.value - 15)
const top = 25
const bottom = 176
const depths = props.series.flatMap((curve) => curve.points.map(([depth]) => depth))
const speeds = props.series.flatMap((curve) => curve.points.map(([, speed]) => speed))
const depthStep = Math.max(4096, 2 ** (Math.ceil(Math.log2(Math.max(...depths))) - 2))
const maxDepth = Math.ceil(Math.max(...depths) / depthStep) * depthStep
const speedStep = Math.max(5, Math.ceil(Math.max(8, ...speeds) / 25) * 5)
const maxSpeed = Math.ceil(Math.max(8, ...speeds) / speedStep) * speedStep
const x = (depth) => left + depth / maxDepth * (right.value - left)
const y = (speed) => bottom - speed / maxSpeed * (bottom - top)
const xTicks = Array.from({ length: maxDepth / depthStep + 1 }, (_, i) => i * depthStep)
const yTicks = Array.from({ length: maxSpeed / speedStep + 1 }, (_, i) => i * speedStep)
const points = computed(() => curve.value.points.map(([depth, speed]) => `${x(depth)},${y(speed)}`).join(' '))

let observer

function measure() {
  const measured = plot.value?.clientWidth
  if (measured > 0) width.value = measured
}

onMounted(() => {
  measure()
  if (typeof ResizeObserver === 'undefined') {
    window.addEventListener('resize', measure)
    return
  }
  observer = new ResizeObserver(measure)
  observer.observe(plot.value)
})

onBeforeUnmount(() => {
  observer?.disconnect()
  window.removeEventListener('resize', measure)
})
</script>

<template>
  <figure class="decode-plot">
    <label v-if="series.length > 1" class="decode-control">
      <span>Configuration</span>
      <span class="decode-select">
        <span aria-hidden="true">{{ curve.name }}</span>
        <svg aria-hidden="true" width="16" height="16" viewBox="0 0 16 16" fill="none">
          <path d="m4 6 4 4 4-4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
        <select v-model="selected">
          <option v-for="(option, index) in series" :key="index" :value="index">{{ option.name }}</option>
        </select>
      </span>
    </label>
    <p v-else class="decode-single">{{ curve.name }}</p>
    <svg
      ref="plot"
      class="decode-svg"
      :viewBox="`0 0 ${width} ${height}`"
      role="img"
      :aria-label="`Decode speed versus context depth for ${curve.name}. The table after the plot groups readings by depth.`"
    >
      <text :x="left" y="13">tok/s</text>
      <g v-for="speed in yTicks" :key="speed">
        <line :x1="left" :x2="right" :y1="y(speed)" :y2="y(speed)" />
        <text :x="left - 8" :y="y(speed)" text-anchor="end" dominant-baseline="middle">{{ speed }}</text>
      </g>
      <g v-for="depth in xTicks" :key="depth">
        <text :x="x(depth)" :y="bottom + 18" :text-anchor="depth === maxDepth ? 'end' : 'middle'">
          {{ depth ? `${depth / 1024}K` : '0' }}
        </text>
      </g>
      <text :x="right" :y="height - 5" text-anchor="end">Context depth (tokens)</text>
      <line class="decode-floor" :x1="left" :x2="right" :y1="y(8)" :y2="y(8)" />
      <polyline :points="points" />
      <circle v-for="[depth, speed] in curve.points" :key="depth" :cx="x(depth)" :cy="y(speed)" r="3.5">
        <title>{{ depth.toLocaleString('en-US') }} tokens, {{ speed }} tok/s</title>
      </circle>
    </svg>
    <figcaption class="decode-caption">
      <span>llama-benchy</span>
      <span class="decode-floor-label">8 tok/s floor</span>
    </figcaption>
  </figure>
</template>
