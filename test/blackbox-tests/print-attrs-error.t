Show how certain attribute errors are printed on type mismatches

  $ cat > x.ml <<EOF
  > let sum a b = a + b
  > let _ = sum 4 5 [@u]
  > EOF
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target melange)
  >  (alias melange)
  >  (emit_stdlib false)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ dune build @melange
  File "x.ml", line 2, characters 8-11:
  2 | let _ = sum 4 5 [@u]
              ^^^
  Error: This expression has type int -> int -> int
         but an expression was expected of type ('a [@u])
  [1]

  $ cat > x.ml <<EOF
  > type 'node t = < preventDefault : unit -> unit [@mel.meth] > Js.t
  > let event : 'node t = Obj.magic ()
  > let result = event [ "preventDefault" ] ()
  > EOF

  $ dune build @melange
  File "x.ml", line 3, characters 13-18:
  3 | let result = event [ "preventDefault" ] ()
                   ^^^^^
  Error: This expression has type
           < preventDefault : (unit -> unit [@mel.meth]) > Js.t
         This is not a function; it cannot be applied.
  [1]


  $ cat > x.ml <<EOF
  > type x
  > external x : x = "x"
  > external set_onload : x -> ((x -> int -> unit)[@mel.this]) -> unit = "onload"
  >   [@@mel.set]
  > external resp : x -> int = "response" [@@mel.get]
  > let _ =
  >   set_onload x
  >     begin
  >       fun o v -> Js.log (resp o + v)
  >     end
  > EOF

  $ dune build @melange
  File "x.ml", lines 8-10, characters 4-7:
   8 | ....begin
   9 |       fun o v -> Js.log (resp o + v)
  10 |     end
  Error: This expression should not be a function, the expected type is
         (x -> int -> unit [@mel.this])
  [1]
