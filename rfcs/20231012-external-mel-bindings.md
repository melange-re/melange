- Start Date: 2023-10-12
- RFC PR: tbd

# Summary

This RFC proposes a new approach to writing bindings to JavaScript functions in
Melange. 

# Basic example

The proposal consists on introducing three extensions:
- `let%js` for declaration of bindings to JavaScript plain values / functions
- `let%js.import` for declaration of bindings to JavaScript modules
- `let%js.obj` would work essentially like `mel.obj`

## `let.js`

This extension operates over `let` bindings, and are expected to assign a string
literal to a value. The string literal will be interpreted as plain JavaScript,
and will define the operations to apply over the labelled arguments, which can
be referenced inside the string by using the `$` prefix.

For example, a binding to `decodeURI` global function:

```ocaml
let%js decodeURI : uri:string -> string = {|decodeURI($uri)|}
```

Note that the usage of quoted string `{||}` is optional, but recommended, as
double quotes `"` inside the string don't need to be escaped.

Also note the choice of `let` vs `external` is intentional: besides having to
type less characters, quoted strings remain untouched by OCamlformat, while they
get transformed into regular strings in externals.

The syntactic construct chosen is also consistent with the generated code:
unlike `external` declarations, `let` bindings don't get inlined at the call
point.

If the author of the binding doesn't want to use labeled arguments, they can
append an underscore to have them removed from the generated OCaml function:

```ocaml
let%js decodeURI : uri_:string -> string = "decodeURI($uri_)"
let _ : string = decodeURI "foo" (* no warning about a missing label ever *)
```

The preprocessor of `let%js` will check that type definitions to have at least
an arrow type. So in cases where before one would just have some abstract type
`t` in the external, now they would become `unit -> t`.

For example, the current external to `Math.PI`:

```ocaml
external pi : float = "PI" [@@mel.scope "Math"]
```

would be written as:

```ocaml
let%js pi : float = "Math.PI"
```

## `let%js.import`

The other extension introduced, `let%js.import`, is used for importing values
from JavaScript modules into the current OCaml module:

```ocaml
type t
let%js.import foo: t = "./bar"
```

Gets transformed into this JavaScript:

```js
import foo from "./bar";
```

It can leverage the OCaml destructuring feature to pick values from the imported
module, but all of them need type annotations:


```ocaml
type u
let%js.import {foo = (hey : string); bar: int} = "./bar"
```
Gets transformed into this JavaScript:

```js
import {foo as hey, bar} from "./bar";
```

Note there is no need to predefine a record type before using `let%js.import`,
as the record is used merely syntactically to be transformed into an `import`
statement.

## `let%js.obj`

Would be similar to `mel.obj` but as an extension applied to `let` bindings:

```ocaml
let%js.obj john = { name = "john"; age = 99 }
```

# Motivation

The current design of the bindings to JavaScript code in Melange has a few
shortcomings:

- They are not particularly user friendly, as writing attributes like
`mel.scope`, `mel.send`, `mel.module` is very different to what one would write
in JavaScript.

- They are not friendly to OCaml native compilation either, which makes writing
share libraries harder. The friction exists because Melange bindings support
externals with a simple type like `t`, while OCaml only supports externals with
arrow types like `t -> u`. One can process the AST to fix this, but given that
they are just plain `external` items, one can't leverage the existing
context-free rule for extensions infrastructure in ppxlib, and has to process
the full AST with a mapper.

- Another source of friction comes from the optimizations done by the compiler
in `external` statements. Melange compilation model is module-oriented, unlike
js_of_ocaml, which has an executable-oriented compilation model. In Melange,
users expect that the code referenced by an external function will be compiled
in the same module where the external is defined. But this assumption breaks if
the external is inlined in some other module due to these compiler
optimizations.

