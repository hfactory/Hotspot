angular.module('Hotspot').factory('datasetService', function($rootScope, $log, $q,
 Restangular, i18nService) {

  var service = {};
  service.data = _([]);
  var initialization = $q.defer();

  service.init = function() {
      $log.debug('Init datasetService');
      
      var validated = _([]);
      // Return the promise for chaining actions after the loading
      var promise;
      var Rest = Restangular.all('Dataset');

      promise = Rest.getList().then(function(responses) {
        $log.debug(responses.length+" dataset loaded");

        _.each(responses, function (response) {
           if(service.validate(response)) {
            validated.push(response);
           }
        });
        service.data = validated;
        $log.debug('datasetService initialized');
        initialization.resolve();
        return validated.value();
      });
    return promise;
  };

  service.whenReady = function(f) {
    initialization.promise.then(f).catch(function() {
      console.error("Error initializing datasetService");
    });
  }

  service.filter = function(f) {
      return service.data.filter(f).valueOf();
  };

  service.validate = function(value) {
      var validated = true;

      if(validated) {
        return validated;
      } else {
        $log.error("Invalid entry "+value);
        return false;
      }

  };

  service.groupBy = function() {
      return service.data.groupBy(function(obj) {
          return true;
      }).valueOf();
  };

  service.add = function(entity, control) {
      var result = Restangular.all('Dataset').post(entity).then(
      function() {
        control.message = "";
        // Reset successfully added entity
        entity = {};
        control.message = i18nService.entity("Dataset") + " saved";
        control.class = "text-success";
      }, function (resp) {
        // Set the error flag
        control.message = i18nService.entity("Dataset") + " not saved: '" + resp.data.error + "'";
        control.class = "text-error";
      });
  }

  return service;

})

angular.module('Hotspot')
  .controller('datasetCtrl', function ($scope, datasetService) {
    $scope.data = [];
    datasetService.whenReady(function() {
      $scope.data = datasetService.data.value();
    });
  });
