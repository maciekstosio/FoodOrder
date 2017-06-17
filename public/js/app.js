var app = angular.module('FoodOrder', ['ngRoute','ng-token-auth']);
var serverUrl = "http://localhost:3000";

app.config(function($authProvider,$routeProvider,$locationProvider){
  //Authorization
  $authProvider.configure({
		apiUrl: 'http://localhost:3000',
    // storage: 'localStorage',
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

app.run(['$rootScope','$auth', '$location', function($rootScope,$auth,$location) {
  $auth.validateUser().then(function(resp) {
    //Redirect to app
    $location.path('/');
  }).catch(function(resp) {
    $location.path('/login')
    if(resp.reason!="unauthorized"){
      alert("Error");
      console.log(resp);
    }
  });

  $rootScope.$on('auth:login-error', function(ev, reason) {
    alert('auth failed because', reason.errors[0]);
  });

  $rootScope.$on('auth:oauth-registration', function(ev, user) {
    alert('new user registered through oauth:' + user.email);
  });

  $rootScope.$on('auth:logout-success', function(ev) {
    alert('goodbye');
    $location.search({});
  });

  $rootScope.$on('auth:session-expired', function(ev) {
    alert('Session has expired');
  });
}]);

app.controller('login', ['$scope', '$auth', '$location', function($scope,$auth,$location){
  $scope.authenticate = function(){
    alert($location.url());
    $auth.authenticate('github').then(function(resp) {
        $location.path('/');
      }).catch(function(resp) {
        alert("Error");
      });
  };
}]);


app.controller('app', ['$scope', '$auth', '$location', '$http', function($scope,$auth,$location,$http){
  $scope.$on('auth:validation-success', function(ev,user) {
    $scope.id = user.id;
    $scope.name = user.name;
    $scope.nickname = user.nickname;
    $scope.image = user.image;
  });

  $http.get(serverUrl+'/lists').then(function(resp) {
    $scope.lists = resp.data.lists;
    $scope.orders = resp.data.orders;
    console.log($scope.lists);

    $scope.ordered = [];
    $scope.orders.forEach(function(item){
      if(item.user_id==$scope.id) $scope.ordered.push(item.list_id);
    });
    console.log($scope.ordered);
  });

  //Add new list
  $scope.newlist = {};
  $scope.newlist.name = "";
  $scope.newlist.link = "";

  $scope.addList = function(){
    data = {
      name:  $scope.newlist.name,
      link:  $scope.newlist.link
    };

    $http.post(serverUrl+"/lists", JSON.stringify(data)).then(function success(resp) {
      $scope.lists.push({
        id: resp.data.id,
        name: $scope.newlist.name,
        link: $scope.newlist.link
      });

      $scope.newlist.name = "";
      $scope.newlist.link = "";

      alert("DODANO");
    }, function error(resp) {
      alert("ERROR");
      console.log(resp);
    });
  };

  $scope.neworder = [];
  $scope.orderform = [];
  $scope.initNewOrder = function(id){
    $scope.orderform[id] = {};
    $scope.neworder[id] = {};
    $scope.neworder[id].name="";
    $scope.neworder[id].price="";
  };

  $scope.addOrder = function(id,name,price){
    data = {
      list_id: id,
      name: name,
      price: price
    };

    $http.post(serverUrl+"/orders", JSON.stringify(data)).then(function success(resp) {
      console.log(resp);
      $scope.orders.push({
        id: resp.data.id,
        list_id: id,
        name: name,
        price: price
      });

      $scope.ordered.push(id);

      $scope.neworder[id].name="";
      $scope.neworder[id].price="";
      $scope.orderform[id].$setPristine();
      alert("Added!");
    }, function error(resp) {
      alert("error");
      console.log(resp);
    });
  }

  //Logout
  $scope.logout = function() {
    $auth.signOut().then(function(resp) {
      $location.path('/login');
    }).catch(function(resp) {
      alert("Error");
    });
  };
}]);
