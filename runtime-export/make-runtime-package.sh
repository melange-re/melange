#!/usr/bin/env bash

name=$1
src=$2
readme_src=$3
target=$4

add_dependencies() {
  local JQ_BASE='.name = $name | .version = $version'
  case "$name" in
    "melange.js")
      # melange.js has no dependencies
      jq "$JQ_BASE" \
        --arg name "$name" \
        --arg version "$MELANGE_RUNTIME_VERSION"
      ;;
    "melange")
      # melange depends on melange.js
      jq "$JQ_BASE | .dependencies.\"melange.js\" = \$version" \
        --arg name "$name" \
        --arg version "$MELANGE_RUNTIME_VERSION"
      ;;
    "melange.belt")
      # melange.belt depends on melange.js and melange
      jq "$JQ_BASE | .dependencies.\"melange.js\" = \$version | .dependencies.\"melange\" = \$version" \
        --arg name "$name" \
        --arg version "$MELANGE_RUNTIME_VERSION"
      ;;
    *)
      echo "Unknown library: $name" >&2
      exit 1
      ;;
  esac
}

# Generate package.json with deps
add_dependencies < "$src" > "$target"

# Generate README.md for the package
sed "s/%{library_name}/$name/g; s/%{version}/$MELANGE_RUNTIME_VERSION/g" "$readme_src" > "README.md"
