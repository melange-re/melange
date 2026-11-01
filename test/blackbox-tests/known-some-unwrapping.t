Known Some payloads need no wrap/unwrap round trip.

  $ . ./setup.sh
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
  $ melc input.ml -o input.js
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const t = require('./input.js');
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
  > console.log(t.nested.toString());
  > console.log(t.poly.toString());
  > EOF
  function nested(y) {
    const match = Caml_option.some(y);
    const n = Caml_option.valFromOption(match);
    if (n !== undefined) {
      return n;
    } else {
      return 0;
    }
  }
  function poly(y) {
    const v = Caml_option.some(y);
    return [Caml_option.valFromOption(v)];
  }
