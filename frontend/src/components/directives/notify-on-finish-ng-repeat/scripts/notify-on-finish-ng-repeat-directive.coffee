'use strict'

# =============================================
# Module
# =============================================
angular.module 'MyAngularOmakase.directives'
  .directive 'notifyOnFinishNgRepeat', ['$timeout', '$rootScope', 'NotifyOnFinishRepeatController', 
    ($timeout, $rootScope, NotifyOnFinishRepeatController) ->
      restrict: 'A'
      scope: 
        finishEventName     : "@"
        publishMode         : "@"
        notifyByRoot        : "@"
      controller : NotifyOnFinishRepeatController

      
  ]
