'use strict'

# =============================================
# Module
# =============================================
angular.module 'MyAngularOmakase.directives'

  .directive 'forkMeOnGithub', [ () ->
    restrict: 'A'
    require : 'tooltip'
    replace : yes
    scope: 
      href: "@"
      type: "@"
    template:"""
      <a 
        href="{{href}}" 
        target="_blank"
        class="fork-me-on-github animated fadeIn" 
        ng-class="{
          'top-right'   : type != 'circle',
          'blue-circle' : type === 'circle'
        }"
        title="Fork Me !!"></a>
    """
  ]
