'use strict'

# =============================================
# Module
# =============================================
angular.module 'MyAngularOmakase'
  
  # =============================================
  # App Config
  # =============================================
  .config( ['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider) ->

    # Default State
    # =============================================
    $urlRouterProvider.otherwise('/login')

    
  ])
