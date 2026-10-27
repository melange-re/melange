Switch default deduplication preserves result and control-flow effects.
ReScript #6671/#6672/#6908, including closed polymorphic variants and nested matches.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >       (target out)
  >       (libraries melange.js)
  >       (preprocess (pps melange.ppx))
  > 
  >       (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ cat > input.ml <<'EOF'
  > let classify x = match x with 2 -> 20 | 5 -> 50 | 8 -> 80 | _ -> 0
  > let explicit x = match x with 0 -> 0 | 1 -> 0 | 2 -> 20 | 3 -> 0 | 5 -> 50 | _ -> 0
  > external hit : int -> unit = "auditSwitchHit"
  > let effectful x =
  >   let result = match x with 0 -> hit 9; 0 | 1 -> hit 9; 0 | 2 -> hit 2; 20 | 5 -> hit 5; 50 | _ -> hit 9; 0 in
  >   hit 99; result
  > let raising x = match x with 2 -> 20 | 5 -> 50 | 8 -> 80 | _ -> failwith "default"
  > type t = [ `T1 | `T2 | `T3 | `T4 | `T5 ]
  > let to_string : t -> string = function `T1 -> "T1" | `T2 -> "T2" | `T3 -> "T3" | `T4 -> "T4" | `T5 -> "T5"
  > let wildcard = function `T1 -> 1 | `T3 -> 3 | _ -> 0
  > let nested x y = match x, y with `T1, Some 1 -> 11 | `T1, _ -> 10 | `T3, Some n -> n | _ -> 0
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > const fs = require('node:fs');
  > globalThis.auditSwitchHit=x=>{ globalThis.auditSwitchEffects.push(x); };
  > (async () => {
  >   for (const ext of ['js', 'mjs']) {
  >     const m = await import('./_build/default/out/input.'+ext);
  >     const code = fs.readFileSync('./_build/default/out/input.'+ext, 'utf8');
  > for(let i=-1;i<=10;i++) {
  >   assert.equal(m.classify(i),({2:20,5:50,8:80})[i]||0);
  >   assert.equal(m.explicit(i),({2:20,5:50})[i]||0);
  >   globalThis.auditSwitchEffects=[];
  >   assert.equal(m.effectful(i),({2:20,5:50})[i]||0);
  >   assert.deepEqual(globalThis.auditSwitchEffects,[(i===2||i===5)?i:9,99]);
  > }
  > assert.equal(m.raising(8),80); assert.throws(()=>m.raising(7));
  > for (const tag of ["T1", "T2", "T3", "T4", "T5"]) {
  >   assert.equal(m.to_string(tag), tag);
  >   assert.equal(m.wildcard(tag), tag === "T1" ? 1 : tag === "T3" ? 3 : 0);
  >   for (const value of [undefined, -1, 0, 1, 4]) {
  >     assert.equal(m.nested(tag, value), tag === "T1" ? value === 1 ? 11 : 10 : tag === "T3" && value !== undefined ? value : 0);
  >   }
  > }
  > const body=code.slice(code.indexOf('function classify'),code.indexOf('function explicit'));
  > assert.equal((body.match(/case /g)||[]).length,3);
  >     console.log(ext, 'controls: ok');
  >   }
  > 
  > 
  > })().catch(e => { console.error(e); process.exitCode=1; });
  > EOF
  $ node check.cjs
  js controls: ok
  mjs controls: ok
