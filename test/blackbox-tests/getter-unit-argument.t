A getter needs an object argument; an erased unit argument must be diagnosed.

  $ . ./setup.sh
  $ cat > invalid.ml <<'EOF'
  > external get : unit -> 'a = "value" [@@mel.get]
  > let result = get ()
  > EOF
  $ melc -alert -unprocessed -ppx melppx invalid.ml -o invalid.js 2> error.log
  [2]
  $ sed -E 's/line [0-9]+/line LINE/g; s/characters [0-9]+-[0-9]+/characters RANGE/g; /^[[:space:]]*$/d' error.log
  File "invalid.ml", line LINE, characters RANGE:
  1 | external get : unit -> 'a = "value" [@@mel.get]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `[@mel.get]' requires an object argument, not an erased unit argument

An interface must reject the invalid declaration before any call is compiled.

  $ head -n 1 invalid.ml > invalid.mli
  $ melc -alert -unprocessed -ppx melppx -c invalid.mli
  File "invalid.mli", line 1, characters 0-47:
  1 | external get : unit -> 'a = "value" [@@mel.get]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `[@mel.get]' requires an object argument, not an erased unit argument
  [2]

Valid polymorphic and scoped getters still read their receiver once.

  $ cat > valid.ml <<'EOF'
  > type obj
  > external get : obj -> 'a = "value" [@@mel.get]
  > external scoped : obj -> int = "value" [@@mel.get] [@@mel.scope "nested"]
  > let read object_ = get object_, scoped object_
  > EOF
  $ melc -ppx melppx valid.ml -o valid.js
  $ node <<'EOF'
  > const t = require('./valid.js');
  > let reads = 0;
  > console.log(t.read({get value() { ++reads; return 3; }, nested: {value: 4}}), reads);
  > EOF
  [ 3, 4 ] 1
