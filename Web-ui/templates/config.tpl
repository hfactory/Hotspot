'use strict';

angular.module('${app}')
.config(function ($stateProvider, $urlRouterProvider) {
    
  $urlRouterProvider.otherwise("/map");
  
  var map = {
      name: 'map',
      url: "/map",
      templateUrl: "views/map.html",
      controller: function($scope, $http, entitiesService, hotspotService) {
      
        var orange = '#ffcc33',
            violet = '#c900ff',
            red    = '#ff0000';
        var hotspotStyle = new ol.style.Style({
            image: new ol.style.Circle({
                radius: 5,
                fill: new ol.style.Fill({
                    color: violet
                }),
                stroke: new ol.style.Stroke({
                    color: '#ffffff',
                    width: 2
                })
            })
        });

        var positionStyle = new ol.style.Style({
            image: new ol.style.Circle({
                radius: 7,
                fill: new ol.style.Fill({
                    color: red
                }),
                stroke: new ol.style.Stroke({
                    color: '#ffffff',
                    width: 2
                })
            })
        });

        function makePoint(lng, lat) {
            return new ol.geom.Point(ol.proj.transform([lng, lat], 'EPSG:4326', 'EPSG:3857'));
        }
        
        // Add a hotspot as returned by the server.
        function addHotspot(hotspot) {
            var h = new ol.Feature({
                geometry: makePoint(hotspot.longitude, hotspot.latitude),
                name: hotspot.name
            });
            hotspotSource.addFeature(h);
        }
        
        var getAllHotspots = function() {
            hotspotService.whenReady(function() {
                var data = hotspotService.data.value();
                _.forEach(data, function(item) {
                    addHotspot(item.fields);
                });
            });
        }

        function getClosest(lng, lat, count) {
            var url = "getClosest?lat=" + lat + "&long=" + lng + "&count=" + count;
            $http.get(url).success(
              function(data) {
                hotspotSource.clear();
                _.forEach(data, function (hotspot) {
                    addHotspot(hotspot);
                });
              }
            );
        }
        
        var updateClosest = function() {
            getClosest(currentLng, currentLat, $scope.currentCount);
        }
        
        var hotspotSource = new ol.source.Vector();
        var positionSource = new ol.source.Vector();
        
        var hotspotLayer = new ol.layer.Vector({
            source: hotspotSource,
            style: hotspotStyle
        });
        
        var positionLayer = new ol.layer.Vector({
            source: positionSource
            //style: positionStyle
        });
        
        var planLayer = new ol.layer.Tile({
            source: new ol.source.MapQuest({ layer: 'osm' })
        });
        
        // Center of our map: Paris.
        var parisLng = 2.3488000,
            parisLat = 48.8534100;
        
        var currentLng   = parisLng,
            currentLat   = parisLat;
        $scope.currentCount = 10;
        
        var map = new ol.Map({
            target: 'map',
            layers: [ planLayer, hotspotLayer, positionLayer ],
            view: new ol.View({
                center: ol.proj.transform([parisLng, parisLat], 'EPSG:4326', 'EPSG:3857'),
                zoom: 13
            })
        });
        
        var positionFeature = null;
        
        function updatePosition(lng, lat) {
            if (positionFeature) {
                positionSource.removeFeature(positionFeature);
            }
            positionFeature = new ol.Feature({
                geometry: makePoint(lng, lat),
                name: "Current Position"
            });
            positionFeature.setStyle(positionStyle);
            positionSource.addFeature(positionFeature);
        }
        
        $scope.mapClicked = function(ev) {
            var loc = map.getEventCoordinate(ev),
                lng_lat = ol.proj.transform(loc, 'EPSG:3857', 'EPSG:4326');
            currentLng = lng_lat[0];
            currentLat = lng_lat[1];
            updatePosition(currentLng, currentLat);
            getClosest(currentLng, currentLat, $scope.currentCount);
        }

        $scope.submit = function (ev) {
          ev.preventDefault();
          var count = $("#count").val();
          if (count > 0) {
            $scope.currentCount = count;
            updateClosest();
          }
        };

        updatePosition(currentLng, currentLat);
        getAllHotspots();
      }
  }
  $stateProvider
    .state(map);
  
  <#list entities as entity> 
  var ${entity}List = { 
      name: '${entity}',
      url: "/${entity}",
      templateUrl: "views/list.html",
      controller: function($scope, entitiesService, ${entity}Service) {
          
        $scope.data = ${entity}Service.data.value();
        var ref = entitiesService.data['${entity}'];
        $scope.reference = ref;

      }
  }

  var ${entity}Add = { 
      name: '${entity}_add',
      url: "/${entity}/add",
      templateUrl: "views/add.html",
      controller: function($scope, entitiesService, ${entity}Service) {
          
        $scope.data = ${entity}Service.data.value();
        var ref = entitiesService.data['${entity}'];
        $scope.reference = ref;
        $scope.entity = {};
        $scope.error = { class:"text-info" };
        $scope.add = ${entity}Service.add;

      }
  }

  var ${entity}Chart = { 
      name: '${entity}_chart',
      url: "/${entity}/chart",
      templateUrl: "views/chart.html",
      controller: function($scope, entitiesService, ${entity}Service) {

        
        $scope.$watch('field', function(nv, ov) {
          if(nv) {
            var grouped = _.groupBy(_.map(${entity}Service.data.value(), "fields"), nv.name.toString());
            var presentation = _.transform(grouped, function(result, value, key) {
              result[key] = {
                    id: key,
                    count: _.size(value)
                };
            });
            $scope.chartData = _.map(presentation, function(c) {
              return c;
            });
          }
        });

        $scope.reference = entitiesService.data['${entity}'];

        $scope.idFunction = function(){
            return function(d) {
                return d.id;
            };
        }
        $scope.countFunction = function(){
            return function(d) {
                return d.count;
            };
        }

        $scope.toolTipContentFunction = function(){
            return function(key, x, y, e, graph) {
                return  '<h3>' + key + ' has ' + y.point.count + ' items</h3>';
            }
        }
    }
  }

  $stateProvider
    .state(${entity}List)
    .state(${entity}Chart)
    .state(${entity}Add);
    
 </#list>

}).directive('ngRightClick', function() {
    return function(scope, element) {
        element.bind('contextmenu', function(event) {
            scope.$apply(function() {
                event = event || window.event;
                if (event.preventDefault) {
                  event.preventDefault();
                } else {
                  return false; // For IE browsers.
                }
            });
        });
    };
});;
