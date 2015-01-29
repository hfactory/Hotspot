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

    <link href="bower_components/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <link href="styles/semantic.min.css" rel="stylesheet" />
    <link href="styles/style.css" rel="stylesheet" />
    <link href="styles/paris-style.css" rel="stylesheet" />

    <link rel="stylesheet" href="http://openlayers.org/en/v3.0.0/css/ol.css" type="text/css">
    <script src="http://openlayers.org/en/v3.0.0/build/ol.js" type="text/javascript"></script>
  </head>

  <body ng-app="${app}">
    <!--[if lt IE 7]>
      <p class="browsehappy">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> to improve your experience.</p>
    <![endif]-->

    <!--[if lt IE 9]>
      <script src="bower_components/es5-shim/es5-shim.js"></script>
      <script src="bower_components/json3/lib/json3.min.js"></script>
    <![endif]-->

    <div id="main-menu-container">
        <div id="menu-button" class="ui icon button">
            <i class="content icon"></i>
            <span class="text">Menu</span>
        </div>
    </div>
    <div ui-view></div>

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

    <script src="js/semantic.min.js"></script>
    <script src="js/script.js"></script>
  </body>
</html>
