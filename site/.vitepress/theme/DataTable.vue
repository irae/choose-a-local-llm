<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'

const scroller = ref(null)
const overflows = ref(false)
let observer

function measure() {
  const el = scroller.value
  if (el) overflows.value = el.scrollWidth > el.clientWidth
}

onMounted(() => {
  measure()
  if (typeof ResizeObserver === 'undefined') {
    window.addEventListener('resize', measure)
    document.fonts?.ready.then(measure)
    return
  }
  const el = scroller.value
  observer = new ResizeObserver(measure)
  observer.observe(el)
  const table = el.querySelector('table')
  if (table) observer.observe(table)
})

onBeforeUnmount(() => {
  observer?.disconnect()
  window.removeEventListener('resize', measure)
})
</script>

<template>
  <div class="data-table">
    <div v-if="overflows" class="data-table-hint" aria-hidden="true">
      <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
        <path d="M2.5 8h11m-8-3-3 3 3 3m5-6 3 3-3 3" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" />
      </svg>
      Scroll for more columns
    </div>
    <div
      ref="scroller"
      class="data-table-scroll"
      :tabindex="overflows ? 0 : undefined"
      :role="overflows ? 'region' : undefined"
      :aria-label="overflows ? 'Horizontally scrollable table' : undefined"
    >
      <slot />
    </div>
  </div>
</template>
