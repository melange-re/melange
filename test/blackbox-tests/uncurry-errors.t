

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > let x = fun [@u] a -> Js.log a
  > let () = x 42
  > EOF

  $ melc -ppx melppx x.ml
  File "x.ml", line 2, characters 9-10:
  2 | let () = x 42
               ^
  Error: This function is uncurried; it needs to be applied in uncurried style
  [2]

  $ cat > x.ml <<EOF
  > let y (a : (int -> int[@u])) = Js.log (a 42 [@u])
  > let () = y (fun x -> x + 1)
  > EOF

  $ melc -ppx melppx x.ml
  File "x.ml", line 2, characters 11-27:
  2 | let () = y (fun x -> x + 1)
                 ^^^^^^^^^^^^^^^^
  Error: This expression is expected to have an uncurried function
  [2]

