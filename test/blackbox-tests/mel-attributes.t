
  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type t
  > external clipboardData : t -> < .. > Js.t = "clipboardData" [@@bs.get]
  > external set_title : t -> string -> unit = "title" [@@bs.set]
  > external err :
  >   x:([\`a of int | \`b of string ] [@bs.string]) ->
  >   unit -> unit = "err" [@@bs.val]
  > external set_onload : t -> ((t -> int -> unit)[@bs.this]) -> unit = "onload"
  > let handlePromiseFailure = function [@bs.open]
  >  | Not_found -> Js.log "Not found"; (Js.Promise.resolve ())
  > external map
  >   :  'a array
  >   -> 'b array -> ('a -> 'b -> 'c [@bs]) -> 'c array = "map"
  > let f = fun [@bs] x y -> x + y
  > let x = (object [@bs] method hi x y =x + y end )
  > external mk : ?hi:int -> unit -> _ = "" [@@bs.obj]
  > (* let raw = [%raw "42"] *)
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
  File "x.ml", line 2, characters 63-69:
  2 | external clipboardData : t -> < .. > Js.t = "clipboardData" [@@bs.get]
                                                                     ^^^^^^
  Alert deprecated: The `[@bs.*]' attributes are deprecated and will be removed in the
  next release.
  Use `[@mel.*]' instead.
  
  File "x.ml", line 3, characters 54-60:
  3 | external set_title : t -> string -> unit = "title" [@@bs.set]
                                                            ^^^^^^
  Alert deprecated: The `[@bs.*]' attributes are deprecated and will be removed in the
  next release.
  Use `[@mel.*]' instead.
  
  File "x.ml", line 6, characters 26-32:
  6 |   unit -> unit = "err" [@@bs.val]
                                ^^^^^^
  Alert deprecated: The `[@bs.*]' attributes are deprecated and will be removed in the
  next release.
  Use `[@mel.*]' instead.
  
  File "x.ml", line 6, characters 26-32:
  6 |   unit -> unit = "err" [@@bs.val]
                                ^^^^^^
  Alert deprecated: `[@mel.val]' attributes are redundant and will be removed in the next release.
  Consider removing them from any external declarations.
  
  File "x.ml", line 5, characters 35-44:
  5 |   x:([`a of int | `b of string ] [@bs.string]) ->
                                         ^^^^^^^^^
  Alert deprecated: The `[@bs.*]' attributes are deprecated and will be removed in the
  next release.
  Use `[@mel.*]' instead.
  
  File "x.ml", line 7, characters 48-55:
  7 | external set_onload : t -> ((t -> int -> unit)[@bs.this]) -> unit = "onload"
                                                      ^^^^^^^
  Alert deprecated: The `[@bs.*]' attributes are deprecated and will be removed in the
  next release.
  Use `[@mel.*]' instead.
  
  File "x.ml", line 8, characters 38-45:
  8 | let handlePromiseFailure = function [@bs.open]
                                            ^^^^^^^
  Alert deprecated: The `[@bs.*]' attributes are deprecated and will be removed in the
  next release.
  Use `[@mel.*]' instead.
  
  File "x.ml", line 12, characters 35-37:
  12 |   -> 'b array -> ('a -> 'b -> 'c [@bs]) -> 'c array = "map"
                                          ^^
  Alert deprecated: The `[@bs]' uncurry attribute is deprecated and will be removed in the next release.
  Use `[@u]' instead.
  
  File "x.ml", line 13, characters 14-16:
  13 | let f = fun [@bs] x y -> x + y
                     ^^
  Alert deprecated: The `[@bs]' uncurry attribute is deprecated and will be removed in the next release.
  Use `[@u]' instead.
  
  File "x.ml", line 14, characters 18-20:
  14 | let x = (object [@bs] method hi x y =x + y end )
                         ^^
  Alert deprecated: The `[@bs]' uncurry attribute is deprecated and will be removed in the next release.
  Use `[@u]' instead.
  
  File "x.ml", line 15, characters 43-49:
  15 | external mk : ?hi:int -> unit -> _ = "" [@@bs.obj]
                                                  ^^^^^^
  Alert deprecated: The `[@bs.*]' attributes are deprecated and will be removed in the
  next release.
  Use `[@mel.*]' instead.

