(function(){
  'use strict';

  angular.module('DashboardModule')
    .factory('DashboardService', function($http) {
      var service = {};

      $http.defaults.headers.common['Accept'] = 'application/json';

      service.getAllTransactionData = function () {
        return $http.get('/transactions')
      };

      service.getDashboardStats= function (duration) {
        var days = duration || 30;
        return $http({url: '/transactions/dashboard/', method: 'GET', params: {days: days}})
      };

      service.getBalance= function (duration) {
        return $http({url: '/transactions/balance/', method: 'GET'})
      };

      return service;
    });
})();