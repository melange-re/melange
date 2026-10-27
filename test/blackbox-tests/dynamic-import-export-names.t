ReScript #8582: dynamic imports must use emitted names for OCaml exports.
Foreign property names are literal JavaScript names and must remain unchanged.

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
  $ cat > target.ml <<'EOF'
  > external value : string -> int = "auditExportValue"
  > let case = value "case"
  > let await = value "await"
  > let value' = value "prime"
  > let (+!) a b = a + b
  > EOF
  $ mkdir -p node_modules/audit-export-names
  $ cat > node_modules/audit-export-names/index.js <<'EOF'
  > exports.case = 43;
  > EOF
  $ cat > input.ml <<'EOF'
  > let case () = Js.import Target.case
  > let await () = Js.import Target.await
  > let prime () = Js.import Target.value'
  > let operator () = Js.import Target.(+!)
  > external foreign_case : int = "case" [@@mel.module "audit-export-names"]
  > let ffi_case () = Js.import foreign_case
  > EOF
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > let events = [];
  > globalThis.auditExportValue = name => {events.push(name); return 42;};
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const m = await import("./_build/default/out/input." + ext);
  >     assert.equal(events.length, ext === "js" ? 0 : 3);
  >     const values = [await m.$$case(), await m.$$await(), await m.prime()];
  >     console.log(ext, "mangled values", values.map(x => x === 42).join(","));
  >     const op = await m.operator();
  >     console.log(ext, "operator", typeof op === "function" && op(2,3) === 5);
  >     assert.equal(await m.ffi_case(), 43);
  >     assert.equal(events.length, ext === "js" ? 3 : 6);
  >     console.log(ext, "literal FFI names and lazy loading: ok");
  >   }
  > })().catch(e => {console.error(e); process.exitCode = 1;});
  > EOF
  $ echo '()' > flags.sexp
  $ dune build @melange
  $ node check.cjs
  js mangled values false,false,false
  js operator false
  js literal FFI names and lazy loading: ok
  mjs mangled values false,false,false
  mjs operator false
  mjs literal FFI names and lazy loading: ok
  $ echo '(--mel-cross-module-opt)' > flags.sexp
  $ dune build @melange
  $ node check.cjs
  js mangled values false,false,false
  js operator false
  js literal FFI names and lazy loading: ok
  mjs mangled values false,false,false
  mjs operator false
  mjs literal FFI names and lazy loading: ok
