Equal switch bodies must remain correct across constant and block dispatch.
ReScript #6792 uses untagged object/array unions, which Melange does not implement.
These tests cover Melange's tagged dispatch, assignments, effects and tail calls.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > type obj = {name : string}
  > type t = Empty | Done | Flag | Object of obj | Array of int array | Date of float
  > let values = [| Empty; Done; Flag; Object {name = "hello"}; Array [|1; 2|]; Date 1. |]
  > let classify = function
  >   | Empty -> "shared"
  >   | Done -> "shared"
  >   | Flag -> "flag"
  >   | Object _ -> "shared"
  >   | Array _ -> "shared"
  >   | Date _ -> "date"
  > external hit : int -> unit = "switchHit"
  > let effects x =
  >   (match x with
  >   | Empty -> hit 1
  >   | Done -> hit 1
  >   | Flag -> hit 2
  >   | Object _ -> hit 1
  >   | Array _ -> hit 1
  >   | Date _ -> hit 2);
  >   hit 3
  > let assigned x =
  >   let result = match x with
  >     | Empty -> 10 | Done -> 10 | Flag -> 20
  >     | Object _ -> 10 | Array _ -> 10 | Date _ -> 20
  >   in
  >   result + 1
  > let with_default = function Object _ -> "payload" | Array _ -> "payload" | _ -> "default"
  > let rec loop i acc =
  >   if i = Array.length values then acc
  >   else
  >     match values.(i) with
  >     | Empty -> loop (i + 1) (acc + 1)
  >     | Done -> loop (i + 1) (acc + 1)
  >     | Flag -> loop (i + 1) (acc + 2)
  >     | Object _ -> loop (i + 1) (acc + 1)
  >     | Array _ -> loop (i + 1) (acc + 1)
  >     | Date _ -> loop (i + 1) (acc + 2)
  > type special = Null [@mel.as null] | Undefined [@mel.as undefined] | Box of int
  > let special = function Null -> 1 | Undefined -> 1 | Box _ -> 2
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require("node:assert/strict");
  > let hits = [];
  > globalThis.switchHit = n => { hits.push(n); };
  > const m = require("./_build/default/out/input.js");
  > assert.deepEqual(m.values.map(m.classify), ["shared", "shared", "flag", "shared", "shared", "date"]);
  > assert.deepEqual(m.values.map(m.assigned), [11, 11, 21, 11, 11, 21]);
  > assert.deepEqual(m.values.map(m.with_default), ["default", "default", "default", "payload", "payload", "default"]);
  > for (let i = 0; i < m.values.length; i++) {
  >   hits = [];
  >   m.effects(m.values[i]);
  >   assert.deepEqual(hits, [i === 2 || i === 5 ? 2 : 1, 3]);
  > }
  > assert.equal(m.loop(0, 0), 8);
  > assert.equal(m.special(null), 1);
  > assert.equal(m.special(undefined), 1);
  > assert.equal(m.special({_0: 7}), 2);
  > const error = {};
  > globalThis.switchHit = () => { throw error; };
  > for (const value of m.values) assert.throws(() => m.effects(value), e => e === error);
  > EOF
