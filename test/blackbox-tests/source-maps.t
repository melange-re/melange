  $ cat > example.ml <<'EOF'
  > let add x y = x + y
  > let value = add 1 2
  > EOF

  $ melc -o no-map.js example.ml

  $ test ! -f no-map.js.map

  $ grep "sourceMappingURL" no-map.js
  [1]

  $ melc --source-map -o external.js example.ml

  $ test -f external.js.map

  $ grep "sourceMappingURL" external.js
  //# sourceMappingURL=external.js.map

  $ jq -r '.sourcesContent[0] == null' external.js.map
  true

  $ melc --source-map --source-map-include-sources -o embedded.js example.ml

  $ test -f embedded.js.map

  $ grep "sourceMappingURL" embedded.js
  //# sourceMappingURL=embedded.js.map

  $ jq -r '.version' embedded.js.map
  3

  $ jq -r '.sourcesContent[0] | type' embedded.js.map
  string

  $ jq -r '.sources[0]' embedded.js.map
  example.ml

  $ jq -r '.mappings | length > 0' embedded.js.map
  true
