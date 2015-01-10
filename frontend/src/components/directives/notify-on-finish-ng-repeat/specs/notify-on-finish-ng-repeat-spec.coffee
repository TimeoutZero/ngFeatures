'use strict'

# =============================================
# LoginController
# =============================================
describe 'Directive: NotifyOnFinishNgRepeat', ()->

  # =============================================
  # Import modules
  # =============================================
  beforeEach module('MyAngularOmakase.scripts')

  # =============================================
  # Variables
  # =============================================
  $scope                         = null
  NotifyOnFinishRepeatController = null

  # =============================================
  # Inject dependencies
  # =============================================
  beforeEach inject (_$rootScope_, $controller) ->
    $scope     = _$rootScope_.$new()
    
    

  # =============================================
  # Tests
  # =============================================
  describe 'Should notify the current scope when the last item of the list is iterated', ->

    it 'With default eventName (list) and default publishMode ($emit)', ->
     
        inject ($controller, $timeout) ->
          $scope.$last = yes 

          spyOn($scope, "$emit")

          NotifyOnFinishRepeatController = $controller 'NotifyOnFinishRepeatController',
            $scope : $scope

          $timeout.flush(1)

          expect($scope.finishEventName).toEqual 'list'
          expect($scope.publishMode).toEqual 'emit'
          expect($scope.$emit).toHaveBeenCalledWith("list", {finishEventName: $scope.finishEventName, publishMode: $scope.publishMode})


    it 'With custom eventName (last-item-is-ready) and not default publishMode ($broadcast)', ->
 
      inject ($controller, $timeout) ->
        eventName              = 'last-item-is-ready'
        publishMode            = 'broadcast'
        $scope.$last           = yes
        $scope.finishEventName = eventName
        $scope.publishMode     = publishMode

        spyOn($scope, "$broadcast")

        NotifyOnFinishRepeatController = $controller 'NotifyOnFinishRepeatController',
          $scope : $scope

        $timeout.flush(1)

        expect($scope.finishEventName).toEqual eventName
        expect($scope.publishMode).toEqual publishMode
        expect($scope.$broadcast).toHaveBeenCalledWith(eventName, {finishEventName: $scope.finishEventName, publishMode: $scope.publishMode})

    it 'By RootScope', ->
      inject ($controller, $timeout, _$rootScope_) ->
        $rootScope = _$rootScope_
        $scope.$last           = yes
        $scope.notifyByRoot    = yes

        spyOn($rootScope, "$emit")

        NotifyOnFinishRepeatController = $controller 'NotifyOnFinishRepeatController',
          $scope : $scope

        $timeout.flush(1)

        expect($scope.finishEventName).toEqual 'list'
        expect($scope.publishMode).toEqual 'emit'
        expect($rootScope.$emit).toHaveBeenCalledWith('list', {finishEventName: 'list', publishMode: 'emit'})


  describe 'Should NOT notify the current scope while the last is not iterated', ->

    it 'With default eventName (list) and default publishMode ($emit)', ->
     
        inject ($controller, $timeout) ->
          $scope.$last = no 

          spyOn($scope, "$emit")

          NotifyOnFinishRepeatController = $controller 'NotifyOnFinishRepeatController',
            $scope : $scope

          $timeout.flush(1)

          expect($scope.finishEventName).toEqual 'list'
          expect($scope.publishMode).toEqual 'emit'
          expect($scope.$emit).not.toHaveBeenCalled()
    

      