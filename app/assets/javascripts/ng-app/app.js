'use strict';

angular
  .module('appModule', [
    'ngRoute',
    'templates',
    'Devise',
    'ngAnimate',
    'toastr',
    'mgo-angular-wizard',
    'angular-loading-bar',
    'UserModule',
    'DashboardModule',
    'AccountsModule'
  ]).config(function ($routeProvider, $locationProvider, AuthProvider, toastrConfig, $httpProvider) {

    angular.extend(toastrConfig, {
      autoDismiss: false,
      containerId: 'toast-container',
      maxOpened: 0,
      newestOnTop: true,
      positionClass: 'toast-bottom-right',
      preventDuplicates: false,
      preventOpenDuplicates: false,
      target: 'body'
    });

    $routeProvider
      .when('/', {
        templateUrl: 'home.html',
        controller: 'HomeController'
      })
      .when('/sign-up', {
        templateUrl: 'user/sign-up.html',
        controller: 'UserController'
      })
      .when('/login', {
        templateUrl: 'user/login.html',
        controller: 'UserController'
      })
      .when('/log-out', {
        templateUrl: 'user/login.html',
        controller: 'LogoutController'
      })
      .when('/forgot-password', {
        templateUrl: 'user/forgot-password.html',
        controller: 'UserController'
      })
      .when('/users/password/:id/change', {
        templateUrl: 'user/password.html',
        controller: 'PasswordsController',
        resolve: {
          password_token: function ($route) {
            return $route.current.params.id;
          }
        }
      });

    $httpProvider.defaults.withCredentials = true;

    $locationProvider.html5Mode({
      enabled: true,
      requireBase: false
    });
  });

