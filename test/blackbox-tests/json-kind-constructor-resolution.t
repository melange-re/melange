JSON kind constructors stay separate from JSON values and local names.
ReScript #6317.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > type local = String of string | Number of int | Null
  > let kind_string = Js.Json.String
  > let kind_number = Js.Json.Number
  > let local = String "local"
  > let checks () =
  >   let open Js.Json in
  >   [| test (string "s") String; test (number 1.) Number;
  >      test (boolean false) Boolean; test null Null;
  >      test (array [||]) Array; test (object_ (Js.Dict.empty ())) Object;
  >      not (test (string "s") Number); not (test null Object) |]
  > let roundtrip () =
  >   let j = Js.Json.parseExn {|["x",1,true,null,{},[]]|} in
  >   Js.Json.stringify j
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js');
  > assert.deepEqual(m.checks(), Array(8).fill(true));
  > assert.equal(m.roundtrip(), '["x",1,true,null,{},[]]');
  > assert.equal(m.local._0, 'local');
  > assert.notEqual(m.kind_string, m.kind_number);
  > EOF
