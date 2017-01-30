angular.module('Hotspot').factory('i18nService', function($rootScope, $log, Restangular) {

  var service = {};

  service.data = {};

  service.load = function(LOCALE) {

  	  service.LOCALE = LOCALE

      $log.debug('Init i18nService with Locale '+ service.LOCALE);
      
      Restangular.one('_i18n', LOCALE).get().then(function(data) {
	    service.data = data;
	  })

      $log.debug('i18nService initialized');
  };

  service.key = function (key) {
  	var defined =  service.data.defined;
  	return defined[key];
  }

  service.entity = function (entity) {
  	var entities = service.data.entities;
  	return entities[entity].label;
  }

  service.field = function (entity, field) {
  	var entities = service.data.entities;
  	return entities[entity].fields[field];
  }

  // register to the main scope
  $rootScope.i18n = service;

  return service;

})