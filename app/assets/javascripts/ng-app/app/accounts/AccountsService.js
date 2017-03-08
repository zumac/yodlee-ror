(function(){
  'use strict';

  angular.module('AccountsModule')
    .factory('AccountsService', function($http) {
      var service = {};

      $http.defaults.headers.common['Accept'] = 'application/json';

      service.getAllAccounts = function () {
        return $http.get('/accounts')
      };

      service.refreshAccount = function (params) {
        return $http({url: '/accounts/refresh', method: 'POST', data: {id: params}})
      };

      service.refreshAllAccount = function (params) {
        return $http({url: '/accounts/refresh_all', method: 'POST'})
      };

      service.deleteAccount = function (params) {
        return $http({url: '/accounts/delete', method: 'POST', data: {id: params}})
      };

      return service;
    });
})();