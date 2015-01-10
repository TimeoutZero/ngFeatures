'use strict'

# =============================================
# Module
# =============================================
angular.module 'MyAngularOmakase.controllers'

  # =============================================
  # LoginController
  # =============================================
  .controller 'LoginController', ['$scope', '$window', 'LoginService', '$state', '$filter', '$modal', '$q',
    ($scope, $window, LoginService, $state, $filter, $modal, $q) ->

      # =============================================
      # Attributes
      # =============================================
      @facebookOptions  = scope : 'email, publish_actions', auth_type: 'rerequest'
      $scope.user       =
        firstName  : null
        email      : null

      $scope.ableToConnectWithFacebook  = yes
      

      # =============================================
      # Initialize
      # =============================================
     
      # =============================================
      # Handlers
      # =============================================
      
      # =============================================
      # Methods
      # =============================================

      # Login Methods
      # ===============================
      $scope.loginWithFacebook = (response) =>
        dataParams = 
          accessToken           : response.authResponse.accessToken

        promise = LoginService.loginWithFacebook(dataParams)
        promise.success -> $scope.openNotificationModal('Connected By Facebook')

        promise.error -> 
          $scope.ableToConnectWithFacebook  = yes
          $scope.openNotificationModal('Could not connect by Facebook')

      $scope.doLogin  = ->
        promise = LoginService.login($scope.user)
        promise.success (data, status, headers, config) -> $scope.openNotificationModal('Connected')
        promise.error (data, status, headers, config, statusText) -> 
          $scope.openNotificationModal('Could not connect')


      # Aux Methods
      # ===============================
      @loginByFacebookSDKCallback = (response) ->
        if response.status is 'connected'
          $scope.loginWithFacebookResponse response
        else
          $scope.$apply ->
            $scope.ableToConnectWithFacebook = yes
        

      @loginByFacebookSDK = =>
        defer = $q.defer()
        defer.resolve( $window.FB.login(@loginByFacebookSDKCallback, @facebookOptions , yes) )
        defer.promise.catch (e) -> 
          $scope.ableToConnectWithFacebook = yes
          $scope.openNotificationModal('Could not connect by Facebook')

      @statusChangeCallback = (response) =>
        if response.status is 'connected' then $scope.loginWithFacebook response  else do @loginByFacebookSDK

      @checkFacebookLoginState = () ->
        $scope.ableToConnectWithFacebook = no
        defer = $q.defer() 
        defer.resolve( $window.FB.getLoginStatus( (response) => @statusChangeCallback(response) ) )
        defer.promise.catch (e) -> 
          $scope.ableToConnectWithFacebook = yes
          $scope.openNotificationModal('Could not connect by Facebook')

      $scope.startLoginWithFacebookProcess = () =>
        if $window.FB then do @checkFacebookLoginState else $scope.openNotificationModal('Could not connect by Facebook')

      $scope.openNotificationModal = (text) ->
        $modal.open 
          windowClass : 'modal modal-theme-plain myo-modal'
          backdrop    : yes
          template    : """ 
            <h3>#{text}</h3>
          """
          

       

      return @

  ]