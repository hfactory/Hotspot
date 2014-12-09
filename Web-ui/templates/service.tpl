angular.module('${app}').factory('${entity}Service', function($rootScope, $log, $q, Restangular, i18nService) {

  var service = {};
  service.data = {};
  var initialization = $q.defer();

  service.init = function() {
      $log.debug('Init ${entity}Service');
      
      var Rest = Restangular.all('${entity}');

      Rest.getList().then(function(responses) {
      
        $log.debug(responses.length+" ${entity} loaded");

        var validated = _([]);
        _.each(responses, function (response) {
           if(service.validate(response)) {
            validated.push(response);
           }
        })
        
        service.data = validated;
        $log.debug('${entity}Service initialized');
        initialization.resolve();
      });

      
  };

  service.whenReady = function(f) {
    initialization.promise.then(f).catch(function() {
      console.error("Error initializing ${entity}Service");
    });
  }

  service.start = function() {
      $log.debug('${entity}Service started');
  };

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
      var result = Restangular.all('${entity}').post(entity).then(
      function() {
        control.message = "";
        // You can remove this line if you do not want a full reload of the entities from HBase
        service.init();
        // Reset successfully added entity
        entity = {};
        control.message = i18nService.entity("${entity}") + " saved";
        control.class = "text-success";
      }, function (resp) {
        // Set the error flag
        control.message = i18nService.entity("${entity}") + " not saved: '" + resp.data.error + "'";
        control.class = "text-error";
      });
  }

  return service;

})

angular.module('${app}')
  .controller('${entity}Ctrl', function ($scope, ${entity}Service) {
    $scope.data = ${entity}Service.data.value();
  });