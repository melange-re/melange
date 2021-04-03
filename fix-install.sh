#!/usr/bin/env sh

set -e
set -u

mkdir -p $cur__lib/ocaml
cd $cur__lib/ocaml
tar xvf ../melange/libocaml.tar.gz
mv others/* .
mv runtime/* .
mv stdlib-412/stdlib_modules/* .
mv stdlib-412/* .

cd $cur__lib
ln -s $cur__target_dir/default/lib/js .
ln -s $cur__target_dir/default/lib/es6 .
