(function() {

'use strict';

require( './Stylesheets' );

var page = [ 'List' ];

var settings = {
  env: 'dev'
  // env: 'prod'
};


var path = page.join('/');
var ctrl = require('./' + path + '/Stub');
var bootstrap = require( './' + path + '/_Bootstrap');
var i = 0;
var l = page.length;

while(i < l) { // Step down the relative path to the component
  ctrl = ctrl[page[i]];
  i++
}

var ctx = bootstrap.context;
if (typeof ctx === 'undefined' || ctx === null) {
  ctx = {}
}

var state = null;
if (typeof ctx.init !== 'undefined' || ctx.init === null) {
  state = ctx.init(settings);
}

var app = ctrl.Stub.fullscreen(state);
if (typeof ctx.ports !== 'undefined' || ctx.init === null) {
  ctx.ports(settings, app, state);
}

})();

