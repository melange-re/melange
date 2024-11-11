#!/usr/bin/env bash

name=$1
src=$2
target=$3

jq '.name = $name | .version = $version' \
  --arg name "$name" \
  --arg version "$MELANGE_RUNTIME_VERSION" \
  $src > $target

