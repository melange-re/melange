
  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > type t
  > external clipboardData : t -> < .. > Js.t = "clipboardData" [@@get]
  > external set_title : t -> string -> unit = "title" [@@set]
  > external err :
  >   x:([\`a of int | \`b of string ] [@string]) ->
  >   unit -> unit = "err"
  > external set_onload : t -> ((t -> int -> unit)[@this]) -> unit = "onload"
  > let handlePromiseFailure = function [@open]
  >  | Not_found -> Js.log "Not found"; (Js.Promise.resolve ())
  >  | _ -> (Js.Promise.resolve ())
  > external map
  >   :  'a array
  >   -> 'b array -> ('a -> 'b -> 'c [@bs]) -> 'c array = "map"
  > let f = fun [@bs] x y -> x + y
  > let x = (object [@bs] method hi x y =x + y end )
  > external mk : ?hi:int -> unit -> _ = "" [@@obj]
  > let [@inline] _x = 42
  > EOF

  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ dune build @melange
  File "x.ml", line 16, characters 0-47:
  16 | external mk : ?hi:int -> unit -> _ = "" [@@obj]
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Alert fragile: mk : the external name is inferred from val name is unsafe from refactoring when changing value name
  File "x.ml", line 2, characters 0-67:
  2 | external clipboardData : t -> < .. > Js.t = "clipboardData" [@@get]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: Found these deprecated attributes in external declaration: `get`. Migrate to the right `[@mel.*]` attributes instead.
  [1]
