
  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >  (target js-out)
  >  (emit_stdlib false))
  > EOF

  $ cat > x.ml <<EOF
  > type t
  > external some_external : unit -> t = "" [@@mel.module "forgot-ppx"]
  > EOF
  $ cat > x.mli <<EOF
  > type t
  > external some_external : unit -> t = "" [@@mel.module "forgot-ppx"]
  > EOF
  $ dune build @melange
  File "x.mli", line 2, characters 0-67:
  Error (alert unprocessed): `[@mel.*]' attributes found in external declaration. Did you forget to preprocess with `melange.ppx'?
  [1]

  $ rm x.mli
  $ cat > x.ml <<EOF
  > let () = ref 0 |. incr
  > let () = foo##bar
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 15-17:
  Error (alert unprocessed): `[@mel.*]' attributes found in external declaration. Did you forget to preprocess with `melange.ppx'?
  
  File "x.ml", line 2, characters 12-14:
  Error (alert unprocessed): `[@mel.*]' attributes found in external declaration. Did you forget to preprocess with `melange.ppx'?
  
  File "x.ml", line 1, characters 15-17:
  Error: |. is not a valid value identifier.
  [1]

  $ cat > x.ml <<EOF
  > let x = fun [@u] () -> 42
  > let y = (x () [@u])
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 14-15:
  Error (alert unprocessed): Found uncurried (`[@u]') attribute. Did you forget to preprocess with `melange.ppx'?
  
  File "x.ml", line 2, characters 16-17:
  Error (alert unprocessed): Found uncurried (`[@u]') attribute. Did you forget to preprocess with `melange.ppx'?
  [1]

Make it non-fatal

  $ cat > dune <<EOF
  > (melange.emit
  >  (target js-out)
  >  (emit_stdlib false)
  >  (compile_flags :standard -alert --unprocessed))
  > EOF

  $ dune build @melange
  File "x.ml", line 1, characters 14-15:
  Alert unprocessed: Found uncurried (`[@u]') attribute. Did you forget to preprocess with `melange.ppx'?
  
  File "x.ml", line 2, characters 16-17:
  Alert unprocessed: Found uncurried (`[@u]') attribute. Did you forget to preprocess with `melange.ppx'?
