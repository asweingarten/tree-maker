'use strict';

// require('ace-css/css/ace.css');
// require('font-awesome/css/font-awesome.css');

// require('bulma/css/bulma.css');
require('./index.css');

// Require index.html so it gets copied to dist
require('./index.html');

require('./lodash.custom.min.js')
// require('./makeTree.js')
import makeTree from './makeTree.js';

import inject from './injectTreeNavigation.js'

var TreeNavigation;
setTimeout(() => TreeNavigation = inject(makeTree), 500);
// var Elm = require('./Main.elm');
// var mountNode = document.getElementById('main');

// .embed() can take an optional second argument. This would be an object describing the data we need to start a program, i.e. a userID or some token
// var app = Elm.Main.embed(mountNode);
function startScanning() {
  TreeNavigation.ports.resumeScanning.send("x");
}

function pauseScanning() {
  TreeNavigation.ports.pauseScanning.send("x");
}

function select() {
  TreeNavigation.ports.receiveExternalCmd.send("Select");
}

export default TreeNavigation;
