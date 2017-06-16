var app = angular.module('FoodOrder', ['ngRoute','ng-token-auth']);

app.config(function($authProvider,$routeProvider,$locationProvider){
  //Authorization
  $authProvider.configure({
		apiUrl: 'http://localhost:3000',
    authProviderPaths: {
      github: '/auth/github'
    }
	});

  //Route
  $routeProvider.when("/", {
    templateUrl : "views/app.html",
    controller : "app"
  }).when("/login", {
    templateUrl : "views/login.html",
    controller : "login"
  });
});


app.controller('login', function($scope,$auth,$location){
  $auth.validateUser().then(function(resp) {
    //Redirect to app
    $location.path('/');
  }).catch(function(resp) {
    if(resp.reason!="unauthorized"){
      alert("Error");
      console.log(resp);
    }
  });


  $scope.authenticate = function(){
    $auth.authenticate('github').then(function(resp) {
        //Redirect to app
        alert("REDIRECT");
        $location.path('/');
      }).catch(function(resp) {
        alert("Error");
      });
  };
});

app.controller('app', function($scope,$auth,$location){
  //Authenticate
  $auth.validateUser().then(function(resp) {
    console.log(resp);
    $location.search({});
    $scope.nickname = resp.nickname;
    $scope.name = resp.name;
    $scope.image = resp.image;
  }).catch(function(resp) {
    //Redirect to login page
    $location.path('/login');
  });

  $scope.logout = function() {
    $auth.signOut().then(function(resp) {
      $location.path('/login');
    }).catch(function(resp) {
      alert("Error");
    });
  };
});
