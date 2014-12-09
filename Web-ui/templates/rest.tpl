var express = require('express'),
    fs = require('fs'),
    lodash = require('lodash');

var app = express();

app.use(express.compress());

app.set('SSE_ENABLED', false);

app.use(express.errorHandler({
    dumpExceptions: true,
    showStack: true
}));

app.use(express.static(__dirname + '/app'));
app.use(express.static(__dirname + '/app/mock'));

app.listen(8080);
