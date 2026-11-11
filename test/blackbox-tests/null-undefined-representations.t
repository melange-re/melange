ReScript #7112: cover null undefined representations.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > let null_value = Js.null
  > let undefined_value = Js.undefined
  > let null_option x = Js.Null.fromOption x
  > let undefined_option x = Js.Undefined.fromOption x
  > let map_null x = Js.Null.map ~f:(fun [@u] x -> x + 1) x
  > let bind_null x = Js.Null.bind ~f:(fun [@u] x -> Js.Null.return (x + 1)) x
  > let decode_null x = Js.Json.decodeNull x
  > let decode_object x = Js.Json.decodeObject x
  > let null_test x = Js.Json.test x Js.Json.Null
  > let object_test x = Js.Json.test x Js.Json.Object
  > type sentinel = Null [@mel.as null] | Undefined [@mel.as undefined] | Value of int
  > let null_sentinel = Null
  > let undefined_sentinel = Undefined
  > let sentinel_tag = function Null -> 0 | Undefined -> 1 | Value _ -> 2
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js');
  > assert.equal(m.null_value, null);
  > assert.equal(m.undefined_value, undefined);
  > assert.equal(m.null_option(undefined), null);
  > assert.equal(m.null_option(7), 7);
  > assert.equal(m.undefined_option(undefined), undefined);
  > assert.deepEqual([m.map_null(null),m.bind_null(null),m.map_null(7),m.bind_null(7)], [null,null,8,8]);
  > assert.deepEqual([m.decode_null(null),m.decode_null(undefined)], [null,undefined]);
  > assert.deepEqual([m.decode_object(null),m.decode_object(undefined),m.decode_object({})], [undefined,undefined,{}]);
  > assert.deepEqual([m.null_test(null),m.null_test(undefined),m.object_test(null),m.object_test({})], [true,false,false,true]);
  > assert.deepEqual([m.null_sentinel,m.undefined_sentinel,m.sentinel_tag(null),m.sentinel_tag(undefined)], [null,undefined,0,1]);
  > EOF
