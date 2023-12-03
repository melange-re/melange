
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
  Alert deprecated: FFI attributes without a namespace are deprecated and will be removed in the next release.
  Use `mel.*' instead.
  
  File "x.ml", line 3, characters 54-57:
  3 | external set_title : t -> string -> unit = "title" [@@set]
                                                            ^^^
  Alert deprecated: FFI attributes without a namespace are deprecated and will be removed in the next release.
  Use `mel.*' instead.
  
  File "x.ml", line 5, characters 35-41:
  5 |   x:([`a of int | `b of string ] [@string]) ->
                                         ^^^^^^
  Alert deprecated: FFI attributes without a namespace are deprecated and will be removed in the next release.
  Use `mel.*' instead.
  
  File "x.ml", line 7, characters 48-52:
  7 | external set_onload : t -> ((t -> int -> unit)[@this]) -> unit = "onload"
                                                      ^^^^
  Alert deprecated: FFI attributes without a namespace are deprecated and will be removed in the next release.
  Use `mel.*' instead.
  
  File "x.ml", line 16, characters 43-46:
  16 | external mk : ?hi:int -> unit -> _ = "" [@@obj]
                                                  ^^^
  Alert deprecated: FFI attributes without a namespace are deprecated and will be removed in the next release.
  Use `mel.*' instead.
  
  File "x.ml", line 17, characters 6-12:
  17 | let [@inline] _x = 42
             ^^^^^^
  Alert deprecated: FFI attributes without a namespace are deprecated and will be removed in the next release.
  Use `mel.*' instead.

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
  Error (alert deprecated): FFI attributes without a namespace are deprecated and will be removed in the next release.
  Use `mel.*' instead.
  [1]

