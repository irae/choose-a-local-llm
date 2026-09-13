<script setup>
const props = defineProps({
  value: { type: String, default: '' },
  note: { type: String, default: '' },
  pill: { type: String, default: '' },
  sub: { type: String, default: '' },
  top: { type: Boolean, default: false },
})

if (!props.value) throw new Error('ScoreCell: missing value')
if (props.pill && !['mendel-blind', 'mendel-guided', 'failed-smoke'].includes(props.pill)) {
  throw new Error(`ScoreCell: pill "${props.pill}" is not mendel-blind, mendel-guided or failed-smoke`)
}
</script>

<template>
  <span class="cs" :class="{ 'cs-top': top }">
    <span class="cs-value"><span v-if="note" class="cs-note">{{ note }} / </span>{{ value }}</span>
    <span v-if="pill || sub" class="cs-sub">
      <template v-if="sub">{{ sub }}</template>
      <span v-if="pill" class="ms-pill cs-pill" :class="`cs-pill-${pill.replace('mendel-', '')}`">{{ pill }}</span>
    </span>
  </span>
</template>
