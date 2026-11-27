<script setup>
import { nextTick, onBeforeUnmount, onMounted, watch } from 'vue'
import { useRoute } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import ProofSidebar from './ProofSidebar.vue'

const { Layout } = DefaultTheme
const route = useRoute()

let observer
let resizeObserver
let root
let frame = 0
let queued = false
let alive = false

function markTables() {
  document.querySelectorAll('.vp-doc table').forEach((table) => {
    const max = table.scrollWidth - table.clientWidth
    const overflowing = max > 2
    table.classList.toggle('is-overflowing', overflowing)
    table.classList.toggle('is-scrolled-start', !overflowing || table.scrollLeft <= 2)
    table.classList.toggle('is-scrolled-end', !overflowing || table.scrollLeft >= max - 2)
  })
}

function schedule() {
  if (!alive) return
  cancelAnimationFrame(frame)
  frame = requestAnimationFrame(() => {
    if (alive) markTables()
  })
}

function refresh() {
  if (queued) return
  queued = true
  nextTick(() => {
    queued = false
    schedule()
  })
}

function onScroll(event) {
  const table = event.target
  if (!(table instanceof Element) || !table.matches('.vp-doc table')) return
  const max = table.scrollWidth - table.clientWidth
  table.classList.toggle('is-scrolled-start', table.scrollLeft <= 2)
  table.classList.toggle('is-scrolled-end', max <= 2 || table.scrollLeft >= max - 2)
}

onMounted(() => {
  alive = true
  root = document.querySelector('.VPContent') || document.body
  root.addEventListener('scroll', onScroll, { capture: true, passive: true })
  observer = new MutationObserver(refresh)
  observer.observe(root, { childList: true, subtree: true })
  resizeObserver = new ResizeObserver(schedule)
  resizeObserver.observe(document.documentElement)
  document.fonts?.ready?.then(() => schedule())
  refresh()
})

watch(() => route.path, refresh)

onBeforeUnmount(() => {
  alive = false
  cancelAnimationFrame(frame)
  root?.removeEventListener('scroll', onScroll, true)
  observer?.disconnect()
  resizeObserver?.disconnect()
})
</script>

<template>
  <Layout>
    <template #sidebar-nav-before>
      <ProofSidebar />
    </template>
  </Layout>
</template>
