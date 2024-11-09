Usage of mel.raw can trigger warning 20 ([ignored-extra-argument])

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune << EOF
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false)
  >  (preprocess (pps melange.ppx)))
  > EOF

  $ cat > foo.ml <<EOF
  > let addOne = [%mel.raw {|
  >   function (a) {
  >     return a + 1;
  >   }
  > |}]
  > let x = addOne 2
  > EOF

  $ dune build @melange
  File "foo.ml", line 6, characters 15-16:
  6 | let x = addOne 2
                     ^
  Error (warning 20 [ignored-extra-argument]): this argument will not be used by the function.
  [1]

Annotating the function (which should always be the case, for safety) makes the
warning go away

  $ cat > foo.ml <<EOF
  > let addOne: int -> int = [%mel.raw {|
  >   function (a) {
  >     return a + 1;
  >   }
  > |}]
  > let x = addOne 2
  > EOF

  $ dune build @melange

Uncurried

  $ cat > foo.ml <<EOF
  > let addOne n = [%mel.raw {|
  >   function (a) {
  >     return a + 1;
  >   }
  > |}] n
  > EOF

  $ dune build @melange
  File "foo.ml", line 5, characters 4-5:
  5 | |}] n
          ^
  Error (warning 20 [ignored-extra-argument]): this argument will not be used by the function.
  [1]

  $ cat > foo.ml <<EOF
  > let addOne n = ([%mel.raw {|
  >   function (a) {
  >     return a + 1;
  >   }
  > |}]: (_ -> _ [@u])) n [@u]
  > EOF

  $ dune build @melange
