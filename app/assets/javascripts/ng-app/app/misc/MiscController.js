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

})();