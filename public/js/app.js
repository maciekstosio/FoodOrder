var app = angular.module('FoodOrder', ['ngRoute','ng-token-auth']);
// var serverUrl = "http://localhost:3000"; //development
var serverUrl = "http://foodorderappbeta.herokuapp.com"; //production

/*
*HELPERS
*/

function error_notification(text){
  UIkit.notification(text , {
    status: 'danger',
    pos: 'top-right'
  });
}

function success_notification(text){
  UIkit.notification(text , {
    status: 'success',
    pos: 'top-right'
  });
}

/*
* CONFIG
*/

app.config(function($authProvider,$routeProvider,$locationProvider){
  //Authorization
  $authProvider.configure({
		apiUrl: serverUrl,
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

/*
* HOME (Login) PAGE
*/

app.controller('login', ['$scope', '$auth', '$location', function($scope,$auth,$location){
  $auth.validateUser().then(function(resp) {
    window.location  = '/'; //Use instead $location.path() to get rid of auth params
  });

  $scope.authenticate = function(){
    $auth.authenticate('github'); //We don't use callbacks because we never reach them
  };
}]);

/*
* APP MAIN CONTROLLER
*/

app.controller('app', ['$scope', '$auth', '$location', '$http', function($scope,$auth,$location,$http){
  $auth.validateUser().then(function(resp) {
    $scope.id = resp.id;
    $scope.name = resp.name;
    $scope.nickname = resp.nickname;
    $scope.image = resp.image;

    //Load lists and orders
    $http.get(serverUrl+'/lists').then(function(resp) {
      console.log(resp);
      $scope.lists = resp.data.lists;
      $scope.orders = resp.data.orders;

      $scope.ordered = [];
      $scope.orders.forEach(function(item){
        if(item.user_id==$scope.id) $scope.ordered.push(item.list_id);
      });
      $("#loading").fadeOut(1000);
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
      $scope.lists.unshift({
        id: resp.data.id,
        user_id: $scope.id,
        state: 0,
        name: $scope.newlist.name,
        link: $scope.newlist.link
      });

      $scope.newlist.name = "";
      $scope.newlist.link = "";

      //Notification
      resp.data.messages.forEach(function(val){
        success_notification(val);
      });
    }, function error(resp) {
      //Notification
      resp.data.messages.forEach(function(val){
        error_notification(val);
      });
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

      //Notification
      resp.data.messages.forEach(function(val){
        success_notification(val);
      });
    }, function error(resp) {
      $scope.liststate[id] = $scope.lists.find(function (e) { return e.id == id; }).state;

      //Notification
      resp.data.messages.forEach(function(val){
        error_notification(val);
      });
      console.log(resp);
    });
  };

  //Delete list
  $scope.deletelist = function(id){
    $http.delete(serverUrl+"/lists/"+id).then(function success(resp) {
      console.log(resp);
      for(var i=0; i < $scope.lists.length; i++){
        if($scope.lists[i].id == id){
          $scope.lists.splice(i,1);
          break;
        }
      }

      //Notification
      resp.data.messages.forEach(function(val){
        success_notification(val);
      });
    }, function error(resp) {
      console.log(resp);
      //Notification
      resp.data.messages.forEach(function(val){
        error_notification(val);
      });
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
        user_id: $scope.id,
        name: name,
        price: price,
        username: $scope.name,
        usernickname: $scope.nickname,
        userimage: $scope.image
      });

      $scope.ordered.push(id);

      $scope.neworder[id].name="";
      $scope.neworder[id].price="";
      $scope.orderform[id].$setPristine(); //To hide preview

      //Notification
      resp.data.messages.forEach(function(val){
        success_notification(val);
      });
    }, function error(resp) {
      //Notification
      resp.data.messages.forEach(function(val){
        error_notification(val);
      });
      console.log(resp);
    });
  }

  $scope.deleteorder = function(list_id,id){
    $http.delete(serverUrl+"/lists/"+list_id+"/orders/"+id).then(function success(resp) {
      console.log(resp);

      //Remove order
      for(var i=0; i < $scope.orders.length; i++){
        if($scope.orders[i].id == id){
          $scope.orders.splice(i,1);
          break;
        }
      }

      //Allow user to order new thing
      for(var i=0; i < $scope.ordered.length; i++){
        if($scope.ordered[i] == list_id){
          $scope.ordered.splice(i,1);
          break;
        }
      }

      //Notification
      resp.data.messages.forEach(function(val){
        success_notification(val);
      });
    }, function error(resp) {
      console.log(resp);
      //Notification
      resp.data.messages.forEach(function(val){
        error_notification(val);
      });
    });
  };

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
      $location.path('/login');
    });
  };
}]);
