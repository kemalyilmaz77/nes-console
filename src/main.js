import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import Carousel3d from 'vue3-carousel-3d'
import "vue3-carousel-3d/dist/index.css"
// Vuetify
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'

const vuetify = createVuetify({
    components,
    directives,
})

const app = createApp(App)
app.use(vuetify)
app.use(Carousel3d)
app.mount('#app')