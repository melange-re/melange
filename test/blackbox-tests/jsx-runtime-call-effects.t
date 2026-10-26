ReScript #6476: lowered JSX calls preserve arbitrary runtime, props, and child effects.
This covers the compiler boundary after the separately maintained JSX PPX.

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
  >  (compile_flags :standard --mel-cross-module-opt)
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ cat > input.ml <<'EOF'
  > external jsx : string -> 'a -> 'b = "auditJsx"
  > external jsxs : string -> 'a -> 'b = "auditJsxs"
  > external props : string -> < child : string > Js.t = "auditProps"
  > external child : string -> string = "auditChild"
  > external make_props : child:string -> < child : string > Js.t = "" [@@mel.obj]
  > let discarded () = ignore (jsx "node" (props "props"))
  > let nested () = ignore (jsxs "parent" (make_props ~child:(child "child")))
  > let throws_props () = ignore (jsx "node" (props "throw"))
  > let throws_runtime () = ignore (jsx "throw" (props "props"))
  > let dead_branch () = if false then ignore (jsx "dead" (props "dead"))
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > const fs = require("node:fs");
  > let events, failure;
  > globalThis.auditProps = value => {
  >   events.push(value);
  >   if (value === "throw") throw failure;
  >   return {child: value};
  > };
  > globalThis.auditChild = value => { events.push(value); return value; };
  > globalThis.auditJsx = (tag, props) => {
  >   events.push(tag);
  >   if (tag === "throw") throw failure;
  >   assert.equal(props.child, "props");
  >   return {tag, props};
  > };
  > globalThis.auditJsxs = (tag, props) => {
  >   assert.equal(props.child, "child");
  >   events.push(tag);
  >   return {tag, props};
  > };
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     events = []; failure = new Error(ext);
  >     const path = "./_build/default/out/input." + ext;
  >     const m = await import(path);
  >     m.discarded(); assert.deepEqual(events, ["props", "node"]);
  >     events = []; m.nested(); assert.deepEqual(events, ["child", "parent"]);
  >     events = []; assert.throws(m.throws_props, e => e === failure);
  >     assert.deepEqual(events, ["throw"]);
  >     events = []; assert.throws(m.throws_runtime, e => e === failure);
  >     assert.deepEqual(events, ["props", "throw"]);
  >     events = []; m.dead_branch(); assert.deepEqual(events, []);
  >     assert.doesNotMatch(fs.readFileSync(path, "utf8"), /[@#]__PURE__/);
  >     console.log(ext + ": ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js: ok
  mjs: ok
