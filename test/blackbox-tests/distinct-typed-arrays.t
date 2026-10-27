ReScript #8955 / #9050: typed-array modules keep distinct nominal types.

  $ . ./setup.sh
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > const fs = require("node:fs");
  > const {spawnSync} = require("node:child_process");
  > for (const [a, b] of [["Int8Array", "Uint8Array"], ["Uint8Array", "Uint8ClampedArray"], ["Float32Array", "Float64Array"]]) {
  >   for (const [from, to] of [[a,b],[b,a]]) {
  >     fs.writeFileSync("negative.ml", `let wrong (x : Js.Typed_array.${from}.t) : Js.Typed_array.${to}.t = x\n`);
  >     const r = spawnSync("melc", ["-ppx", "melppx", "-o", "negative.js", "negative.ml"], {encoding:"utf8"});
  >     assert.equal(r.status, 2, r.stderr);
  >     assert.ok(r.stderr.includes("has type") && r.stderr.includes(from) && r.stderr.includes(to), r.stderr);
  >   }
  > }
  > fs.writeFileSync("wrong_case.ml", "type ta = I8 of Js.Typed_array.Int8Array.t | U8 of Js.Typed_array.Uint8Array.t\nlet wrong = I8 (Js.Typed_array.Uint8Array.make [|1|])\n");
  > const r = spawnSync("melc", ["-ppx", "melppx", "-o", "wrong_case.js", "wrong_case.ml"], {encoding:"utf8"});
  > assert.equal(r.status, 2, r.stderr);
  > assert.ok(r.stderr.includes("Int8Array.t") && r.stderr.includes("Uint8Array.t"), r.stderr);
  > console.log("six cross-type assignments and the wrong variant payload rejected");
  > EOF
  $ node check.cjs
  six cross-type assignments and the wrong variant payload rejected

Valid arrays retain their JavaScript class, signedness, and constructor dispatch.

  $ cat > valid.ml <<'EOF'
  > type ta = I8 of Js.Typed_array.Int8Array.t | U8 of Js.Typed_array.Uint8Array.t
  > let i8 = Js.Typed_array.Int8Array.make [|255|]
  > let u8 = Js.Typed_array.Uint8Array.make [|255|]
  > let copy_i8 = Js.Typed_array.Int8Array.copy i8
  > let copy_u8 = Js.Typed_array.Uint8Array.copy u8
  > let classify = function I8 _ -> "i8" | U8 _ -> "u8"
  > let classes = [|classify (I8 i8); classify (U8 u8)|]
  > EOF
  $ melc -ppx melppx -o valid.js valid.ml
  $ node -e 'const assert = require("node:assert/strict"); const m = require("./valid.js"); assert.ok(m.i8 instanceof Int8Array); assert.ok(m.copy_i8 instanceof Int8Array); assert.ok(m.u8 instanceof Uint8Array); assert.ok(m.copy_u8 instanceof Uint8Array); assert.equal(m.copy_i8[0], -1); assert.equal(m.copy_u8[0], 255); assert.deepEqual(m.classes, ["i8", "u8"]); console.log("typed-array runtime controls: ok");'
  typed-array runtime controls: ok
