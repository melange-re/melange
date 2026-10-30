ReScript #6476: lowered JSX calls preserve arbitrary runtime, props, and child effects.
This covers the compiler boundary after the separately maintained JSX PPX.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx))
  >  (compile_flags :standard --mel-cross-module-opt))
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
  $ node <<'EOF'
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
  > events = []; failure = new Error("failure");
  > const path = "./_build/default/out/input.js";
  > const m = require(path);
  > m.discarded(); assert.deepEqual(events, ["props", "node"]);
  > events = []; m.nested(); assert.deepEqual(events, ["child", "parent"]);
  > events = []; assert.throws(m.throws_props, e => e === failure);
  > assert.deepEqual(events, ["throw"]);
  > events = []; assert.throws(m.throws_runtime, e => e === failure);
  > assert.deepEqual(events, ["props", "throw"]);
  > events = []; m.dead_branch(); assert.deepEqual(events, []);
  > assert.doesNotMatch(fs.readFileSync(path, "utf8"), /[@#]__PURE__/);
  > EOF
