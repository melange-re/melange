Showcase how to use `[@mel.meth]`

  $ . ./setup.sh
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

  $ melc -ppx melppx main.ml
  File "main.ml", line 9, characters 8-18:
  9 | let x = props##foo 123 "abc"
              ^^^^^^^^^^
  Error: This method call has type int -> string -> unit
         but an expression was expected of type
           ('a [@mel.meth]) = ('a [@mel.meth])
  [2]

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

  $ melc -ppx melppx main.ml > main.js
  $ node ./main.js
  a: 123
  b: abc
