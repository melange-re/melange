Typed-array map and mapi must reject callbacks returning nonnumeric values.
The current bindings incorrectly accept both cases (ReScript #9112).

  $ . ./setup.sh
  $ cat > map.ml <<'EOF'
  > let f xs =
  >   Js.Typed_array.Int8Array.map ~f:(fun _ -> "not a number") xs
  > EOF
  $ melc -ppx melppx -o map.js map.ml

  $ cat > mapi.ml <<'EOF'
  > let f xs =
  >   Js.Typed_array.Float64Array.mapi ~f:(fun _ _ -> "not a number") xs
  > EOF
  $ melc -ppx melppx -o mapi.js mapi.ml
