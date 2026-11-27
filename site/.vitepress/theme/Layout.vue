<script setup>
import { nextTick, onBeforeUnmount, onMounted, watch } from 'vue'
import { useRoute } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import ProofSidebar from './ProofSidebar.vue'

const { Layout } = DefaultTheme
const route = useRoute()

let observer
let resizeObserver

function markTables() {
  document.querySelectorAll('.vp-doc table').forEach((table) => {
    const overflow = table.scrollWidth - table.clientWidth
    const overflowing = overflow > 2
    table.classList.toggle('is-overflowing', overflowing)
    table.classList.toggle('is-scrolled-start', !overflowing || table.scrollLeft <= 2)
    table.classList.toggle('is-scrolled-end', !overflowing || table.scrollLeft >= overflow - 2)
    if (table.dataset.scrollBound) return
    table.dataset.scrollBound = '1'
    table.addEventListener(
      'scroll',
      () => {
        const max = table.scrollWidth - table.clientWidth
        table.classList.toggle('is-scrolled-start', table.scrollLeft <= 2)
        table.classList.toggle('is-scrolled-end', table.scrollLeft >= max - 2)
      },
      { passive: true },
    )
  })
}

async function refresh() {
  await nextTick()
  requestAnimationFrame(markTables)
}

onMounted(() => {
  const root = document.querySelector('.VPContent') || document.body
  observer = new MutationObserver(refresh)
  observer.observe(root, { childList: true, subtree: true })
  resizeObserver = new ResizeObserver(markTables)
  resizeObserver.observe(document.documentElement)
  refresh()
})

watch(() => route.path, refresh)

onBeforeUnmount(() => {
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
