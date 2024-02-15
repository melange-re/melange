
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
  File "x.ml", line 2, characters 63-66:
  2 | external clipboardData : t -> < .. > Js.t = "clipboardData" [@@get]
                                                                     ^^^
  Error: `[@bs.*]' and non-namespaced attributes have been removed in favor of `[@mel.*]' attributes.
  [1]

Skip processing with PPX but still use `@mel.config`

  $ cat > dune <<EOF
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false))
  > EOF
  $ cat > x.ml <<EOF
  > [@@@config { flags = [| "-w"; "-32" |] }]
  > let x = 1
  > EOF
  $ dune build @melange
  File "x.ml", line 1, characters 4-10:
  1 | [@@@config { flags = [| "-w"; "-32" |] }]
          ^^^^^^
  Error: `[@bs.*]' and non-namespaced attributes have been removed in favor of `[@mel.*]' attributes. Use `[@mel.config]' instead.
  [1]

