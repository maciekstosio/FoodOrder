var app = angular.module('FoodOrder', ['ngRoute','ng-token-auth']);

app.config(function($authProvider,$routeProvider){
  //Authorization
  $authProvider.configure({
		apiUrl: 'http://localhost:3000',
    authProviderPaths: {
      github: '/auth/github'
    }
	});

  //Route
  $routeProvider.when("/app", {
    templateUrl : "views/app.html",
    controller : "app"
  }).when("/", {
    templateUrl : "views/login.html",
    controller : "login"
  });
});


app.controller('login', function($scope,$auth,$location){
  $scope.hello = "Hello World";

  $auth.validateUser().then(function(resp) {
    //Redirect to app
    $location.path('/app');
  }).catch(function(resp) {
    if(resp.reason!="unauthorized"){
      alert("Error");
      console.log(resp);
    }
  });


  $scope.authenticate = function(){
    $auth.authenticate('github').then(function(resp) {
        //Redirect to app
        $location.path('/app');
      }).catch(function(resp) {
        alert("Error");
      });
  };
});

app.controller('app', function($scope,$auth,$location){
  //Authenticate
  $auth.validateUser().then(function(resp) {
    console.log(resp);
  }).catch(function(resp) {
    //Redirect to login page
    $location.path('/');
  });

  $scope.logout = function() {
    $auth.signOut().then(function(resp) {
      $location.path('/')
    }).catch(function(resp) {
      alert("Error");
    });
  };
});
