<script setup>
const props = defineProps({
  value: { type: String, default: '' },
  note: { type: String, default: '' },
  pill: { type: String, default: '' },
  sub: { type: String, default: '' },
  top: { type: Boolean, default: false },
})

if (!props.value) throw new Error('ScoreCell: missing value')
if (props.pill && !['mendel-blind', 'mendel-guided', 'failed-smoke', 'model-failed'].includes(props.pill)) {
  throw new Error(`ScoreCell: pill "${props.pill}" is not mendel-blind, mendel-guided, failed-smoke or model-failed`)
}
</script>

<template>
  <span class="cs" :class="{ 'cs-top': top }">
    <span class="cs-value"><span v-if="note" class="cs-note">{{ note }} / </span>{{ value }}</span>
    <span v-if="pill || sub" class="cs-sub">
      <template v-if="sub">{{ sub }}</template>
      <span v-if="pill" class="ms-pill cs-pill" :class="`cs-pill-${{ 'mendel-blind': 'yellow', 'mendel-guided': 'green', 'failed-smoke': 'gray', 'model-failed': 'gray' }[pill]}`">{{ pill }}</span>
    </span>
  </span>
</template>
