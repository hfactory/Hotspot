'use strict';

angular.module('${app}', [
  'restangular',
  'ngRoute',
  'ui.router'
])

.config(function(RestangularProvider) {
  RestangularProvider.setBaseUrl('/${app}/');
})

.factory('loadingService', function($rootScope, $log, entitiesService, ${entities_services}) {

  var service = {};
  service.services = _([entitiesService , ${entities_services}]);

  service.start = function () {
    $log.debug('Starting loadingService');
    service.services.each(function (service) {
      service.init();
    })
  }

  return service;

})

.run( function( $rootScope, $log, $locale, i18nService, loadingService, Restangular) {

  console.log('Starting ...');
  
  i18nService.load($locale.id.slice(0,2));
  loadingService.start();
  
});