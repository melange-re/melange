Restored local opens on flattened tuple bindings have well-formed locations.

  $ . ./setup.sh

  $ cat > locations.ml <<'EOF'
  > module Values = struct
  >   let first = 1
  >   let second = 2
  > end
  > let first, second = Values.(first, second)
  > EOF

  $ ocamlc -ppx 'melppx -locations-check' -c locations.ml
