import 'core-js/web/dom-collections'

import('@rails/ujs').then((rails) => rails.start())
import 'hammerjs'
import 'jquery-hotkeys'
import morphdom from 'morphdom'

import jQuery from 'jquery'
import 'jquery-ui/ui/widgets/autocomplete'
import 'jquery-ui/ui/widgets/button'
import 'jquery-ui/ui/widgets/dialog'

let Danbooru = {}

declare global {
  interface Window {
    $: JQueryStatic
    jQuery: JQueryStatic
    morphdom: typeof morphdom
    Danbooru: typeof Danbooru
  }
}

window.$ = jQuery
window.jQuery = jQuery
window.morphdom = morphdom
window.Danbooru = Danbooru
