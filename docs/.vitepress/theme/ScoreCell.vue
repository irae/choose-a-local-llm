<script setup>
const props = defineProps({
  value: { type: String, default: '' },
  sub: { type: String, default: '' },
  top: { type: Boolean, default: false },
})

if (!props.value) throw new Error('ScoreCell: missing value')
</script>

<template>
  <span class="cs" :class="{ 'cs-top': top }">
    <span class="cs-value">{{ value }}</span>
    <span v-if="sub" class="cs-sub">{{ sub }}</span>
  </span>
</template>
