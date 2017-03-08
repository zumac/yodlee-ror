(function(){
  'use strict';

  angular.module('appModule')
    .controller('SidebarController', function($scope, $location) {

      $scope.isActive = function (viewLocation) {
        if($location.path().indexOf(viewLocation) > -1){
          return true;
        } else {
          return false
        }
      };
    });
  angular.module('appModule').factory('AuthService', ['Auth', '$location', 'logger',
    function (Auth, $location, logger){

      return {
        validate: function validate() {
          if (Auth._currentUser == undefined)
          {
            logger.logError("You are not allowed to access this page. Please login to continue.");
            $location.path("/");
            return false
          }
          else{
            return true
          }
        }
      }
    }
  ]);

})();