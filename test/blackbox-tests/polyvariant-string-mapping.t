ReScript #6903: explicit string mappings round-trip; coercions do not apply representation attributes.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx))
  >  (compile_flags :standard --mel-cross-module-opt))
  > EOF
  $ cat > input.ml <<'EOF'
  > type language = [ `OCaml | `ReScript [@mel.as "js"] ] [@@deriving jsConverter]
  > external mapped : ([ `OCaml | `ReScript [@mel.as "js"] ] [@mel.string]) -> string = "auditIdentity"
  > let direct = mapped `ReScript
  > let indirect value = mapped value
  > let original : language = `ReScript
  > let widened = (original :> [ language | `Other ])
  > let mapped_value = languageToJs original
  > let unmapped_value = languageToJs `OCaml
  > let roundtrip = languageFromJs "js" = Some original
  > let old_name_rejected = languageFromJs "ReScript" = None
  > let unknown_rejected = languageFromJs "missing" = None
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require("node:assert/strict");
  > globalThis.auditIdentity = value => value;
  > const m = require("./_build/default/out/input.js");
  > assert.equal(m.direct, "js");
  > assert.equal(m.indirect(m.original), "js");
  > assert.equal(m.original, m.widened);
  > assert.equal(m.mapped_value, "js");
  > assert.equal(m.unmapped_value, "OCaml");
  > assert.equal(m.roundtrip, true);
  > assert.equal(m.old_name_rejected, true);
  > assert.equal(m.unknown_rejected, true);
  > EOF

  $ cat > coercion.ml <<'EOF'
  > type language = [ `OCaml | `ReScript ]
  > let to_string (value : language) = (value :> string)
  > EOF
  $ melc -ppx melppx -mel-stop-after-cmj coercion.ml
  File "coercion.ml", line 2, characters 35-52:
  2 | let to_string (value : language) = (value :> string)
                                         ^^^^^^^^^^^^^^^^^
  Error: Type language = [ `OCaml | `ReScript ] is not a subtype of string
  [2]

  $ cat > unused.ml <<'EOF'
  > type language = [ `OCaml | `ReScript [@mel.as "js"] ]
  > EOF
  $ melc -ppx melppx -mel-stop-after-cmj unused.ml 2>&1 | sed '/^$/d'
  File "unused.ml", line 1, characters 39-45:
  1 | type language = [ `OCaml | `ReScript [@mel.as "js"] ]
                                             ^^^^^^
  Alert unused: Unused attribute [@mel.as]
  This means such annotation is not annotated properly.
  For example, some annotations are only meaningful in externals
