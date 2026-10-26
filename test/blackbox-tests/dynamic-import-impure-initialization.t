ReScript #6232: dynamic-only imports do not initialize impure modules eagerly.
Mixed references retain the static dependency in either order.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx))
  >  (compile_flags :standard (:include flags.sexp))
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ cat > lazy_target.ml <<'EOF'
  > external initialize : string -> int = "auditInitialize"
  > let value = initialize "lazy"
  > EOF
  $ cat > mixed_a.ml <<'EOF'
  > external initialize : string -> int = "auditInitialize"
  > let value = initialize "mixed a"
  > EOF
  $ cat > mixed_b.ml <<'EOF'
  > external initialize : string -> int = "auditInitialize"
  > let value = initialize "mixed b"
  > EOF
  $ cat > throw_target.ml <<'EOF'
  > external initialize : unit -> int = "auditThrow"
  > let value = initialize ()
  > EOF
  $ cat > lazy_user.ml <<'EOF'
  > let load () = Js.import Lazy_target.value
  > module type Target = sig val value : int end
  > let load_module () = Js.import (module Lazy_target : Target)
  > let load_throw () = Js.import Throw_target.value
  > EOF
  $ cat > dynamic_first.ml <<'EOF'
  > let load () = Js.import Mixed_a.value
  > let read () = Mixed_a.value
  > EOF
  $ cat > static_first.ml <<'EOF'
  > let read () = Mixed_b.value
  > let load () = Js.import Mixed_b.value
  > EOF
  $ mkdir -p node_modules/audit-mixed-a node_modules/audit-mixed-b
  $ cat > node_modules/audit-mixed-a/index.js <<'EOF'
  > exports.value = 42;
  > exports.other = 43;
  > EOF
  $ cp node_modules/audit-mixed-a/index.js node_modules/audit-mixed-b/index.js
  $ cat > ffi_dynamic_first.ml <<'EOF'
  > external first : int = "value" [@@mel.module "audit-mixed-a"]
  > external second : int = "other" [@@mel.module "audit-mixed-a"]
  > let load () = Js.import first
  > let read () = second
  > EOF
  $ cat > ffi_static_first.ml <<'EOF'
  > external first : int = "other" [@@mel.module "audit-mixed-b"]
  > external second : int = "value" [@@mel.module "audit-mixed-b"]
  > let read () = first
  > let load () = Js.import second
  > EOF
  $ echo '()' > flags.sexp
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > const fs = require("node:fs");
  > let events, failure;
  > globalThis.auditInitialize = name => { events.push(name); return 42; };
  > globalThis.auditThrow = () => { events.push("throw"); throw failure; };
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     events = []; failure = new Error(ext);
  >     const path = "./_build/default/out/";
  >     const m = await import(path + "lazy_user." + ext);
  >     assert.deepEqual(events, []);
  >     assert.equal(await m.load(), 42);
  >     assert.deepEqual(events, ["lazy"]);
  >     assert.equal((await m.load_module()).value, 42);
  >     assert.equal(await m.load(), 42);
  >     assert.deepEqual(events, ["lazy"]);
  >     let promise;
  >     assert.doesNotThrow(() => { promise = m.load_throw(); });
  >     await assert.rejects(promise, e => e === failure);
  >     assert.deepEqual(events, ["lazy", "throw"]);
  >     for (const [file, name] of [["dynamic_first", "mixed a"], ["static_first", "mixed b"]]) {
  >       const mixed = await import(path + file + "." + ext);
  >       const result = mixed.read();
  >       assert.equal(result, 42);
  >       console.log(ext, file, "eager", events.filter(event => event === name).length, "read", result);
  >       assert.equal(await mixed.load(), 42);
  >       assert.equal(events.filter(event => event === name).length, 1);
  >     }
  >     for (const file of ["ffi_dynamic_first", "ffi_static_first"]) {
  >       const ffi = await import(path + file + "." + ext);
  >       const result = ffi.read();
  >       assert.equal(result, 43);
  >       console.log(ext, file, "read", result);
  >       assert.equal(await ffi.load(), 42);
  >     }
  >     const source = fs.readFileSync(path + "lazy_user." + ext, "utf8");
  >     assert.doesNotMatch(source, /require\(.*(?:lazy_target|throw_target)/);
  >     assert.doesNotMatch(source, /import .* from .*(?:lazy_target|throw_target)/);
  >     console.log(ext + ": ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js dynamic_first eager 1 read 42
  js static_first eager 1 read 42
  js ffi_dynamic_first read 43
  js ffi_static_first read 43
  js: ok
  mjs dynamic_first eager 1 read 42
  mjs static_first eager 1 read 42
  mjs ffi_dynamic_first read 43
  mjs ffi_static_first read 43
  mjs: ok

The dependency requirement must survive cross-module optimization too.

  $ echo '(--mel-cross-module-opt)' > flags.sexp
  $ dune build @melange
  $ node check.cjs
  js dynamic_first eager 1 read 42
  js static_first eager 1 read 42
  js ffi_dynamic_first read 43
  js ffi_static_first read 43
  js: ok
  mjs dynamic_first eager 1 read 42
  mjs static_first eager 1 read 42
  mjs ffi_dynamic_first read 43
  mjs ffi_static_first read 43
  mjs: ok
