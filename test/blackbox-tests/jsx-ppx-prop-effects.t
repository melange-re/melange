ReScript #8757/#9057: observe children and prop effects through the real JSX PPX.
Melange lowers JSX to calls; it does not have ReScript's JSX-preserve mode.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > module React = struct
  >   external jsx : 'a -> 'b -> 'b = "auditJsx"
  > end
  > module Comp = struct
  >   external make : string = "auditComp"
  >   external makeProps : children:string -> title:string -> unit -> < children : string; title : string > Js.t = "" [@@mel.obj]
  > end
  > external note : string -> string = "auditNote"
  > let render () = (Comp.createElement ~children:(note "children") ~title:(note "title") ()) [@JSX]
  > type props = { children : string; title : string; retained : int }
  > let render_copy base =
  >   let children = note "children" in
  >   let title = note "title" in
  >   let props = { base with children; title } in
  >   (Comp.createElement ~children:props.children ~title:props.title ()) [@JSX]
  > EOF
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx reason-react-ppx))
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const events = [];
  >     globalThis.auditComp = "component";
  >     globalThis.auditNote = x => { events.push(x); return x; };
  >     globalThis.auditJsx = (component, props) => {
  >       assert.equal(component, "component");
  >       events.push("jsx");
  >       return props;
  >     };
  >     const m = await import("./_build/default/out/input." + ext);
  >     const base = {children:"old child",title:"old title",retained:1};
  >     for (const run of [m.render, () => m.render_copy(base)]) {
  >       events.length = 0;
  >       assert.deepEqual(run(), {children:"children",title:"title"});
  >       assert.deepEqual(events, ["children", "title", "jsx"]);
  >     }
  >     assert.deepEqual(base, {children:"old child",title:"old title",retained:1});
  >     const failure = new Error("children");
  >     globalThis.auditNote = x => { events.push(x); throw failure; };
  >     for (const run of [m.render, () => m.render_copy(base)]) {
  >       events.length = 0;
  >       assert.throws(run, e => e === failure);
  >       assert.deepEqual(events, ["children"]);
  >     }
  >     console.log(ext, "JSX prop effects: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js JSX prop effects: ok
  mjs JSX prop effects: ok
