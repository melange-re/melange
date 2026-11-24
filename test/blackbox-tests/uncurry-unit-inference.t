Type inference for the shared-field proposal for
https://github.com/melange-re/melange/issues/674.

The proposal is not yet implemented in melange.ppx. These tests model its
types and spell out the proposed expansion of `f () [@u]`, using the existing
uncurried application primitives.

  $ . ./setup.sh
  $ cat > shared_field.mli <<'EOF'
  > module Fn : sig
  >   type 'a arity1 = { call : 'a } [@@unboxed]
  >   type 'a arity0 = { call : unit -> 'a } [@@unboxed]
  > end
  > type 'a callback = ('a -> unit) Fn.arity1
  > type 'a promise
  > val make :
  >   (resolve:'a callback -> reject:exn callback -> unit) -> 'a promise
  > EOF
  $ melc -c shared_field.mli

The expected callback type makes resolve's arity known before its body is
checked. Zero-arity calls still work, and an unknown receiver defaults to
arity0, whose field was declared last.

  $ cat > direct.ml <<'EOF'
  > open Shared_field
  > let promise =
  >   make (fun ~resolve ~reject:_ ->
  >     Js.Internal.opaqueFullApply ((Js.Internal.opaque resolve.Fn.call) ()))
  > let zero (f : 'a Fn.arity0) =
  >   Js.Internal.opaqueFullApply ((Js.Internal.opaque f.Fn.call) ())
  > let call f =
  >   Js.Internal.opaqueFullApply ((Js.Internal.opaque f.Fn.call) ())
  > EOF
  $ melc -I . -i direct.ml
  val promise : unit Shared_field.promise
  val zero : 'a Shared_field.Fn.arity0 -> 'a
  val call : 'a Shared_field.Fn.arity0 -> 'a

Extracting the call into an unannotated helper loses that expected type.
The helper is inferred as taking arity0; passing resolve later cannot change
that choice to arity1, even when the promise's result is explicitly unit.
In source syntax, this is `let call f = f () [@u]`, followed by
`Js.Promise.make (fun ~resolve ~reject:_ -> call resolve)`.

  $ cat > extracted.ml <<'EOF'
  > open Shared_field
  > let call f =
  >   Js.Internal.opaqueFullApply ((Js.Internal.opaque f.Fn.call) ())
  > let promise : unit promise =
  >   make (fun ~resolve ~reject:_ -> call resolve)
  > EOF
  $ melc -I . -i extracted.ml
  File "extracted.ml", line 5, characters 39-46:
  5 |   make (fun ~resolve ~reject:_ -> call resolve)
                                             ^^^^^^^
  Error: The value resolve has type
           'a Shared_field.callback = ('a -> unit) Shared_field.Fn.arity1
         but an expression was expected of type 'b Shared_field.Fn.arity0
  [2]

Annotating the helper's parameter supplies the arity before field selection.
The callback alias retains arity1 when its argument is instantiated to unit.
With the proposed PPX change, the corresponding source would define
`type 'a callback = ('a -> unit) [@u]` and use
`let call (f : unit callback) = f () [@u]`.

Writing `(unit -> unit) [@u]` directly would still select arity0.

  $ cat > annotated.ml <<'EOF'
  > open Shared_field
  > let call (f : unit callback) =
  >   Js.Internal.opaqueFullApply ((Js.Internal.opaque f.Fn.call) ())
  > let promise = make (fun ~resolve ~reject:_ -> call resolve)
  > EOF
  $ melc -I . -i annotated.ml
  val call : unit Shared_field.callback -> unit
  val promise : unit Shared_field.promise

Selecting arity1 still checks the argument type: a callback expecting an int
cannot be applied to unit.

  $ cat > wrong_argument.ml <<'EOF'
  > open Shared_field
  > let call (f : int callback) =
  >   Js.Internal.opaqueFullApply ((Js.Internal.opaque f.Fn.call) ())
  > EOF
  $ melc -I . -i wrong_argument.ml
  File "wrong_argument.ml", line 3, characters 62-64:
  3 |   Js.Internal.opaqueFullApply ((Js.Internal.opaque f.Fn.call) ())
                                                                    ^^
  Error: This expression should not be a unit literal, the expected type is int
  [2]
