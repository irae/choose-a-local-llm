import DefaultTheme from 'vitepress/theme'
import ModelSpec from './ModelSpec.vue'
import ScoreCell from './ScoreCell.vue'
import TokCell from './TokCell.vue'
import CurveCell from './CurveCell.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('ModelSpec', ModelSpec)
    app.component('ScoreCell', ScoreCell)
    app.component('TokCell', TokCell)
    app.component('CurveCell', CurveCell)
  },
}
