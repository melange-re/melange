Object returns remain valid JavaScript through closures and nested options.
ReScript #7013 fixes arrow printing; Melange emits function bodies with return.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > type obj = {a : int; b : int}
  > let f1 () = (fun () -> Some {a = 1; b = 2}) [@u]
  > let f2 () = Some (Some (Some {a = 1; b = 2}))
  > let f3 () = Some (Some None)
  > let read_three = function
  >   | None -> 0
  >   | Some None -> 1
  >   | Some (Some None) -> 2
  >   | Some (Some (Some {a; b})) -> a + b
  > let nest x = Some (Some (Some x))
  > let same_payload expected = function
  >   | Some (Some (Some actual)) -> actual == expected
  >   | _ -> false
  > external hit : int -> int = "optionHit"
  > let closure () =
  >   let a = hit 1 in
  >   (fun () ->
  >     let b = hit 2 in
  >     Some {a; b}) [@u]
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require("node:assert/strict");
  > let hits = [];
  > globalThis.optionHit = n => { hits.push(n); return n; };
  > const m = require("./_build/default/out/input.js");
  > const f = m.f1();
  > assert.deepEqual(f(), {a: 1, b: 2});
  > assert.deepEqual(m.f2(), {a: 1, b: 2});
  > assert.equal(m.read_three(m.f2()), 3);
  > assert.equal(m.read_three(m.f3()), 2);
  > assert.notEqual(m.f3(), undefined);
  > for (const value of [undefined, null, {a: 7, b: 8}, [1, 2], () => 3]) {
  >   assert.equal(m.same_payload(value, m.nest(value)), true);
  > }
  > hits = [];
  > const captured = m.closure();
  > assert.deepEqual(hits, [1]);
  > assert.deepEqual(captured(), {a: 1, b: 2});
  > assert.deepEqual(captured(), {a: 1, b: 2});
  > assert.deepEqual(hits, [1, 2, 2]);
  > const error = {};
  > globalThis.optionHit = () => { throw error; };
  > assert.throws(() => captured(), e => e === error);
  > assert.throws(() => m.closure(), e => e === error);
  > EOF
