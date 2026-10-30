Typed-array map and mapi must reject callbacks returning nonnumeric values.
Regression coverage for ReScript #9112.

  $ . ./setup.sh
  $ cat > map.ml <<'EOF'
  > let f xs =
  >   Js.Typed_array.Int8Array.map ~f:(fun _ -> "not a number") xs
  > EOF
  $ melc -ppx melppx -o map.js map.ml
  File "map.ml", line 2, characters 44-58:
  2 |   Js.Typed_array.Int8Array.map ~f:(fun _ -> "not a number") xs
                                                  ^^^^^^^^^^^^^^
  Error: This constant has type string but an expression was expected of type
           Js.Typed_array.Int8Array.elt = int
  [2]

  $ cat > mapi.ml <<'EOF'
  > let f xs =
  >   Js.Typed_array.Float64Array.mapi ~f:(fun _ _ -> "not a number") xs
  > EOF
  $ melc -ppx melppx -o mapi.js mapi.ml
  File "mapi.ml", line 2, characters 50-64:
  2 |   Js.Typed_array.Float64Array.mapi ~f:(fun _ _ -> "not a number") xs
                                                        ^^^^^^^^^^^^^^
  Error: This constant has type string but an expression was expected of type
           Js.Typed_array.Float64Array.elt = float
  [2]
