<script setup>
import { computed } from 'vue'

const props = defineProps({
  shallow: { type: String, default: '' },
  deep: { type: String, default: '' },
  cap: { type: String, default: '' },
  stale: { type: Boolean, default: false },
  topShallow: { type: Boolean, default: false },
  topDeep: { type: Boolean, default: false },
})

if (!props.shallow || !props.deep) throw new Error('TokCell: missing shallow or deep')

const pad = (text) => {
  const s = String(text)
  if (!/^\d+(\.\d+)?$/.test(s)) return s.padStart(4)
  return Number(s).toFixed(1).padStart(4)
}

const left = computed(() => pad(props.shallow))
const right = computed(() => pad(props.deep))
</script>

<template>
  <span class="tkw"
    ><span class="tk"
      ><span v-if="stale" class="tk-stale">†</span
      ><pre class="tk-pre"><b v-if="topShallow">{{ left }}</b><template v-else>{{ left }}</template><span class="tk-arrow">→</span><b v-if="topDeep">{{ right }}</b><template v-else>{{ right }}</template></pre></span
    ><span v-if="cap" class="cs-sub"><span class="ms-pill cs-pill cs-pill-gray">{{ cap }}</span></span></span
  >
</template>
