var app = angular.module('FoodOrder', ['ngRoute','ng-token-auth']);
var serverUrl = "http://localhost:3000";

app.config(function($authProvider,$routeProvider,$locationProvider){
  //Authorization
  $authProvider.configure({
		apiUrl: 'http://localhost:3000',
    authProviderPaths: {
      github: '/auth/github'
    }
	});

  //Routes
  $routeProvider.when("/", {
    templateUrl : "views/app.html",
    controller : "app"
  }).when("/login", {
    templateUrl : "views/login.html",
    controller : "login"
  });
});

app.controller('login', ['$scope', '$auth', '$location', function($scope,$auth,$location){
  $auth.validateUser().then(function(resp) {
    window.location  = '/'; //Use instead $location.path() to get rid of auth params
  });

  $scope.authenticate = function(){
    $auth.authenticate('github'); //We don't use callbacks because we never reach them
  };
}]);


app.controller('app', ['$scope', '$auth', '$location', '$http', function($scope,$auth,$location,$http){
  $auth.validateUser().then(function(resp) {
    $scope.id = resp.id;
    $scope.name = resp.name;
    $scope.nickname = resp.nickname;
    $scope.image = resp.image;

    //Load lists and orders
    $http.get(serverUrl+'/lists').then(function(resp) {
      $scope.lists = resp.data.lists;
      $scope.orders = resp.data.orders;

      $scope.ordered = [];
      $scope.orders.forEach(function(item){
        if(item.user_id==$scope.id) $scope.ordered.push(item.list_id);
      });
    });
  }).catch(function(resp) {
    $location.path('/login');
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
        user_id: $scope.id,
        state: 0,
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

  //Change list status
  $scope.states = ["In progress", "Finalized", "Ordered", "Delivered"];
  $scope.liststate = [];

  $scope.changestate = function(id){
    data = {
      state: $scope.liststate[id]
    };

    $http.put(serverUrl+"/lists/"+id, JSON.stringify(data)).then(function success(resp) {
      console.log(resp);
      $scope.lists.find(function (e) { return e.id == id; }).state = $scope.liststate[id];
      alert("Changed");
    }, function error(resp) {
      $scope.liststate[id] = $scope.lists.find(function (e) { return e.id == id; }).state;
      alert("error");
      console.log(resp);
    });
  };

  //Delete list status
  $scope.deletelist = function(id){
    $http.delete(serverUrl+"/lists/"+id).then(function success(resp) {
      console.log(resp);
      for(var i=0; i < $scope.lists.length; i++){
        if($scope.lists[i].id == id){
          $scope.lists.splice(i,1);
          break;
        }
      }
      alert("Deleted");
    }, function error(resp) {
      console.log(resp);
      alert("error");
    });
  };

  //Add new order
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
      $scope.orderform[id].$setPristine(); //To hide preview
      alert("Added!");
    }, function error(resp) {
      alert("error");
      console.log(resp);
    });
  }

  //Some helpers
  $scope.hasElementWithListID = function(array,id){
    if(array.filter(function(e){ return e.list_id == id}).length>0) return true;
    return false;
  }
  //Logout
  $scope.logout = function() {
    $auth.signOut().then(function(resp) {
      $location.path('/login');
    }).catch(function(resp) {
      alert("Error");
      $location.path('/login');
    });
  };
}]);
