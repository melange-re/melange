Showcase how to use `[@mel.meth]`

 $ . ./setup.sh

  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target melange)
  >  (alias mel)
  >  (emit_stdlib false)
  >  (preprocess (pps melange.ppx)))
  > EOF

  $ cat > main.ml <<EOF
  > let props : < foo : int -> string -> unit > Js.t =
  >   [%mel.raw
  >     {| {
  >     foo: function(a, b) {
  >       console.log("a:", a);
  >       console.log("b:", b);
  >     } }|}]
  > 
  > let x = props##foo 123 "abc"
  > EOF

  $ dune build @mel
  File "main.ml", line 9, characters 8-18:
  9 | let x = props##foo 123 "abc"
              ^^^^^^^^^^
  Error: This expression has type int -> string -> unit
         but an expression was expected of type ('a [@mel.meth])
  [1]

Methods in ( < .. > Js.t) need a `[@mel.meth]` annotation

  $ cat > main.ml <<EOF
  > let props : < foo : (int -> string -> unit [@mel.meth]) > Js.t =
  >   [%mel.raw
  >     {| {
  >     foo: function(a, b) {
  >       console.log("a:", a);
  >       console.log("b:", b);
  >     } }|}]
  > 
  > let x = props##foo 123 "abc"
  > EOF

  $ dune build @mel
  $ node _build/default/melange/main.js
  a: 123
  b: abc
