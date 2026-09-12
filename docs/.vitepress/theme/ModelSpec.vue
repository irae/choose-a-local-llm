<script setup>
const props = defineProps({
  base: { type: String, default: '' },
  quant: { type: String, default: '' },
  server: { type: String, default: '' },
  publisher: { type: String, default: '' },
  repo: { type: String, default: '' },
  drafter: { type: String, default: '' },
  kv: { type: String, default: '' },
  effort: { type: String, default: '' },
  hide: { type: String, default: '' },
  top: { type: Boolean, default: false },
})

const EFFORTS = ['off', 'on', 'low', 'medium', 'high', 'xhigh', 'max']
const KVS = ['f16', 'q8_0', 'q4_0', 'q4_0+bias']
const FIELDS = ['quant', 'server', 'publisher', 'drafter', 'kv', 'effort']
const name = `ModelSpec ${props.base || '?'} ${props.quant || ''}`.trim()

// `hide` lists the fields a line leaves out, comma separated: the rows
// under it name those. A hidden field is neither required nor shown.
const hidden = new Set(props.hide.split(',').map((s) => s.trim()).filter(Boolean))
for (const h of hidden) {
  if (!FIELDS.includes(h)) throw new Error(`${name}: hide="${h}" is not one of ${FIELDS.join(', ')}`)
}
const show = (f) => !hidden.has(f) && props[f]

if (!props.base) throw new Error(`${name}: missing base`)
for (const f of ['quant', 'server', 'publisher', 'kv', 'effort']) {
  if (!hidden.has(f) && !props[f]) throw new Error(`${name}: missing ${f} (or list it in hide)`)
}
if (show('publisher') && !props.repo) throw new Error(`${name}: a publisher needs its repo`)
if (props.repo && !/^[\w.-]+\/[\w.-]+$/.test(props.repo)) throw new Error(`${name}: repo "${props.repo}" is not owner/name`)
if (props.kv && !KVS.includes(props.kv)) throw new Error(`${name}: kv "${props.kv}" is not one of ${KVS.join(', ')}`)
if (props.effort && !EFFORTS.includes(props.effort)) throw new Error(`${name}: effort "${props.effort}" is not one of ${EFFORTS.join(', ')}`)
if (props.drafter && !/^[a-z]+(\/\d+)?$/.test(props.drafter)) {
  throw new Error(`${name}: drafter "${props.drafter}" must look like mtp/3 or dspark`)
}

const card = props.repo ? `https://huggingface.co/${props.repo}` : ''
const title = show('quant') ? `${props.base} ${props.quant}` : props.base
const hasServing = show('server') || show('publisher')
const hasPills = show('drafter') || show('kv') || show('effort')
</script>

<template>
  <span class="ms" :class="{ 'ms-top': top }">
    <span class="ms-name">{{ title }}</span>
    <span v-if="hasServing || hasPills" class="ms-sub">
      <a v-if="show('publisher')" class="ms-publisher" :href="card" target="_blank" rel="noreferrer">{{ publisher }}</a><span v-if="show('publisher') && show('server')" class="ms-serving">,</span>
      <span v-if="show('server')" class="ms-serving">{{ server }}</span>
      <span v-if="hasServing && hasPills" class="ms-serving">–</span>
      <span v-if="show('drafter')" class="ms-pill ms-drafter">{{ drafter }}</span>
      <span v-if="show('kv')" class="ms-pill ms-kv">{{ kv }}</span>
      <span v-if="show('effort')" class="ms-pill ms-effort" :class="'ms-effort-' + effort">{{ effort }}</span>
    </span>
  </span>
</template>
