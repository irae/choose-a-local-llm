<script setup>
import DefaultTheme from 'vitepress/theme'
import ProofSidebar from './ProofSidebar.vue'

const { Layout } = DefaultTheme
</script>

<template>
  <Layout>
    <template #nav-bar-title-before>
      <svg class="brand-mark" viewBox="0 0 22 22" aria-hidden="true">
        <path d="M3 4.5 C7 6, 10 9, 13 12 S17.5 15.5, 19.5 16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
        <line class="floor" x1="2" y1="19" x2="20" y2="19" stroke-width="1.4" stroke-dasharray="2.2 2" />
        <circle cx="3" cy="4.5" r="1.8" fill="currentColor" />
      </svg>
    </template>
    <template #sidebar-nav-before>
      <ProofSidebar />
    </template>
  </Layout>
</template>
