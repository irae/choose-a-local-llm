import DefaultTheme from 'vitepress/theme'
import '@fontsource-variable/ibm-plex-sans/standard.css'
import '@fontsource-variable/ibm-plex-sans/standard-italic.css'
import '@fontsource/ibm-plex-mono/400.css'
import '@fontsource/ibm-plex-mono/600.css'
import Layout from './Layout.vue'
import ModelSpec from './ModelSpec.vue'
import ScoreCell from './ScoreCell.vue'
import TokCell from './TokCell.vue'
import CurveCell from './CurveCell.vue'
import DecodeChart from './DecodeChart.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  Layout,
  enhanceApp({ app }) {
    app.component('ModelSpec', ModelSpec)
    app.component('ScoreCell', ScoreCell)
    app.component('TokCell', TokCell)
    app.component('CurveCell', CurveCell)
    app.component('DecodeChart', DecodeChart)
  },
}
