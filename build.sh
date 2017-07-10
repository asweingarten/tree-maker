#!/bin/bash

elm-make src/*.elm --output build/treeNav.js;
cp src/*.js build/;
