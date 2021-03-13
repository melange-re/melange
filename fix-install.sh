#! /bin/sh

set -e
set -u

cd $cur__lib/bucklescript
tar xvf libocaml.tar.gz
mv others/* .
mv runtime/* .
mv stdlib-412/stdlib_modules/* .
mv stdlib-412/* .

cd $cur__lib
ln -s $cur__target_dir/default/lib/js .
ln -s $cur__target_dir/default/lib/es6 .

ln -s $cur__bin/bsc.exe $cur__bin/bsc
ln -s $cur__bin/bsb.exe $cur__bin/bsb
