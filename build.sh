#!/bin/bash

elm-make src/*.elm --output build/treeNav.js;
browserify src/app.js -o build/bundle.js
