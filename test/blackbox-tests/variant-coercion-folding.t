Remapped variant constants must agree with their emitted JavaScript values.
The identity external exposes the explicitly chosen integer representation.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (preprocess (pps melange.ppx))
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ cat > input.ml <<'EOF'
  > type flag = A [@mel.as 0] | B [@mel.as 2] | C [@mel.as 7]
  > external to_int : flag -> int = "%identity"
  > external read : unit -> flag = "readFlag"
  > let direct = to_int B
  > let constants = [|0 lor to_int B; to_int B + 0; - to_int B;
  >   to_int B land 3; to_int B lxor 3; to_int B lsl 1;
  >   to_int B lsr 1; to_int B asr 1; to_int B mod 2; to_int B / 2|]
  > let runtime x = 0 lor to_int x
  > let cast_match () = match to_int B with 0 -> 10 | 2 -> 20 | 7 -> 70 | _ -> -1
  > let variant_match = function A -> 10 | B -> 20 | C -> 70
  > let variant_constant () = variant_match B
  > let effectful () = to_int (read ()) lor 0
  > type other = Zero [@mel.as 8] | One [@mel.as 0]
  > external other_int : other -> int = "%identity"
  > let zero = other_int One + 0
  > let ordinary = (2 lor 4) + 1
  > let make = function 0 -> A | 1 -> B | 2 -> C | _ -> A
  > type gate = Open [@mel.as true] | Closed [@mel.as false]
  > external to_bool : gate -> bool = "%identity"
  > let bools = [|if to_bool Open then 1 else 2; if to_bool Closed then 1 else 2|]
  > let character () = let text = "abcd" in text.[to_int B]
  > external record : int -> unit = "recordIndex"
  > let loop limit = for i = 0 to limit - to_int B do record i done
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > (async () => {
  >   for (const [format, t] of [['CommonJS', require('./_build/default/out/input.js')], ['ESM', await import('./_build/default/out/input.mjs')]]) {
  >     assert.equal(t.direct, 2);
  >     assert.equal(t.runtime(t.direct), 2);
  >     assert.deepEqual([0, 2, 7].map(t.variant_match), [10, 20, 70]);
  >     assert.equal(t.variant_constant(), 20);
  >     let reads = 0;
  >     global.readFlag = () => { reads++; return 7; };
  >     assert.equal(t.effectful(), 7);
  >     assert.equal(reads, 1);
  >     assert.equal(t.ordinary, 7);
  >     const indices = [];
  >     global.recordIndex = i => indices.push(i);
  >     t.loop(4);
  >     console.log(format + ': ' + JSON.stringify([t.constants, t.cast_match(), t.zero, [0,1,2].map(t.make), t.bools, t.character(), indices]));
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  CommonJS: [[2,2,-2,2,1,4,1,1,0,1],20,0,[0,2,7],[1,2],99,[0,1,2]]
  ESM: [[2,2,-2,2,1,4,1,1,0,1],20,0,[0,2,7],[1,2],99,[0,1,2]]
