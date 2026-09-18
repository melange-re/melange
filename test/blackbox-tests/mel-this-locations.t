Method callbacks generate location-contained scaffolding

  $ . ./setup.sh

  $ cat > locations.ml <<'EOF'
  > let callback =
  >   fun [@mel.this] self value ->
  >     self + value
  > EOF

  $ melc -ppx 'melppx -locations-check' -c locations.ml > /dev/null
