<script setup>
import DefaultTheme from 'vitepress/theme-without-fonts'
import ProofSidebar from './ProofSidebar.vue'

const { Layout } = DefaultTheme
</script>

<template>
  <Layout>
    <template #sidebar-nav-before>
      <ProofSidebar />
    </template>
  </Layout>
</template>
