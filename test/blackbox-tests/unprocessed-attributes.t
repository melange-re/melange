
  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF

  $ cat > x.ml <<EOF
  > type t
  > external some_external : unit -> t = "" [@@mel.module "forgot-ppx"]
  > EOF
  $ cat > x.mli <<EOF
  > type t
  > external some_external : unit -> t = "" [@@mel.module "forgot-ppx"]
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >  (target js-out)
  >  (emit_stdlib false))
  > EOF

  $ dune build @melange
  File "x.mli", line 2, characters 0-67:
  2 | external some_external : unit -> t = "" [@@mel.module "forgot-ppx"]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Alert unprocessed: [%@mel.*] attributes found in external declaration. Did you forget to preprocess with `melange.ppx'?
  File "x.ml", line 2, characters 0-67:
  2 | external some_external : unit -> t = "" [@@mel.module "forgot-ppx"]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Alert unprocessed: [%@mel.*] attributes found in external declaration. Did you forget to preprocess with `melange.ppx'?

