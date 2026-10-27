ReScript #6569/#6570: unrelated extension names must not share a global counter.
Fresh processes load separately compiled modules in opposite orders. Generative
functor applications must still create distinct constructors within one runtime.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx))
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ echo 'type t = ..' > types.ml
  $ cat > a.ml <<'EOF'
  > type Types.t += A of int
  > exception E of int
  > external init : string -> unit = "auditInit"
  > let () = init "a"
  > let value = A 1
  > let exn_value = E 11
  > EOF
  $ cat > b.ml <<'EOF'
  > type Types.t += B of int
  > exception E of int
  > external init : string -> unit = "auditInit"
  > let () = init "b"
  > let value = B 2
  > let exn_value = E 22
  > EOF
  $ cat > loader.ml <<'EOF'
  > let load_a () = Js.import A.value
  > let load_b () = Js.import B.value
  > EOF
  $ cat > matcher.ml <<'EOF'
  > module Alias = A
  > exception Rebound = Alias.E
  > let extension = function A.A n -> n | B.B n -> n | _ -> -1
  > let exception_ = function Rebound n -> n | B.E n -> n | _ -> -1
  > module Make () = struct
  >   type Types.t += Local of int
  >   exception Local_exn of int
  >   let value = Local 1
  >   let exn_value = Local_exn 1
  > end
  > let generative () =
  >   let module X = Make () in
  >   let module Y = Make () in
  >   let wrong_extension = match Y.value with X.Local _ -> true | _ -> false in
  >   let wrong_exception = match Y.exn_value with X.Local_exn _ -> true | _ -> false in
  >   wrong_extension || wrong_exception
  > EOF
  $ dune build @melange
  $ cat > run.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > const [ext, order] = process.argv.slice(2);
  > const events = [];
  > globalThis.auditInit = name => events.push(name);
  > (async () => {
  >   const loader = await import(`./_build/default/out/loader.${ext}`);
  >   assert.deepEqual(events, []);
  >   const values = {};
  >   for (const name of order) values[name] = await loader["load_" + name]();
  >   assert.deepEqual(events, [...order]);
  >   const a = await import(`./_build/default/out/a.${ext}`);
  >   const b = await import(`./_build/default/out/b.${ext}`);
  >   const matcher = await import(`./_build/default/out/matcher.${ext}`);
  >   assert.equal(matcher.extension(values.a), 1);
  >   assert.equal(matcher.extension(values.b), 2);
  >   assert.equal(matcher.exception_(a.exn_value), 11);
  >   assert.equal(matcher.exception_(b.exn_value), 22);
  >   assert.equal(matcher.generative(), false);
  >   assert.equal(matcher.generative(), false);
  >   assert.deepEqual(events, [...order]);
  >   console.log(JSON.stringify([values.a.MEL_EXN_ID, values.b.MEL_EXN_ID, a.exn_value.MEL_EXN_ID, b.exn_value.MEL_EXN_ID]));
  > })().catch(e => {console.error(e);process.exitCode=1;});
  > EOF
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > const {spawnSync} = require("node:child_process");
  > for (const ext of ["js", "mjs"]) {
  >   const ids = ["ab", "ba"].map(order => {
  >     const r = spawnSync(process.execPath, ["run.cjs", ext, order], {encoding:"utf8"});
  >     assert.equal(r.status, 0, r.stderr);
  >     return JSON.parse(r.stdout);
  >   });
  >   assert.deepEqual(ids[0], ids[1]);
  >   assert.equal(new Set(ids[0]).size, 4);
  >   console.log(ext, "load order, matching, rebinding and generativity: ok");
  > }
  > EOF
  $ node check.cjs
  js load order, matching, rebinding and generativity: ok
  mjs load order, matching, rebinding and generativity: ok
