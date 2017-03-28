'use strict';

angular.module('appModule')
  .config(function ($routeProvider) {
    $routeProvider
      .when('/pages/terms-and-conditions', {
        templateUrl: 'pages/terms-and-conditions.html',
        controller: 'HomeController'
      })
      .when('/pages/privacy-policy', {
        templateUrl: 'pages/privacy-policy.html',
        controller: 'HomeController'
      });
  })
  .controller('HomeController', function ($scope, Auth) {
    $scope.user;
    Auth.currentUser().then(function(user) {
      if (Auth._currentUser == undefined)
      {
        $scope.user = false;
      }
      else{
        $scope.user = true;
      }
    }, function(error) {
      $scope.user = false;
    });

  });