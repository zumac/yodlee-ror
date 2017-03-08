(function(){
  'use strict';

  angular.module('UserModule', ['templates', 'Devise', 'mgo-angular-wizard', 'toastr'])
    .controller('UserController', function ($scope, $q, $sce, $timeout, Auth, $location, WizardHandler, toastr, UserService) {
      $scope.is_mfa_enabled = 'false';
      $scope.user = {};
      $scope.banks = {};
      $scope.mfa_response = {};
      $scope.html = '';
      $scope.html_mfa = '';
      $scope.account = {};
      $scope.bank = {
        id: '1'
      };
      $scope.search;

      var bank = UserService.getBankObjects();
      bank.then(
        function(payload) {
          $scope.banks = payload.data.banks;
        },
        function(errorPayload) {
          $log.error('failure loading movie', errorPayload);
        }
      );

      $scope.bankSearch = function(queryText){
        var bank = UserService.getBankObjects(queryText);
        bank.then(
          function(payload) {
            $scope.banks = payload.data.banks;
            $scope.$apply();
          },
          function(errorPayload) {
            $log.error('failure loading movie', errorPayload);
          }
        );
      };

      $scope.bankLogin = function(bank){
        var bank = UserService.loginBank(bank);
        bank.then(
          function(payload) {
            if(payload.data.status == 'true'){
              if(payload.data.result.mfa == 'true'){
                $scope.bank = {};
                $scope.bank.item_id = payload.data.result.item_id;
                $scope.html_mfa = payload.data.result.html;
                $scope.is_mfa_enabled = 'true';
                $scope.mfa_response = payload.data.result.response;
                console.log($scope.mfa_response);
                var deferred = $q.defer();

                setTimeout(function() {
                  // since this fn executes async in a future turn of the event loop, we need to wrap
                  // our code into an $apply call so that the model changes are properly observed.
                  $scope.$apply(function() {
                    $scope.is_mfa_enabled = 'true';
                  });
                }, 1000);

                deferred.promise;
                var deferred = $q.defer();

                setTimeout(function() {
                  // since this fn executes async in a future turn of the event loop, we need to wrap
                  // our code into an $apply call so that the model changes are properly observed.
                  $scope.$apply(function() {
                    WizardHandler.wizard().next();
                  });
                }, 1000);
                deferred.promise;

              } else {
                $location.path("/dashboard");
              }
            } else {
              toastr.error('Some error while creating your account', 'Error');
            }

          },
          function(errorPayload) {
            $log.error('failure loading movie', errorPayload);
          }
        );

      };

      $scope.mfaLogin = function(bank){
        console.log($scope.mfa_response);
        var mfa = UserService.mfaLogin(bank, $scope.mfa_response);
        mfa.then(
          function(payload) {
            if(payload.data.status == 'true'){
              $location.path("/dashboard");
            }

          },
          function(errorPayload) {
            $log.error('failure loading movie', errorPayload);
          }
        );

      };

      $scope.accountValidation = function(){
        var d = $q.defer();
        $timeout(function(){
          if($scope.user.email && $scope.user.password && $scope.user.password_confirmation && $scope.user.first_name && $scope.user.last_name && $scope.user.phone && $scope.user.email.length > 1 && $scope.user.password.length > 1 && $scope.user.password_confirmation.length > 1 && $scope.user.first_name.length > 1 && $scope.user.last_name.length > 1 && $scope.user.phone.length > 1){
            Auth.register($scope.user).then(function(registeredUser) {
              if(registeredUser.status == 'false'){
                toastr.error(registeredUser.error.message, 'Error');
                return d.resolve(false);
              } else {
                Auth.login($scope.user);
                toastr.info('Account Created Successfully', 'Info');
                return d.resolve(true);
              }

            }, function(error) {
              return d.resolve(false);
            });

          } else {
            toastr.error('Enter valid inputs in all the fields', 'Error');
            return d.resolve(false);
          }
        }, 2000);
        return d.promise;
      };

      $scope.getBankLoginDetails = function(selectedBank){
        var bank = UserService.getBankLoginForm(selectedBank);
        bank.then(
          function(payload) {
            $scope.html = payload.data.form;
            WizardHandler.wizard().next();
          },
          function(errorPayload) {
            $log.error('failure loading movie', errorPayload);
          }
        );
      };

      $scope.signin = function() {
        Auth.login($scope.user).then(function(user) {

          if(user.status == 'false'){
            toastr.error(user.error.message, 'Error');
          }else{
              $location.path("/dashboard");
          }
        }, function(error) {
          toastr.error('Invalid Login Credentials', 'Error');
        });
      };

      $scope.forgotpassword = function() {
        Auth.sendResetPasswordInstructions($scope.user).then(function() {
          toastr.info('Password Reset Instructions Sent', 'Info');
        });
      };

    })
    .directive('dynamic', function ($compile) {
      return {
        restrict: 'A',
        replace: true,
        link: function ($scope, ele, attrs) {
          $scope.$watch(attrs.dynamic, function(html) {
            ele.html(html);
            $compile(ele.contents())($scope);
          });
        }
      };
    })

    .controller('LogoutController', function ($scope, Auth, $location) {
      var config = {
        headers: {
          'X-HTTP-Method-Override': 'DELETE'
        }
      };

      Auth.logout(config).then(function(oldUser) {
        $location.path("/login");
      }, function(error) {
      });
    })

    .controller('PasswordsController', function ($scope, Auth, $location, toastr, password_token) {

      $scope.user = {};
      $scope.user.reset_password_token = password_token;

      $scope.changePassword = function() {
        Auth.resetPassword($scope.user).then(function(response) {
          if(response.status == 'false'){
            toastr.error(response.error.message, 'Error');
          }else{
            toastr.info('Password Changed Successfully', 'Info');
            $location.path("/login");
          }

        }, function(error) {

        });
      };

    });

})();