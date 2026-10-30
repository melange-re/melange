Anonymous closures retain dynamic this, arguments, and constructor behavior.
ReScript #6945 and #7061.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > let callbacks = [|
  >   (fun x -> ([%raw "this.base"] : int) + x);
  >   (fun x -> ([%raw "arguments.length"] : int) + x)
  > |]
  > let nested seed = [| fun x -> seed + x + ([%raw "this.base"] : int) |]
  > let object_result = [| fun (x : int) -> [%mel.obj { value = x }] |]
  > let unit_callback = [| fun (x : int) -> Js.log x |]
  > let constructor = [| fun (_x : int) -> ignore ([%raw "this.value = _x"] : int) |]
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js');
  > assert.equal(m.callbacks[0].call({base:10},4), 14);
  > assert.equal(m.callbacks[1](4,8,9), 7);
  > assert.equal(m.nested(3)[0].call({base:10},4), 17);
  > assert.deepEqual(m.object_result[0](7), {value:7});
  > const old = console.log, seen = [];
  > try { console.log = x => seen.push(x); assert.equal(m.unit_callback[0](9), undefined); }
  > finally { console.log = old; }
  > assert.deepEqual(seen, [9]);
  > assert.equal(new m.constructor[0](6).value, 6);
  > EOF
