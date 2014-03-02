bitcamp = angular.module("bitcampApp")

  .controller "LoginCtrl", ($http, $scope, $rootScope, $stateParams, $state, $cookieStore, colors, $timeout) ->
    $rootScope.bodyCSS["background-color"] = colors["blue-light"]

    $scope.email     = ""
    $scope.password  = ""
    $scope.token     = $stateParams.token

    $scope.title     = "camper login"

    $scope.loginB_CSS = {
      "transition": "background-color 0.3s ease-out"
    }

    $rootScope.api_messages = []

    $scope.apiErr = (name, errObj) ->
      if errObj[name]
        m = "#{name} #{errObj[name][errObj[name].length-1]}"
        console.log m
        m
      else false

    if $cookieStore.get "auth"
      $state.go "main"

    $scope.loggingIn = false
    $scope.loginF = (email, password, token) ->
      $scope.loggingIn   = true
      $scope.emailErr    = false
      $scope.passwordErr = false
      $http.post("/api/login", {
        email:    $scope.email,
        password: $scope.password,
        token:    $scope.token
      })
        .success (cookie) ->
          $rootScope.cookie = cookie
          $cookieStore.put "auth", cookie
          $http.defaults.headers.common["Authorization"] = "Token token=\"#{cookie.token}\""
          if $scope.token
            $state.go("register.two")
          else
            $state.go("main")
        .error ->
          $scope.api_messages = []
          $scope.api_messages.push "invalid credentials!"
          $scope.loginB_CSS["background-color"] = colors["red"]
          ($timeout (->
            $scope.loggingIn = false
            delete $scope.loginB_CSS["background-color"]
            $scope.api_messages = []
            $("#login-password").focus()
          ), 2000)
          $scope.emailErr    = true
          $scope.passwordErr = true
