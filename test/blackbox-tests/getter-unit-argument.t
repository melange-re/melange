A getter needs an object argument; an erased unit argument must be diagnosed.
The initial snapshot records the backend assertion.

  $ . ./setup.sh
  $ cat > invalid.ml <<'EOF'
  > external get : unit -> 'a = "value" [@@mel.get]
  > let result = get ()
  > EOF
  $ melc -ppx melppx invalid.ml -o invalid.js 2> error.log; status=$?; echo "exit: $status"
  exit: 125
  $ sed -E 's/line [0-9]+/line LINE/g; s/characters [0-9]+-[0-9]+/characters RANGE/g' error.log
  melc: internal error, uncaught exception:
        File "jscomp/core/lam_compile_external_call.ml", line LINE, characters RANGE: Assertion failed
        

An interface must reject the invalid declaration before any call is compiled.

  $ head -n 1 invalid.ml > invalid.mli
  $ melc -ppx melppx -c invalid.mli

Valid polymorphic and scoped getters still read their receiver once.

  $ cat > valid.ml <<'EOF'
  > type obj
  > external get : obj -> 'a = "value" [@@mel.get]
  > external scoped : obj -> int = "value" [@@mel.get] [@@mel.scope "nested"]
  > let read object_ = get object_, scoped object_
  > EOF
  $ melc -ppx melppx valid.ml -o valid.js
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const t = require('./valid.js');
  > let reads = 0;
  > assert.deepEqual(t.read({get value() { ++reads; return 3; }, nested: {value: 4}}), [3, 4]);
  > assert.equal(reads, 1);
  > console.log('valid getters: ok');
  > EOF
  valid getters: ok
