angular.module('${app}').factory('${entity}Service', function($rootScope, $log, $q,
<#if entity == "hotspot">
 datasetService,
</#if> Restangular, i18nService) {

  var service = {};
  service.data = _([]);
  var initialization = $q.defer();

<#if entity == "hotspot">
  service.init = function() {
      $log.debug('Init ${entity}Service');
      // Do not use whenReady for hotspot since the loading is not done during initialization
      initialization.resolve();
  };

  service.initData = function(datasetName) {
<#else>
  service.init = function() {
      $log.debug('Init ${entity}Service');
</#if>
      
      var validated = _([]);
      // Return the promise for chaining actions after the loading
      var promise;
<#if entity == "hotspot">
      if(datasetName) {
        var Rest = Restangular.all('filteredHotspot?datasetName='+datasetName);
<#else>
      var Rest = Restangular.all('${entity}');
</#if>

      promise = Rest.getList().then(function(responses) {
        $log.debug(responses.length+" ${entity} loaded");

        _.each(responses, function (response) {
           if(service.validate(response)) {
            validated.push(response);
           }
        });
        service.data = validated;
        $log.debug('${entity}Service initialized');
        initialization.resolve();
        return validated.value();
      });
<#if entity == "hotspot">
    }
</#if>
    return promise;
  };

  service.whenReady = function(f) {
    initialization.promise.then(f).catch(function() {
      console.error("Error initializing ${entity}Service");
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
      var result = Restangular.all('${entity}').post(entity).then(
      function() {
        control.message = "";
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
    $scope.data = [];
    ${entity}Service.whenReady(function() {
      $scope.data = ${entity}Service.data.value();
    });
  });