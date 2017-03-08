(function(){
  'use strict';

  angular.module('DashboardModule', ['ngResource', 'ngRoute', 'templates', 'Devise', 'ngTable', 'chart.js', 'angular-underscore', 'ngSanitize'])
    .config(function ($routeProvider, ChartJsProvider) {
      $routeProvider
        .when('/dashboard', {
          templateUrl: 'dashboard/index.html',
          controller: 'DashboardController'
        });
      // Configure all charts
      ChartJsProvider.setOptions({
        responsive: true,
        scales: {
          yAxes: [{
            display: true,
            ticks: {
              userCallback: function(label, index){
                return  ' £ ' + label.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
              }
            }
          }],
          xAxes:[{
            position: "bottom",
            type: "time",
            ticks: {
              maxRotation: 20
            },
            time: {
              // string/callback - By default, date objects are expected. You may use a pattern string from http://momentjs.com/docs/#/parsing/string-format/ to parse a time string format, or use a callback function that is passed the label, and must return a moment() instance.
              parser: false,
                // string - By default, unit will automatically be detected.  Override with 'week', 'month', 'year', etc. (see supported time measurements)
              unit: false,

              // Number - The number of steps of the above unit between ticks
              unitStepSize: 1,

              // string - By default, no rounding is applied.  To round, set to a supported time unit eg. 'week', 'month', 'year', etc.
              round: false,

              // Moment js for each of the units. Replaces `displayFormat`
              // To override, use a pattern string from http://momentjs.com/docs/#/displaying/format/
              tooltipFormat: ''
            }
          }]
        },
        legend: {
          display: false
        },
        tooltips: {
          callbacks: {
            label: function(tooltipItem, data) { return ' £ ' + tooltipItem.yLabel.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","); }
          }
        }
      });

    })
    .controller('DashboardController', function ($scope, AuthService, NgTableParams, DashboardService) {

      $scope.colours = ['#FFFFFF'];
      $scope.labels = ['Running Account Balance'];
      $scope.data = [];
      $scope.bank = {};
      $scope.stats = {};
      $scope.balance = 0;
      $scope.graphDuration = [
        { id: 7, name: '7 DAYS' },
        { id: 30, name: '30 DAYS' },
        { id: 60, name: '60 DAYS' },
        { id: 90, name: '90 DAYS' },
        { id: 180, name: '180 DAYS' },
        { id: 5000, name: 'ALL TIME' }
      ];
      $scope.selectedItem = $scope.graphDuration[1];
      AuthService.validate();

      var balance = DashboardService.getBalance();
      balance.then(
        function(payload) {
          $scope.balance = payload.data.balance;
        },
        function(errorPayload) {
          $log.error('failure loading movie', errorPayload);
        }
      );


      var stats = DashboardService.getDashboardStats();
      stats.then(
        function(payload) {
          $scope.labels = _.pluck(payload.data.statistics.chart, 'date');
          $scope.data = [ _.pluck(payload.data.statistics.chart, 'amount')];
          $scope.stats = payload.data.statistics;
        },
        function(errorPayload) {
          $log.error('failure loading movie', errorPayload);
        }
      );

      $scope.changeGraph = function(durationObject){
        var stats = DashboardService.getDashboardStats(durationObject.id);
        stats.then(
          function(payload) {
            $scope.labels = _.pluck(payload.data.statistics.chart, 'date');
            $scope.data = [ _.pluck(payload.data.statistics.chart, 'amount')];
            $scope.stats = payload.data.statistics;
          },
          function(errorPayload) {
            $log.error('failure loading movie', errorPayload);
          }
        );
      };

      var data = DashboardService.getAllTransactionData();
      data.then(
        function(payload) {
          $scope.bank = payload.data.bank;
          $scope.tableParams = new NgTableParams({ sorting: { post_date: 'desc'}, count: 10}, { counts: [10, 25, 50], dataset: payload.data.transactions});
        },
        function(errorPayload) {
          $log.error('failure loading movie', errorPayload);
        }
      );
    })
    .directive('bankDetails', function() {
      return {
        scope: {
          id: "&accountId",
          bank: "&bankObj"
        },
        template: "<img src=data:image/png;base64,{{image}}></img>",
        link: function (scope, iElm, iAttrs) {
          _.each(scope.bank(), function(object){
            var result = _.find(object.account, function(num){ return num == scope.id(); });
            if(result){
              scope.image = object.image;
            }
          })
        }
      };
    });

  angular.module('ngTable').run(['$templateCache', function ($templateCache) {
    $templateCache.put('ng-table/pager.html', '<div class="ng-cloak ng-table-pager" ng-if="params.data.length"> <div ng-if="params.settings().counts.length" class="ng-table-counts btn-group pull-right"> <select ng-options="count as count for count in params.settings().counts" ng-model="selectedItem" ng-change="params.count(selectedItem)" class="form-control"><option value="">Show</option></select></div> <div class="col-md-offset-4 col-sm-offset-3"> <ul ng-if="pages.length" class="pagination"> <li ng-class="{\'disabled\': !page.active && !page.current, \'active\': page.current}" ng-repeat="page in pages" ng-switch="page.type"> <a ng-switch-when="prev" ng-click="params.page(page.number)" href="">PREV</a> <a ng-switch-when="first" ng-click="params.page(page.number)" href=""><span ng-bind="page.number"></span></a> <a ng-switch-when="page" ng-click="params.page(page.number)" href=""><span ng-bind="page.number"></span></a> <a ng-switch-when="more" ng-click="params.page(page.number)" href="">&#8230;</a> <a ng-switch-when="last" ng-click="params.page(page.number)" href=""><span ng-bind="page.number"></span></a> <a ng-switch-when="next" ng-click="params.page(page.number)" href="">NEXT</a> </li> </ul></div> </div>');
  }]);

})();