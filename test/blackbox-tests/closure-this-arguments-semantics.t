Anonymous closures retain dynamic this, arguments, and constructor behavior.
ReScript #6945 and #7061.

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
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > const fs = require('node:fs');
  > 
  > (async () => {
  >   for (const ext of ['js', 'mjs']) {
  >     const m = await import('./_build/default/out/input.'+ext);
  >     const code = fs.readFileSync('./_build/default/out/input.'+ext, 'utf8');
  > assert.equal(m.callbacks[0].call({base:10},4),14);
  > assert.equal(m.callbacks[1](4,8,9),7);
  > assert.equal(m.nested(3)[0].call({base:10},4),17);
  > assert.deepEqual(m.object_result[0](7),{value:7});
  > const old=console.log; const seen=[];
  > try { console.log=x=>seen.push(x); assert.equal(m.unit_callback[0](9),undefined); }
  > finally { console.log=old; }
  > assert.deepEqual(seen,[9]);
  > assert.equal(new m.constructor[0](6).value,6);
  > assert.match(code,/function/);
  >     console.log(ext, 'controls: ok');
  >   }
  > 
  > 
  > })().catch(e => { console.error(e); process.exitCode=1; });
  > EOF
  $ node check.cjs
  js controls: ok
  mjs controls: ok
