<!doctype html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>${app}</title>
    <base href="/${app}/">

    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <!-- basic styles -->

    <link href="styles/form.min.css" rel="stylesheet" />
    <link href="styles/table.min.css" rel="stylesheet" />
    <link href="styles/main.css" rel="stylesheet" />

    <link rel="stylesheet" href="http://openlayers.org/en/v3.0.0/css/ol.css" type="text/css">
    <script src="http://openlayers.org/en/v3.0.0/build/ol.js" type="text/javascript"></script>

    <link rel="stylesheet" href="styles/bootstrap.min.css">
    <style>
      #map {
        position: relative;
      }
      #info {
        position: absolute;
        height: 1px;
        width: 1px;
        z-index: 100;
      }
      .tooltip.in {
        opacity: 1;
        filter: alpha(opacity=100);
      }
      .tooltip.top .tooltip-arrow {
        border-top-color: white;
      }
      .tooltip-inner {
        border: 2px solid white;
      }
    </style>
  </head>

  <body ng-app="${app}">
    <!--[if lt IE 7]>
      <p class="browsehappy">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> to improve your experience.</p>
    <![endif]-->

    <!--[if lt IE 9]>
      <script src="bower_components/es5-shim/es5-shim.js"></script>
      <script src="bower_components/json3/lib/json3.min.js"></script>
    <![endif]-->

    <div class="menu">
      <ul>
        <li>
          <a ui-sref="hotspot" >Hotspots listing</a></li>
        <li>
          <a ui-sref="map" >Hotspots map</a>
        </li>
        <li>
          <a ui-sref="hotspot_add" >Add a hotspot</a>
        </li>
      </ul>
    </div><!-- menu -->

    <div class="main-container">
          <!-- PAGE CONTENT BEGINS -->

          <div ui-view></div>

          <!-- PAGE CONTENT ENDS -->
    </div><!-- /.main-container -->

    <!-- basic scripts -->

    <!-- inline scripts related to this page -->

    <script src="bower_components/lodash/dist/lodash.js"></script>
    <script src="bower_components/jquery/jquery.min.js"></script>
    
    <script src="bower_components/bootstrap/bootstrap.min.js"></script>
    
    <script src="bower_components/angular/angular.js"></script>

    <!-- build:js scripts/modules.js -->
    <script src="bower_components/angular-resource/angular-resource.js"></script>
    <script src="bower_components/angular-route/angular-route.js"></script>
    <script src="bower_components/restangular/dist/restangular.min.js"></script>
    <script src="bower_components/angular-ui-router/release/angular-ui-router.min.js"></script>

    <!-- endbuild -->

    <!-- build:js({.tmp,app}) scripts/scripts.js -->
    <script src="scripts/app.js"></script>
    <script src="scripts/config.js"></script>

    <script src="scripts/entities-service.js"></script>
    <script src="scripts/i18n-service.js"></script>
    
    <#list entities as entity> 
    <script src="scripts/data/${entity}-service.js"></script>
    </#list>

  </body>
</html>
