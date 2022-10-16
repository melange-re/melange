#!/usr/bin/env sh

set -e
set -u

cd $cur__lib

ln -sfn melange/js js
ln -sfn melange/es6 es6
mv melange/melange/* melange
rm -rf melange/melange
