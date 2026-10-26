JSON kind constructors stay separate from JSON values and local names.
ReScript #6317.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >       (target out)
  >       (libraries melange.js)
  >       (preprocess (pps melange.ppx))
  > 
  >       (module_systems (commonjs js) (es6 mjs)))
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
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > const fs = require('node:fs');
  > 
  > (async () => {
  >   for (const ext of ['js', 'mjs']) {
  >     const m = await import('./_build/default/out/input.'+ext);
  >     const code = fs.readFileSync('./_build/default/out/input.'+ext, 'utf8');
  > assert.deepEqual(m.checks(),Array(8).fill(true));
  > assert.equal(m.roundtrip(),'["x",1,true,null,{},[]]');
  > assert.equal(m.local._0,'local');
  > assert.notEqual(m.kind_string,m.kind_number);
  >     console.log(ext, 'controls: ok');
  >   }
  > 
  > 
  > })().catch(e => { console.error(e); process.exitCode=1; });
  > EOF
  $ node check.cjs
  js controls: ok
  mjs controls: ok
