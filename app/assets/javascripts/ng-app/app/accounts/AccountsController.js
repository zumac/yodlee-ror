(function(){
  'use strict';

  angular.module('AccountsModule', ['ngResource', 'ngRoute', 'templates', 'Devise','rorymadden.date-dropdowns'])
    .config(function ($routeProvider) {
      $routeProvider
        .when('/accounts/linked', {
          templateUrl: 'accounts/index.html',
          controller: 'AccountsController'
        })
        .when('/accounts/linked/add', {
          templateUrl: 'accounts/add.html',
          controller: 'AddAccountController'
        })
        .when('/accounts/user/settings', {
          templateUrl: 'accounts/user.html',
          controller: 'UserAccountController'
        })
        .when('/accounts/user/update-password', {
          templateUrl: 'accounts/update_password.html',
          controller: 'UserAccountController'
        });
    })
    .controller('AccountsController', function ($scope, AccountsService, AuthService) {
      $scope.banks = {};
      AuthService.validate();

      var account = AccountsService.getAllAccounts();
      account.then(
        function(payload) {
          $scope.banks = payload.data.bank;
          $scope.$apply();
        },
        function(errorPayload) {
          $log.error('Error loading data.', errorPayload);
        }
      );

      $scope.refresh = function (objectParams) {
        AccountsService.refreshAccount(objectParams.account_id);
      };

      $scope.refreshAll = function () {
        AccountsService.refreshAllAccount();
      };

      $scope.delete = function (objectParams) {
        var account = AccountsService.deleteAccount(objectParams.account_id);
        account.then(
          function(payload) {
            $scope.banks = payload.data.bank;
            $scope.$apply();
          },
          function(errorPayload) {
            $log.error('Error loading data.', errorPayload);
          }
        );
      };
    })
    .controller('AddAccountController', function ($scope,  AuthService, AccountsService, UserService) {
      $scope.banks = {};
      AuthService.validate();
      var bank = UserService.getBankObjects();
      bank.then(
        function(payload) {
          $scope.banks = payload.data.banks;
        },
        function(errorPayload) {
          $log.error('Error loading data.', errorPayload);
        }
      );
    })
    .controller('UserAccountController', function ($scope, $location, Auth, AuthService, $http, toastr) {
      $scope.user = {};
      AuthService.validate();
      Auth.currentUser().then(function(user) {
        $scope.user = Auth._currentUser
      });

      $scope.update = function (objectParams) {
        $http.put('/users.json', {
          user: $scope.user
        }).
          success(function(response, status, headers, config) {
            if(response.status == 'false'){
              toastr.error(response.error.message, 'Error');
            }else{
              toastr.info('Profile Updated', 'Info');
            }
          })
      };
    })

    .directive('bankImage', function() {
      return {
        scope: {
          bank: "&bankObj"
        },
        template: "<img class='bank-img' src=data:image/png;base64,{{image}}></img>",
        link: function (scope, iElm, iAttrs) {
          scope.image = scope.bank().image;
        }
      };
    });

})();