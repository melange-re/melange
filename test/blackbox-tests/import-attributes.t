The baseline compiler rejects import attributes on FFI declarations.
The implementation in #2111 covers emitted attributes and loading behavior.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > external imported : Js.Json.t = "default" [@@mel.module "./fixture.json"]
  >   [@@mel.import_attributes [("type", "json")]]
  > EOF
  $ melc -alert -unused -ppx melppx --mel-module-type es6 -o input.mjs input.ml 2>error
  [2]
  $ sed -n '4p' error
  Error (alert unprocessed): `[@mel.*]' attributes found in external declaration. Did you forget to preprocess with `melange.ppx'?
