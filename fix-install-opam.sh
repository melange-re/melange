#!/usr/bin/env sh

set -e
set -u

set -x

lib_dir="$1"
build_dir="$2"

mkdir -p "${lib_dir}/melange"
cd "${lib_dir}"
tar xvf libocaml.tar.gz --directory "${lib_dir}/melange"
cd melange
mv others/* .
mv runtime/* .
mv stdlib-412/stdlib_modules/* .
mv stdlib-412/* .

cd "${lib_dir}"
ln -s "${build_dir}/_build/default/lib/js" .
ln -s "${build_dir}/_build/default/lib/es6" .
