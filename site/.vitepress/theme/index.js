import DefaultTheme from 'vitepress/theme-without-fonts'
import Layout from './Layout.vue'
import ModelSpec from './ModelSpec.vue'
import ScoreCell from './ScoreCell.vue'
import TokCell from './TokCell.vue'
import CurveCell from './CurveCell.vue'
import DataTable from './DataTable.vue'
import DecodePlot from './DecodePlot.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  Layout,
  enhanceApp({ app }) {
    app.component('ModelSpec', ModelSpec)
    app.component('ScoreCell', ScoreCell)
    app.component('TokCell', TokCell)
    app.component('CurveCell', CurveCell)
    app.component('DataTable', DataTable)
    app.component('DecodePlot', DecodePlot)
  },
}