Besides trying to tackle the issues above, this proposal would also fix issues
like [#757](https://github.com/melange-re/melange/issues/757), that are caused
by some combination of attributes not being allowed in the current
implementation of bindings in Melange.

With the suggested design, the following attributes —and their corresponding
maintenance— in the Melange compiler could be eventually removed:

- `mel.module`
- `mel.get` and `mel.set`
- `mel.get_index` and `mel.set_index`
- `mel.send` and `mel.send.pipe`
- `mel.new`
- `mel.scope`
- `mel.splice` / `mel.variadic`

The `mel.uncurry` and `u` attributes could be replaced by a single attribute
`mel.called_from_js`. See the [related section](#meluncurry-and-u) below.

The `mel.obj` attribute could be replaced with `let%js.obj`, which would work
essentially in the same way. See more in the [related section](#melobj) below.

# Detailed design

## `let%js`

The processing of the `let` primitives decorated with the `js` extension would
have to do the following:

- Iterate through the types on the external.
- Parse the string primitive with the Flow parser (as it does right now for some
  extensions like `mel.raw`).
- Check that the string primitive contains valid `$` references to the labelled
  arguments, and handle errors properly.
- Finally, proceed to the conversion of the external into JS code, by adding
  wrapping `function` JavaScript statement with arguments and a `return`
  statement.

The implementation remains to be decided, but it might be possible to build upon
the existing `mel.raw` extension. It would look as follows.

A binding defined like in the basic example:

```ocaml
let%js decodeURI : uri:string -> string = "decodeURI($uri)"
```

Would be converted into something like this:

```ocaml
let decodeURI : uri:string -> string = [%mel.raw "function (uri) { return decodeURI(uri) }"]
```

As the PPX would wrap the string with `function` and `return`, handling multiple
assignments inside the same binding is not possible. For those cases, one can
continue to use `mel.raw`.

## `let%js.import`

The `let%js.import` extension would have to do some checks as well:
- first that the pattern passed to it is either a single identifier or a record
  destructuring
- if it's an identifier, check it has type annotation, if it's a record
  destructuring, check that all the fields have type annotations
- finally, tranform the expression into either `require` or `import` statements
  based on the chosen `melange.emit` configuration

## `let%js.obj`

Would work essentially as `mel.obj`.

---

To specify in depth the proposal, we will go through each of the existing
attributes, and compare how they would be written using the proposed design.

## Global bindings

Global bindings can remain available with regular `external` statements, but
they can also be represented in the new system for convenience when needed, or
in cases where the compiler inlining the external as an optimization is leading
to runtime errors.

Current:

```ocaml
external setTimeout : (unit -> unit) -> int -> timeoutID = "setTimeout"
```

Proposed:

```ocaml
let%js setTimeout : fn:(unit -> unit) -> ms:int -> timeoutID = {|setTimeout($fn, $ms)|}
```

## `mel.module`

Simple module binding would work by referencing the JavaScript module.

Current:

```ocaml
type path
external path : path = "path" [@@mel.module]
```

Proposed:

```ocaml
type path
let%js.import path = "path"
```

The choice of using `import` extension allows to transform this code into ES6
(`import`) or CommonJS (`require`) form, depending on the mode selected in
`melange.emit`.

For more complex bindings, like the ones passing a string to `mel.module` to
narrow the scope, one can use destructuring.

Current:

```ocaml
external dirname : string -> string = "dirname" [@@mel.module "path"]
let root = dirname "/User/github"
```

Proposed:

```ocaml
let%js.import { dirname : string -> string } = "path"
let root = dirname "/User/github"
```

If the name of the field imported starts with an invalid character in OCaml,
like uppercase characters, `mel.as` can be used:

```ocaml
let%js.import { foo : string [@mel.as "Foo"] } = "./bar"
```

## `mel.get` and `mel.set`

Current:

```ocaml
external set_title : document -> string -> unit = "title" [@@mel.set]
external get_title : document -> string = "title" [@@mel.get]
```

Proposed:

```ocaml
let%js set_title : doc:document -> title:string -> unit = "$doc.title = $title"
let%js get_title : doc:document -> string = "$doc.title"
```

## `mel.get_index` and `mel.set_index`

Current:

```ocaml
type t
external create : int -> t = "Int32Array" [@@mel.new]
external get : t -> int -> int = "" [@@mel.get_index]
external set : t -> int -> int -> unit = "" [@@mel.set_index]
```

Proposed:

```ocaml
type t
let%js create : length:int -> t = "new Int32Array($length)"
let%js get : arr:t -> pos:int -> int = "$arr[$pos]"
let%js set : arr:t -> pos:int -> value:int -> unit = "$arr[$pos] = $value"
```

Let's see another example, in combination with importing modules:

Before:

```ocaml
type t
external book : unit -> t = "Book" [@@mel.new] [@@mel.module]
let myBook = book ()
```

After:

```ocaml
type t
let%js.import book: t = "Book"
let%js create_book : ~t_:t -> unit -> t = "new $t_()"
let myBook = book |> create_book ()
```

## `mel.send` and `mel.send.pipe`

Current:

```ocaml
external get_by_id : document -> string -> Dom.element = "getElementById"
  [@@mel.send]
external get_by_id : string -> Dom.element = "getElementById"
  [@@mel.send.pipe: document]
```

Proposed:

```ocaml
let%js get_by_id : doc_:document -> id:string -> Dom.element = "$doc_.getElementById($id)"
let%js get_by_id : id:string -> doc_:document -> Dom.element = "$doc_.getElementById($id)"
```

## `mel.new`

Current:

```ocaml
type t
external create_date : unit -> t = "Date" [@@mel.new]
let date = create_date ()
```

Proposed:

```ocaml
type t
let%js create_date : unit -> t = "new Date()"
let date = create_date ()
```

## `mel.scope`

Before:

```ocaml
external node_env : string = "NODE_ENV" [@@mel.scope "process", "env"]
```

Proposed:

```ocaml
let%js node_env : string = "process.env.NODE_ENV"
```

## `mel.uncurry` and `u`

Uncurrying in Melange has historically been complicated, but there might be ways
to make it simpler to understand and use.

The need for uncurrying OCaml functions in Melange arises when both these
situations happen:
- A function written in OCaml is being passed to some JavaScript library through
  the bindings
- *And* the function can potentially be called from the JavaScript library
  itself

Sometimes only the first situation happens. For example, if we write bindings to
`React.useCallback` we do not need to care about uncurrying, because the `react`
JavaScript library itself will never call the callback, it will always be called
from the OCaml side.

To reflect this and help Melange users identify the scenarios where it's needed,
a attribute `mel.called_from_js` is introduced.

Before:

```ocaml
external map :
  'a array -> 'b array -> (('a -> 'b -> 'c)[@mel.uncurry]) -> 'c array = "map"
```

After:

```ocaml
let%js map :
    arr1:'a array ->
    arr2:'b array ->
    cb:(('a -> 'b -> 'c)[@mel.called_from_js]) ->
    'c array =
  {|map($arr1, $arr2, $cb)|}
```

When the PPX detects the usage of this attribute on arrow types in `let%js`
extensions, it will transform the generated code so the function passed is
transformed into its uncurried form, in a similar way than js_of_ocaml does with
its runtime function
[Js.wrap_callback](https://github.com/ocsigen/js_of_ocaml/blob/0fc2b735593f8b18bc5aa4342a3c79f4a39fd81f/lib/js_of_ocaml/js.mli#L160-L163).

Using `mel.raw` to show how the example above would look like:

```ocaml
let map :
    arr1:'a array ->
    arr2:'b array ->
    cb:('a -> 'b -> 'c) ->
    'c array =
  [%mel.raw
    "function (arr1, arr2, cb) { return map(arr1, arr2, Js.wrap_callback(cb)) }"]
```

## `mel.obj`

Before:

```ocaml
let john = [%mel.obj { name = "john"; age = 99 }]
let t = john##name
```

After:

```ocaml
let%js.obj john = { name = "john"; age = 99 }
let t = john##name
```

## `mel.variadic` 

Before:

```ocaml
external join : string array -> string = "join"
  [@@mel.module "path"] [@@mel.variadic]
let v = join [| "a"; "b" |]
```

After:

```ocaml
type path
let%js.import path: path = "path"
let%js join : t_:path -> paths:string array -> string = "$t_.join(...$paths)"
let v = path |> join ~paths:[| "a"; "b" |]
```

Or alternatively, if we want to import just the property `join` from `path`
module for leaner bundle size:

```ocaml
type join
let%js.import { join: join } = "path"
let%js call : t_:join -> paths:string array -> string = "$t_(...$paths)"
let v = join |> call ~paths:[| "a"; "b" |]
```

Another example, before:

```ocaml
type param
external executeCommand : string -> param array -> unit = ""
  [@@mel.scope "commands"] [@@mel.module "vscode"] [@@mel.variadic]

let f a b c = executeCommand "hi" [| a; b; c |]
```

After:

```ocaml
type commands
let%js.import { commands : commands } = "vscode"
let%js execute : t_:commands -> cmd:string -> args:param array -> unit = "$t_.executeCommand($cmd,...$args)"

let f a b c = commands |> execute ~cmd:"hi" ~args:[| a; b; c |]
```

# Drawbacks

The inlining in external definitions done by the OCaml compiler is lost.
However, the suggested design is purely additive, so the current implementation
of bindings could be left for cases when the extra performance is required.

# Alternatives

One alternative could be to implement a system for externals more similar to
Js_of_ocaml, where the primitive defines a function that has to exist in the
linked JavaScript at runtime.

It is unclear though how that would solve the problems listed in the
[motivation](#motivation) section.

# Adoption strategy

The proposal could be implemented on addition of the existing bindings system,
and they could coexist without issues. Libraries adopting the new system would
need to define a dependency on Melange constrained to the first version of it
that supports the new bindings system.

# How we teach this

- Update documentation site melange.re to include the new bindings system
- Implement tooling to convert from JavaScript code snippets to the bindings

# Unresolved questions

Regarding the implementation, it is unclear how the error handling will be done,
as well as the underlying usage of `mel.raw` to implement the `let%js`
extension.

It is also unclear if the PPX needs to be implemented as part of the Melange
compiler, or could be implemented outside of it first. At the very least, the
`called_from_js` attribute requires the addition of one extra function in the
Melange runtime.

Finally, the proposal does not covered yet how to migrate away from `mel.return`
and attributes used to annotate arguments in `external` definitions: `mel.int`,
`mel.string`, `mel.this` and `mel.unwrap`.

# References / mentions

The idea for the `let%js` extension in the proposal is based on
[rescript-lang/rescript-compiler#3618](https://github.com/rescript-lang/rescript-compiler/issues/3618),
which itself was based on
[fdopen/ppx_cstubs](https://github.com/fdopen/ppx_cstubs).

