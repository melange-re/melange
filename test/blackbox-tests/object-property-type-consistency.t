ReScript #8584 / #8597: open rows can infer inconsistent getter/setter types.
This records the unsound baseline and the supported object APIs a fix must preserve.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > let break_soundness (o : < x : int; .. > Js.t) : int =
  >   o##x #= "hello";
  >   o##x
  > external obj : < x : int; .. > Js.t = "auditObject"
  > let result : int = break_soundness obj
  > let update (o : < x : int [@mel.set] > Js.t) = o##x #= 3; o##x
  > let write_only (o : < x : int [@mel.set {no_get}] > Js.t) = o##x #= 7
  > type nullable = < x : int [@mel.get {null; undefined}] [@mel.set] > Js.t
  > let read_nullable (o : nullable) = Js.Nullable.toOption o##x
  > let write_nullable (o : nullable) = o##x #= 4
  > EOF
  $ melc -ppx melppx -o input.js input.ml
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > globalThis.auditObject = {x: 1};
  > const m = require("./input.js");
  > assert.equal(m.result, "hello");
  > console.log("declared int, actual", typeof m.result);
  > const ordinary = {x: 1};
  > assert.equal(m.update(ordinary), 3);
  > let written;
  > const setter = {set x(value) {written = value;}, get x() {throw new Error("unexpected read");}};
  > m.write_only(setter);
  > assert.equal(written, 7);
  > for (const x of [null, undefined]) {
  >   const object = {x};
  >   assert.equal(m.read_nullable(object), undefined);
  >   m.write_nullable(object);
  >   assert.equal(m.read_nullable(object), 4);
  > }
  > console.log("mutable, write-only and nullable controls: ok");
  > EOF
  $ node check.cjs
  declared int, actual string
  mutable, write-only and nullable controls: ok

Closed rows reject unrelated writes, read-only writes, and the upstream coercion.

  $ cat > reject.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > const fs = require("node:fs");
  > const {spawnSync} = require("node:child_process");
  > for (const source of [
  >   'let bad (o : < x : int [@mel.set] > Js.t) = o##x #= "hello"',
  >   'let bad (o : < x : int > Js.t) = o##x #= 1',
  >   'let bad (o : < x : int [@mel.set] > Js.t) = let r = (o :> < x : int > Js.t) in r##x #= 1'
  > ]) {
  >   fs.writeFileSync("negative.ml", source + "\n");
  >   const r = spawnSync("melc", ["-ppx", "melppx", "-o", "negative.js", "negative.ml"], {encoding:"utf8"});
  >   assert.equal(r.status, 2, r.stderr);
  >   assert.ok(r.stderr.includes("type"), r.stderr);
  >   assert.ok(!r.stderr.includes("Assert_failure"), r.stderr);
  > }
  > console.log("closed-row invalid writes rejected");
  > EOF
  $ node reject.cjs
  closed-row invalid writes rejected
