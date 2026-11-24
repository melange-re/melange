ReScript #9117: characterize Melange's actual React PPX lowering, including keys
and multiple children. There is no JSX-preserve mode to compare against. The PPX
binds keys before the call; other argument order is not an OCaml language guarantee.
The spread case uses an explicit FFI copy before JSX, not ReScript JSX spread syntax.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.13)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx reason-react-ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > module React = struct
  >   type element
  >   external jsx : 'a -> 'b -> element = "auditJsx"
  >   external jsxs : 'a -> 'b -> element = "auditJsxs"
  >   external jsxKeyed : key:string -> 'a -> 'b -> unit -> element = "auditJsxKeyed"
  >   external jsxsKeyed : key:string -> 'a -> 'b -> unit -> element = "auditJsxsKeyed"
  >   external array : 'a array -> 'a array = "%identity"
  > end
  > module ReactDOM = struct
  >   include React
  >   external domProps : children:'a -> title:string -> unit -> < children : 'a; title : string > Js.t = "" [@@mel.obj]
  > end
  > module Comp = struct
  >   external make : string = "auditComp"
  >   external makeProps : children:'a -> title:string -> unit -> < children : 'a; title : string > Js.t = "" [@@mel.obj]
  > end
  > external note : string -> string = "auditNote"
  > let single () = (Comp.createElement ~title:(note "title") ~children:(note "child") ~key:(note "key") ()) [@JSX]
  > let multiple () = (Comp.createElement ~title:(note "title") ~children:[note "first"; note "second"] ~key:(note "key") ()) [@JSX]
  > let dom () = (div ~title:(note "title") ~children:[note "first"; note "second"] ~key:(note "key") ()) [@JSX]
  > type props = { children : string array; title : string; retained : int }
  > external spread : props -> props = "auditSpread"
  > let copied base =
  >   let props = spread base in
  >   let children = [| note "first"; note "second" |] in
  >   let title = note "title" in
  >   let props = { props with children; title } in
  >   (Comp.createElement ~children:props.children ~title:props.title ~key:(note "key") ()) [@JSX]
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > let events = [], throwsAt;
  > const failure = {};
  > const note = x => { events.push(x); if (x === throwsAt) throw failure; return x; };
  > globalThis.auditNote = note;
  > Object.defineProperty(globalThis, 'auditComp', {configurable:true, get() { note('tag'); return 'component'; }});
  > const jsx = (name, key, tag, props) => { note(name); return {key, tag, props}; };
  > globalThis.auditJsx = (tag, props) => jsx('jsx', undefined, tag, props);
  > globalThis.auditJsxs = (tag, props) => jsx('jsxs', undefined, tag, props);
  > globalThis.auditJsxKeyed = (key, tag, props) => jsx('jsxKeyed', key, tag, props);
  > globalThis.auditJsxsKeyed = (key, tag, props) => jsx('jsxsKeyed', key, tag, props);
  > globalThis.auditSpread = base => { note('spread'); return {...base}; };
  > const base = {
  >   get children() { note('base.children'); return ['old']; },
  >   get title() { note('base.title'); return 'old'; },
  >   get retained() { note('base.retained'); return 1; },
  > };
  > const m = require('./_build/default/out/input.js');
  > for (const name of ['single', 'multiple', 'dom', 'copied']) {
  >   events = [];
  >   const result = m[name](base);
  >   assert.deepEqual(result, {key:'key', tag:name === 'dom' ? 'div' : 'component', props:{children:name === 'single' ? 'child' : ['first','second'], title:'title'}});
  >   console.log(name + ':', events.join(', '));
  > }
  > for (const name of ['single', 'multiple', 'dom']) {
  >   events = []; throwsAt = 'key';
  >   assert.throws(() => m[name](), e => e === failure);
  >   assert.deepEqual(events, ['key']);
  > }
  > events = []; throwsAt = 'base.title';
  > assert.throws(() => m.copied(base), e => e === failure);
  > assert.deepEqual(events, ['spread', 'base.children', 'base.title']);
  > throwsAt = undefined;
  > assert.deepEqual(base.children, ['old']);
  > assert.equal(base.title, 'old');
  > assert.equal(base.retained, 1);
  > EOF
  single: key, tag, child, title, jsxKeyed
  multiple: key, tag, first, second, title, jsxsKeyed
  dom: key, first, second, title, jsxsKeyed
  copied: spread, base.children, base.title, base.retained, first, second, title, key, tag, jsxKeyed
