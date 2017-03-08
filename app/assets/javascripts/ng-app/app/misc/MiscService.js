(function(){
  'use strict';

  angular.module('appModule').factory('AuthService', function (Auth, $location, toastr){

    return {
      validate: function validate() {
        Auth.currentUser().then(function(user) {
          if (Auth._currentUser == undefined)
          {
            toastr.error("You are not allowed to access this page. Please login to continue.",'Error');
            $location.path("/");
            return false
          }
          else{
            return true
          }
        });

      }
    }
  });

})();