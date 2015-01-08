'use strict'

# =============================================
# Module
# =============================================
angular.module 'MyAngularOmakase.directives'

  # =============================================
  # mainMenu
  # =============================================
  .directive 'mainBar', [ () ->
    restrict: 'A'
    replace : yes
    scope: 
      hasMenu : "@"
      hasUser : "@"
    controller  : ['$scope', '$filter', '$rootScope', '$state',
      ($scope, $filter, $rootScope, $state) ->

        # =============================================
        # Attributes
        # =============================================
        $scope.currentParentState = null
        $scope.user               = null
        $scope.isOpen             = no
        
        $scope.hasMenu   = if $scope.hasMenu then $scope.$eval($scope.hasMenu) else no
        $scope.hasUser   = if $scope.hasUser then $scope.$eval($scope.hasUser) else no

        $scope.menuItems = []

        # =============================================
        # Methods
        # =============================================
        $scope.changeSelectedItem = () =>
          states = $state.current.name.split('.')
          $scope.currentParentState = states[0] or $state.current.name

        $scope.loggout = ->
          promise = LoginService.loggout()
          promise.success -> $state.go 'login'

        # =============================================
        # Events
        # =============================================
        $scope.changeSelectedItem()


    ]
    templateUrl: 'views/components/directives/main-bar/views/main-bar.html'
  ]
