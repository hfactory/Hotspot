angular.module('Hotspot').factory('hotspotService', function($rootScope, $log, $q,
 datasetService,
 Restangular, i18nService) {

  var service = {};
  service.data = _([]);
  var initialization = $q.defer();

  service.init = function() {
      $log.debug('Init hotspotService');
      // Do not use whenReady for hotspot since the loading is not done during initialization
      initialization.resolve();
  };

  service.initData = function(datasetName) {
      
      var validated = _([]);
      // Return the promise for chaining actions after the loading
      var promise;
      if(datasetName) {
        var Rest = Restangular.all('filteredHotspot?datasetName='+datasetName);

      promise = Rest.getList().then(function(responses) {
        $log.debug(responses.length+" hotspot loaded");

        _.each(responses, function (response) {
           if(service.validate(response)) {
            validated.push(response);
           }
        });
        service.data = validated;
        $log.debug('hotspotService initialized');
        initialization.resolve();
        return validated.value();
      });
    }
    return promise;
  };

  service.whenReady = function(f) {
    initialization.promise.then(f).catch(function() {
      console.error("Error initializing hotspotService");
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
      var result = Restangular.all('Hotspot').post(entity).then(
      function() {
        control.message = "";
        // Reset successfully added entity
        entity = {};
        control.message = i18nService.entity("Hotspot") + " saved";
        control.class = "text-success";
      }, function (resp) {
        // Set the error flag
        control.message = i18nService.entity("Hotspot") + " not saved: '" + resp.data.error + "'";
        control.class = "text-error";
      });
  }

  return service;

})

angular.module('Hotspot')
  .controller('hotspotCtrl', function ($scope, hotspotService) {
    $scope.data = [];
    hotspotService.whenReady(function() {
      $scope.data = hotspotService.data.value();
    });
  });
