ReScript #9045-#9047 target overlapping multi-constructor untagged variants.
Melange rejects that representation and keeps ordinary constructor dispatch distinct.

  $ . ./setup.sh
  $ cat > invalid.ml <<'EOF'
  > type t = Literal | Text of string [@@unboxed]
  > EOF
  $ melc -o invalid.js invalid.ml
  File "invalid.ml", line 1, characters 0-45:
  1 | type t = Literal | Text of string [@@unboxed]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: This type cannot be unboxed because it has more than one constructor.
  [2]
  $ cat > valid.ml <<'EOF'
  > type 'a box = Box of 'a [@@unboxed]
  > let unbox (Box x) = x
  > type t = Literal [@mel.as "literal"] | Text of string | Number of int
  > let classify = function
  >   | Literal -> "literal constructor"
  >   | Text "literal" -> "text payload"
  >   | Text _ -> "other text"
  >   | Number _ -> "number"
  > let folded = [|classify Literal; classify (Text "literal"); classify (Number 0)|]
  > let dynamic = Array.map classify [|Sys.opaque_identity Literal; Sys.opaque_identity (Text "literal"); Sys.opaque_identity (Number 0)|]
  > let integer = unbox (Box 42)
  > let text = unbox (Box "literal")
  > let counter = ref 0
  > let same_body x = match x with
  >   | Literal | Number _ -> incr counter
  >   | Text _ -> incr counter
  > let () = Array.iter same_body [|Literal; Text "literal"; Number 0|]
  > let effects = !counter
  > EOF
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (modules valid)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ dune build @melange
  $ node -e 'const assert = require("node:assert/strict"); const m = require("./_build/default/out/valid.js"); assert.deepEqual(m.folded, ["literal constructor", "text payload", "number"]); assert.deepEqual(m.dynamic, m.folded); assert.equal(m.integer, 42); assert.equal(m.text, "literal"); assert.equal(m.effects, 3); console.log("folded/runtime dispatch, unboxing and effects: ok");'
  folded/runtime dispatch, unboxing and effects: ok
