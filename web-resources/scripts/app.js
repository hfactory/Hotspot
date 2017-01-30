'use strict';

angular.module('Hotspot', [
  'restangular',
  'ngRoute',
  'ui.router'
])

.config(function(RestangularProvider) {
  RestangularProvider.setBaseUrl('/Hotspot/');
})

.factory('loadingService', function($log, entitiesService, datasetService, hotspotService) {

  var service = {};
  service.services = _([entitiesService , datasetService, hotspotService]);

  service.start = function () {
    $log.debug('Starting loadingService');
    service.services.each(function (service) {
      service.init();
    })
  }

  return service;

})

.run( function($log, $locale, i18nService, loadingService, Restangular) {

  console.log('Starting ...');
  
  i18nService.load($locale.id.slice(0,2));
  loadingService.start();
  
});