<script setup>
import { computed } from 'vue'

const props = defineProps({
  shallow: { type: String, default: '' },
  deep: { type: String, default: '' },
  stale: { type: Boolean, default: false },
  topShallow: { type: Boolean, default: false },
  topDeep: { type: Boolean, default: false },
})

if (!props.shallow || !props.deep) throw new Error('TokCell: missing shallow or deep')

const pad = (text) => {
  const s = String(text)
  if (!/^\d+(\.\d+)?$/.test(s)) return s.padStart(5)
  const [int, frac = ''] = s.split('.')
  return `${int.padStart(2)}${frac ? `.${frac}` : ' '}`.padEnd(5)
}

const left = computed(() => pad(props.shallow))
const right = computed(() => pad(props.deep))
</script>

<template>
  <span class="tk"><span v-if="stale" class="tk-stale">†</span><pre class="tk-pre"><b v-if="topShallow">{{ left }}</b><template v-else>{{ left }}</template> → <b v-if="topDeep">{{ right }}</b><template v-else>{{ right }}</template></pre></span>
</template>
