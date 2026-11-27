<script setup>
const props = defineProps({
  value: { type: String, default: '' },
  depth: { type: String, default: '' },
  served: { type: Boolean, default: false },
})

if (!props.value) throw new Error('CurveCell: missing value')
</script>

<template>
  <span class="cc"
    ><span class="cc-value"><b v-if="served">{{ value }}</b><template v-else>{{ value }}</template></span
    ><span v-if="depth" class="cs-sub"><span class="ms-pill cs-pill cs-pill-gray">{{ depth }}</span></span></span
  >
</template>
