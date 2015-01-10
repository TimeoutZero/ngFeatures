'use strict'

# =============================================
# Module
# =============================================
angular.module 'MyAngularOmakase.controllers'

  # =============================================
  # NotifyOnFinishRepeatController
  # =============================================
  .controller 'NotifyOnFinishRepeatController', [ '$scope', '$timeout', '$rootScope',
    ($scope, $timeout, $rootScope) ->

      # =============================================
      # Attributes
      # =============================================
      $scope.eventModes =
        EMIT_MODE      : 'emit'
        BROADCAST_MODE : 'broadcast'

      $scope.finishEventName  or=  "list"
      $scope.publishMode      or= $scope.eventModes.EMIT_MODE
      currentEventScope         = if $scope.notifyByRoot then $rootScope else $scope

      $scope.config =
        finishEventName : $scope.finishEventName
        publishMode     : $scope.publishMode

      # =============================================
      # Methods
      # =============================================


      # =============================================
      # Aux Methods
      # =============================================
      

      # =============================================
      # Initialize
      # =============================================
      if $scope.$last is yes  
       
        switch $scope.publishMode 
          when $scope.eventModes.EMIT_MODE
            $timeout -> 
                currentEventScope.$emit("#{$scope.finishEventName}", $scope.config)
              , 0

          when $scope.eventModes.BROADCAST_MODE
            $timeout -> 
                currentEventScope.$broadcast("#{$scope.finishEventName}", $scope.config)
              , 0


      return @

  ]