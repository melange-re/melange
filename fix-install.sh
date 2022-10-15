#!/usr/bin/env sh

set -e
set -u

cd $cur__lib

mv melange/js js
mv melange/es6 es6
mv melange/melange/* melange
rm -rf melange/melange
