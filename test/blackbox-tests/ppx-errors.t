Demonstrate PPX error messages

  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > module M = struct
  >   type t = { b : string }
  > end
  > let x = [%mel.obj { a = 1; M.b = 2 }]
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 4, characters 27-30:
  4 | let x = [%mel.obj { a = 1; M.b = 2 }]
                                 ^^^
  Error: `%mel.obj' literals only support simple labels
  [2]

  $ cat > x.ml <<EOF
  > let x = [%mel.obj [1;2;3]]
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 1, characters 8-26:
  1 | let x = [%mel.obj [1;2;3]]
              ^^^^^^^^^^^^^^^^^^
  Error: %mel.obj requires a record literal
  [2]

  $ cat > x.ml <<EOF
  > class type x = object
  >   method height : int [@@mel.get { null = not }]
  > end [@u]
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 2, characters 42-45:
  2 |   method height : int [@@mel.get { null = not }]
                                                ^^^
  Error: expected this expression to be a boolean literal (`true` or `false`)
  [2]

  $ cat > x.ml <<EOF
  > type t
  > external mk : int -> (_ [@mel.as {json| undeclared_var |json}]) ->  t = "mk"
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 2, characters 33-61:
  2 | external mk : int -> (_ [@mel.as {json| undeclared_var |json}]) ->  t = "mk"
                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `[@mel.as {json| ... |json}]' only supports JavaScript literals
  [2]

  $ cat > x.ml <<EOF
  > type t
  > external mk : t = "" ""
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 2, characters 0-23:
  2 | external mk : t = "" ""
      ^^^^^^^^^^^^^^^^^^^^^^^
  Error: Melange requires a single string in `external` payloads
  [2]

  $ cat > x.ml <<EOF
  > type t =
  >   < chdir : string -> unit [@mel.meth] [@mel.get] >
  >   Js.t
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 2, characters 2-51:
  2 |   < chdir : string -> unit [@mel.meth] [@mel.get] >
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `@mel.get' / `@mel.set' cannot be used with `@mel.meth'
  [2]

  $ cat > x.ml <<EOF
  > let { M.x } = (module Y)
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 1, characters 6-9:
  1 | let { M.x } = (module Y)
            ^^^
  Error: Pattern matching on modules requires simple labels
  [2]

  $ cat > x.ml <<EOF
  > let () = [%mel.debugger payload]
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 1, characters 9-32:
  1 | let () = [%mel.debugger payload]
               ^^^^^^^^^^^^^^^^^^^^^^^
  Error: `%mel.debugger' doesn't take payload
  [2]

  $ cat > x.ml <<EOF
  > let () = [%mel.re 42]
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 1, characters 9-21:
  1 | let () = [%mel.re 42]
               ^^^^^^^^^^^^
  Error: `%mel.re' can only be applied to a string
  [2]

  $ cat > x.ml <<EOF
  > let () = [%mel.re "just a string"]
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 1, characters 24-25:
  1 | let () = [%mel.re "just a string"]
                              ^
  Warning 103 [melange-ffi-warning]: FFI warning: Unexpected identifier, expected the end of input
  File "x.ml", line 1, characters 18-33:
  1 | let () = [%mel.re "just a string"]
                        ^^^^^^^^^^^^^^^
  Error: `%mel.re' expects a valid JavaScript regular expression literal
         (`/regex/opt-flags')
  [2]

  $ cat > x.ml <<EOF
  > let x = function [@mel.open]
  > | Not_found -> 0
  > | Invalid_argument _ -> 1
  > | ident -> 2
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 4, characters 2-7:
  4 | | ident -> 2
        ^^^^^
  Error: Unsupported pattern. `[@mel.open]' requires patterns to be (exception)
         constructors
  [2]

  $ cat > x.ml <<EOF
  > let x =
  >   (object
  >      method y = 3
  >   end [@u])
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 3, characters 5-17:
  3 |      method y = 3
           ^^^^^^^^^^^^
  Error: Unsupported JS Object syntax. Methods must take at least one argument
  [2]

  $ cat > x.ml <<EOF
  > class type x = object
  >   method height : int [@@mel.get "str"]
  > end[@u]
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 2, characters 25-32:
  2 |   method height : int [@@mel.get "str"]
                               ^^^^^^^
  Error: Unsupported attribute payload. Expected a configuration record literal
  [2]

  $ cat > x.ml <<EOF
  > class type x = object
  >   method height : int [@@mel.get { x with null = true }]
  > end[@u]
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 2, characters 25-32:
  2 |   method height : int [@@mel.get { x with null = true }]
                               ^^^^^^^
  Error: Unsupported attribute payload. Expected a configuration record literal
         (`with' not supported)
  [2]


  $ cat > x.ml <<EOF
  > class type x = object
  >   method height : int [@@mel.get { M.null = true }]
  > end[@u]
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 2, characters 25-32:
  2 |   method height : int [@@mel.get { M.null = true }]
                               ^^^^^^^
  Error: Unsupported attribute payload. Expected a configuration record literal
         (qualified labels aren't supported)
  [2]

  $ cat > x.ml <<EOF
  > type t
  > external x : t = "x" [@@mel.module (1,"2")]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 2, characters 36-37:
  2 | external x : t = "x" [@@mel.module (1,"2")]
                                          ^
  Error: Expected a tuple of string literals
  [2]

  $ cat > x.ml <<EOF
  > type t
  > external x : t = "x" [@@mel.module 1]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 2, characters 21-37:
  2 | external x : t = "x" [@@mel.module 1]
                           ^^^^^^^^^^^^^^^^
  Error: Expected a string or tuple of strings
  [2]

  $ cat > x.ml <<EOF
  > type t
  > external x : t = "x" [@@mel.module ("1","2","3")]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 2, characters 21-49:
  2 | external x : t = "x" [@@mel.module ("1","2","3")]
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `[@mel.module ..]' expects, at most, a tuple of two strings (module
         name, variable name)
  [2]

  $ cat > x.ml <<EOF
  > type t
  > external x : t = "x" [@@mel.scope]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 2, characters 21-34:
  2 | external x : t = "x" [@@mel.scope]
                           ^^^^^^^^^^^^^
  Error: `[@mel.scope ..]' expects a tuple of strings in its payload
  [2]

  $ cat > x.ml <<EOF
  > type 'a t
  > external set : 'a t -> string -> 'a -> unit = "payload" [@@mel.set_index]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 2, characters 56-73:
  2 | external set : 'a t -> string -> 'a -> unit = "payload" [@@mel.set_index]
                                                              ^^^^^^^^^^^^^^^^^
  Error: `@mel.set_index' requires its `external' payload to be the empty
         string
  [2]

  $ cat > x.ml <<EOF
  > type 'a t
  > external get : 'a t -> string -> 'a = "payload" [@@mel.get_index]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 2, characters 48-65:
  2 | external get : 'a t -> string -> 'a = "payload" [@@mel.get_index]
                                                      ^^^^^^^^^^^^^^^^^
  Error: `@mel.get_index' requires its `external' payload to be the empty
         string
  [2]

  $ cat > x.ml <<EOF
  > external mk : foo:string -> unit -> _ Js.t = "payload" [@@mel.obj]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 1, characters 0-66:
  1 | external mk : foo:string -> unit -> _ Js.t = "payload" [@@mel.obj]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `[@mel.obj]' requires its `external' payload to be the empty string
  [2]

  $ cat > x.ml <<EOF
  > external mk : foo:string -> string -> _ Js.t = "" [@@mel.obj]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 1, characters 28-34:
  1 | external mk : foo:string -> string -> _ Js.t = "" [@@mel.obj]
                                  ^^^^^^
  Error: `[@mel.obj]' external declaration arguments must be one of:
         - a labelled argument
         - an optionally labelled argument
         - `unit' as the final argument
  [2]

  $ cat > x.ml <<EOF
  > external mk : foo:(string -> string [@mel.uncurry]) -> unit -> _ Js.t = ""
  > [@@mel.obj]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 1, characters 19-35:
  1 | external mk : foo:(string -> string [@mel.uncurry]) -> unit -> _ Js.t = ""
                         ^^^^^^^^^^^^^^^^
  Error: `[@mel.uncurry]' can't be used within `[@mel.obj]'
  [2]

  $ cat > x.ml <<EOF
  > type 'a t
  > external set : 'a t -> string -> 'a -> 'a -> unit = "" [@@mel.set_index]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 2, characters 0-72:
  2 | external set : 'a t -> string -> 'a -> 'a -> unit = "" [@@mel.set_index]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `[@mel.set_index]' requires a function of 3 arguments: `'t -> 'key ->
         'value -> unit'
  [2]

  $ cat > x.ml <<EOF
  > type 'a t
  > external get : 'a t -> 'a = "" [@@mel.get_index]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 2, characters 0-48:
  2 | external get : 'a t -> 'a = "" [@@mel.get_index]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `[@mel.get_index]' requires a function of 2 arguments: `'t -> 'key ->
         'value'
  [2]

  $ cat > x.ml <<EOF
  > type t
  > external red : string -> t = "some-module"
  > [@@mel.new "payload"] [@@mel.module]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 3, characters 0-21:
  3 | [@@mel.new "payload"] [@@mel.module]
      ^^^^^^^^^^^^^^^^^^^^^
  Error: `[@mel.new]' doesn't expect an attribute payload
  [2]

  $ cat > x.ml <<EOF
  > external get : string = "some-fn" [@@mel.send]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 1, characters 0-46:
  1 | external get : string = "some-fn" [@@mel.send]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `[@mel.send]` requires a function with at least one argument
  [2]

  $ cat > x.ml <<EOF
  > external get : (_ [@mel.as {json|{}|json}]) -> string = "some-fn" [@@mel.send]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 1, characters 0-78:
  1 | external get : (_ [@mel.as {json|{}|json}]) -> string = "some-fn" [@@mel.send]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `[@mel.send]`'s must have at least a non-constant argument
  [2]

  $ cat > x.ml <<EOF
  > type t
  > external get : t -> string = "some-fn" [@@mel.send] [@@mel.new "hi"]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 2, characters 52-68:
  2 | external get : t -> string = "some-fn" [@@mel.send] [@@mel.new "hi"]
                                                          ^^^^^^^^^^^^^^^^
  Error: `[@mel.new]' doesn't expect an attribute payload
  [2]

  $ cat > x.ml <<EOF
  > type t
  > external get : (t [@mel.this]) -> string = "some-fn" [@@mel.send] [@@mel.new "hi"]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", line 2, characters 66-82:
  2 | external get : (t [@mel.this]) -> string = "some-fn" [@@mel.send] [@@mel.new "hi"]
                                                                        ^^^^^^^^^^^^^^^^
  Error: `[@mel.new]' doesn't expect an attribute payload
  [2]

  $ cat > x.ml <<EOF
  > type t
  > external setX1 : t -> unit = "set"
  > [@@mel.set] [@@mel.scope "a0"]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", lines 2-3, characters 0-30:
  2 | external setX1 : t -> unit = "set"
  3 | [@@mel.set] [@@mel.scope "a0"]
  Error: `[@mel.set]' requires a function of two arguments
  [2]

  $ cat > x.ml <<EOF
  > type t
  > external f: t -> int -> unit [@mel.uncurry] = "set"
  > [@@mel.send]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", lines 2-3, characters 0-12:
  2 | external f: t -> int -> unit [@mel.uncurry] = "set"
  3 | [@@mel.send]
  Error: `[@mel.uncurry]' must not be applied to the entire annotation
  [2]

  $ cat > x.ml <<EOF
  > type t
  > external f: t -> int -> (unit [@mel.uncurry]) = "set"
  > [@@mel.send]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", lines 2-3, characters 0-12:
  2 | external f: t -> int -> (unit [@mel.uncurry]) = "set"
  3 | [@@mel.send]
  Error: `[@mel.uncurry]' cannot be applied to the return type
  [2]

  $ cat > x.ml <<EOF
  > external join : ?foo:string array -> string = "join"
  > [@@mel.module "path"] [@@mel.variadic]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", lines 1-2, characters 0-38:
  1 | external join : ?foo:string array -> string = "join"
  2 | [@@mel.module "path"] [@@mel.variadic]
  Error: `[@mel.variadic]' cannot be applied to an optionally labelled argument
  [2]

