(function(){
  'use strict';

  angular.module('UserModule')
    .factory('UserService', function($http) {
      var service = {};

      $http.defaults.headers.common['Accept'] = 'application/json';

      service.getBankObjects= function (query) {
        return $http({url: '/banks', method: 'GET', params: {query: query}})
      };

      service.getBankLoginForm= function (id) {
        return $http({url: '/banks/login_requirement', method: 'GET', params: {id: id}})
      };

      service.loginBank= function (bank) {
        return $http({url: '/banks/login', method: 'POST', data: {bank: bank}})
      };

      service.mfaLogin= function (bank, mfa_response) {
        return $http({url: '/banks/login_mfa', method: 'POST', data: {bank: bank, mfa_response: mfa_response}})
      };

      return service;
  });
})();