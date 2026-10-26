# Tagged templates

Bind a JavaScript tag as a value, then use `Js.TaggedTemplate.apply`:

```ocaml
external tag : (int, string) Js.TaggedTemplate.t = "tag"
  [@@mel.module "./tag.js"]

let render value =
  Js.TaggedTemplate.apply tag [|"value: "; "!"|] [|value|]
```

This emits a native tagged template equivalent to:

```js
(0, TagJs.tag)`value: ${value}!`;
```

The two type parameters describe interpolation values and the result. Importing
a tag uses the usual FFI value bindings, including relative module imports.

Supply all three arguments together. Both arrays must be literal arrays, every
fragment must be a string literal, and there must be one more fragment than
interpolation value. Dynamic arrays and partial application produce a compiler
diagnostic. A wrapper with literal arrays can itself be partially applied.

Fragments describe the cooked strings passed to the tag. Ordinary OCaml strings
retain byte semantics; `{js|...|js}` literals support JavaScript Unicode strings.
Melange escapes backticks, `${`, backslashes, and control characters. The tag's
`.raw` array contains those generated JavaScript escapes, rather than the OCaml
source spelling. Use a raw JavaScript binding when a tag requires specific raw
source text, including invalid JavaScript escape sequences.

Calls preserve tag effects, interpolation order, the frozen template array,
and its identity at each source site. Functions containing templates are kept
out of inlining, even with `[@@inline always]`, to preserve that identity.

Tags are called as function values, without a JavaScript receiver. Bind a
receiver explicitly when required:

```ocaml
external bind : ('a, 'b) Js.TaggedTemplate.t -> 'receiver ->
  ('a, 'b) Js.TaggedTemplate.t = "bind" [@@mel.send]

let render_with_receiver tag receiver value =
  Js.TaggedTemplate.apply (bind tag receiver) [|""; ""|] [|value|]
```
