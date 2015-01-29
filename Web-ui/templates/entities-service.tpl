angular.module('${app}').factory('entitiesService', function($rootScope, $log, Restangular) {

  var service = {};

  service.data = {};

  service.init = function() {
      $log.debug('Init entitiesService');
      
      var Rest = Restangular.all('_entities');

      Rest.getList().then(function(responses) {
      
        $log.debug(responses.length+" entities loaded");

        var validated 
        _.each(responses, function (response) {
           $log.debug('Registering entity '+response.entity);
           service.data[response.entity] = response;
        })
      });

      $log.debug('entitiesService initialized');
  };

  return service;

})

angular.module('${app}')
  .controller('entitiesCtrl', function ($scope, entitiesService) {
    $scope.entities = entitiesService.data;
  });