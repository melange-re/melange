Known Some payloads need no wrap/unwrap round trip. The initial snapshot records redundant calls.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit (target output) (alias melange))
  > EOF
  $ cat > input.ml <<'EOF'
  > let nested y = match Some y with Some (Some n) -> n | Some None -> 0 | None -> -1
  > let poly y = match Some y with Some v -> [|v|] | None -> [||]
  > let identity y = match Some y with Some v -> v == y | None -> false
  > let effectful next = match Some (next ()) with Some v -> [|v|] | None -> [||]
  > let captured () =
  >   let r = ref None in
  >   let opt = Some !r in
  >   r := Some 7;
  >   match opt with Some v -> v | None -> Some 8
  > let deep = Some (Some None)
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > const t = require('./_build/default/output/input.js');
  > assert.equal(t.nested(undefined), 0);
  > assert.equal(t.nested(7), 7);
  > for (const payload of [undefined, null, false, 0, {}, t.deep]) {
  >   assert.deepEqual(t.poly(payload)[0], payload);
  >   if (payload !== t.deep) assert.equal(t.identity(payload), true);
  >   let calls = 0;
  >   assert.deepEqual(t.effectful(() => { calls++; return payload; })[0], payload);
  >   assert.equal(calls, 1);
  > }
  > assert.equal(t.captured(), undefined);
  > for (const name of ['nested', 'poly']) {
  >   const code = t[name].toString();
  >   console.log(name, 'wrap:', /\.some\(/.test(code), 'unwrap:', /\.valFromOption\(/.test(code));
  > }
  > console.log('nested options, identity, effects and capture: ok');
  > EOF
  $ node check.cjs
  nested wrap: true unwrap: true
  poly wrap: true unwrap: true
  nested options, identity, effects and capture: ok
