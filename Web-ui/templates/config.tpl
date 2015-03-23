'use strict';

angular.module('${app}')
.config(function ($stateProvider, $urlRouterProvider) {
    
  $urlRouterProvider.otherwise("/map");
  
  var map = {
      name: 'map',
      url: "/map",
      templateUrl: "views/map.html",
      controller: function($scope, $http, entitiesService, datasetService, hotspotService) {
        $scope.datasetName = "Load data from Menu";
        $scope.closests = null;
        $scope.hotspotRef = entitiesService.data['hotspot'];
        
      	$scope.loadData = function(set) {
          hotspotSource.clear();
      	  if (set) {
      	    // Update map : center on dataset provided location
      	    currentLng = set.fields.longitude;
            currentLat = set.fields.latitude;
      	    map.getView().setZoom(13);
            map.getView().setCenter(ol.proj.transform([currentLng, currentLat], 'EPSG:4326', 'EPSG:3857'));
            updateSelectedPosition(currentLng, currentLat);
            
      	    $scope.datasetName = set.fields.name;
            var promise = hotspotService.initData(set.fields.name);
            promise.then(function(data) {
              addAllHotspots(data);
            });
      	  }
      	};      

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

        var selectedPositionStyle = new ol.style.Style({
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
        
        var userPositionStyle = new ol.style.Style({
            image: new ol.style.Circle({
                radius: 7,
                fill: new ol.style.Fill({
                    color: orange
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
        
        var addAllHotspots = function(data) {
            $scope.closests = null;
            _.forEach(data, function(item) {
                addHotspot(item.fields);
            });
        }

        function getClosest(dataset, lng, lat, count) {
            // Variable used for displaying the list of closests points
            $scope.closests = {"points": [], "fieldNames": ["name", "address", "town"]};
            var url = "getClosest?datasetName=" + dataset + "&lat=" + lat + "&long=" + lng + "&count=" + count;
            $http.get(url).success(
              function(data) {
                hotspotSource.clear();
                _.forEach(data, function (hotspot) {
                    addHotspot(hotspot);
                    $scope.closests.points.push(hotspot);
                });
              }
            );
        }
        
        var updateClosest = function() {
            getClosest($scope.datasetName, currentLng, currentLat, $scope.currentCount);
        }
        
        var hotspotSource = new ol.source.Vector();
        var selectedPositionSource = new ol.source.Vector();
        var userPositionSource = new ol.source.Vector();
        
        var hotspotLayer = new ol.layer.Vector({
            source: hotspotSource,
            style: hotspotStyle
        });
        
        var selectedPositionLayer = new ol.layer.Vector({
            source: selectedPositionSource
            //style: positionStyle
        });
        
        var userPositionLayer = new ol.layer.Vector({
            source: userPositionSource
            //style: positionStyle
        });
        
        var planLayer = new ol.layer.Tile({
            source: new ol.source.MapQuest({ layer: 'osm' })
        });
        
        // Center of our map: Paris.
        var parisLng = 2.3488000,
            parisLat = 48.8534100;
        
        var parisView = new ol.View({
            center: ol.proj.transform([parisLng, parisLat], 'EPSG:4326', 'EPSG:3857'),
            zoom: 13
        });
                
        var currentLng   = parisLng,
            currentLat   = parisLat;
        
        $scope.currentCount = 10;
        
        // By default, we show a world map
        var map = new ol.Map({
            target: 'map',
            layers: [ planLayer, selectedPositionLayer, userPositionLayer, hotspotLayer ],
            view: new ol.View({
                center: [0, 0],
                zoom: 2
            }) 
        });
        
        var geolocation = new ol.Geolocation({
            tracking: true, 
            projection: map.getView().getProjection()
        });
        
        // In case of error, center the map on Paris
        geolocation.on('error', function(error) {
            map.setView(parisView);
            currentLng = parisLng;
            currentLat = parisLat;
            updateSelectedPosition(currentLng, currentLat);
        });
        
        geolocation.on('change', function(evt) {
            var pos = geolocation.getPosition();
            map.getView().setZoom(13);
            map.getView().setCenter(pos);
            geolocation.setTracking(false);
            
            var lng_lat = ol.proj.transform(pos, 'EPSG:3857', 'EPSG:4326');
            updateUserPosition(lng_lat[0], lng_lat[1]);
        });
         
        var info = angular.element(document.querySelector('#info'));
        info.tooltip({
            animation: false,
            trigger: 'manual'
        })
        
        var displayFeatureInfo = function(pixel) {
            info.css({
              left: pixel[0] + 'px',
              top: (pixel[1] - 15) + 'px'
            });
            var feature = map.forEachFeatureAtPixel(pixel, function (feature, layer) {
                return feature;
            });
            if (feature) {
                info.tooltip('hide')
                    .attr('data-original-title', feature.get('name'))
                    .tooltip('fixTitle')
                    .tooltip('show');
            } else {
                info.tooltip('hide');
            }
        }
        
        $(map.getViewport()).on('mousemove', function (evt) {
            displayFeatureInfo(map.getEventPixel(evt.originalEvent));
        });
              
        var selectedPositionFeature = null;
        var userPositionFeature = null;
        
        function updateSelectedPosition(lng, lat) {
            selectedPositionFeature = updatePosition(lng, lat, selectedPositionFeature, selectedPositionSource, selectedPositionStyle, "Selected Position");
        }
        
        function updateUserPosition(lng, lat) {
            userPositionFeature = updatePosition(lng, lat, userPositionFeature, userPositionSource, userPositionStyle, "Your Position");
        }
        
        function updatePosition(lng, lat, positionFeature, positionSource, positionStyle, positionName) {
            if (positionFeature) {
                positionSource.removeFeature(positionFeature);
            }
            positionFeature = new ol.Feature({
                geometry: makePoint(lng, lat),
                name: positionName
            });
            positionFeature.setStyle(positionStyle);
            positionSource.addFeature(positionFeature);
            
            return positionFeature;
        }
        
        $scope.mapClicked = function(ev) {
            var loc = map.getEventCoordinate(ev),
                lng_lat = ol.proj.transform(loc, 'EPSG:3857', 'EPSG:4326');
            currentLng = lng_lat[0];
            currentLat = lng_lat[1];
            updateSelectedPosition(currentLng, currentLat);
            getClosest($scope.datasetName, currentLng, currentLat, $scope.currentCount);
        }

        $scope.submit = function (ev) {
          ev.preventDefault();
          var count = $("#count").val();
          if (count > 0) {
            $scope.currentCount = count;
            updateClosest();
          }
        };

        updateSelectedPosition(currentLng, currentLat);
        // Put the datasets in scope when ready to display the Menu
        datasetService.whenReady(function() {
          $scope.datasets = datasetService.data.value();
        });
      }
  }
  $stateProvider
    .state(map);

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
});