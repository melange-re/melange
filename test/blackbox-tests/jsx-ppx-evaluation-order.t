ReScript #9117: characterize Melange's actual React PPX lowering, including keys
and multiple children. There is no JSX-preserve mode to compare against. The PPX
binds keys before the call; other argument order is not an OCaml language guarantee.
The spread case uses an explicit FFI copy before JSX, not ReScript JSX spread syntax.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.13)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx reason-react-ppx))
  >  (module_systems (commonjs js) (es6 mjs)))
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
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > (async () => {
  >   for (const ext of ['js', 'mjs']) {
  >     let events = [], throwsAt;
  >     const failure = {};
  >     const note = x => { events.push(x); if (x === throwsAt) throw failure; return x; };
  >     globalThis.auditNote = note;
  >     Object.defineProperty(globalThis, 'auditComp', {configurable:true, get() { note('tag'); return 'component'; }});
  >     const jsx = (name, key, tag, props) => { note(name); return {key, tag, props}; };
  >     globalThis.auditJsx = (tag, props) => jsx('jsx', undefined, tag, props);
  >     globalThis.auditJsxs = (tag, props) => jsx('jsxs', undefined, tag, props);
  >     globalThis.auditJsxKeyed = (key, tag, props) => jsx('jsxKeyed', key, tag, props);
  >     globalThis.auditJsxsKeyed = (key, tag, props) => jsx('jsxsKeyed', key, tag, props);
  >     globalThis.auditSpread = base => { note('spread'); return {...base}; };
  >     const base = {
  >       get children() { note('base.children'); return ['old']; },
  >       get title() { note('base.title'); return 'old'; },
  >       get retained() { note('base.retained'); return 1; },
  >     };
  >     const m = await import('./_build/default/out/input.' + ext);
  >     for (const name of ['single', 'multiple', 'dom', 'copied']) {
  >       events = [];
  >       const result = m[name](base);
  >       assert.deepEqual(result, {key:'key', tag:name === 'dom' ? 'div' : 'component', props:{children:name === 'single' ? 'child' : ['first','second'], title:'title'}});
  >       assert.equal(events.filter(x => x === 'key').length, 1);
  >       assert.equal(events.filter(x => x === 'tag').length, name === 'dom' ? 0 : 1);
  >       assert.equal(events.filter(x => x === 'title').length, 1);
  >       console.log(ext, name + ':', events.join(', '));
  >     }
  >     for (const name of ['single', 'multiple', 'dom']) {
  >       events = []; throwsAt = 'key';
  >       assert.throws(() => m[name](), e => e === failure);
  >       assert.deepEqual(events, ['key']);
  >     }
  >     events = []; throwsAt = 'base.title';
  >     assert.throws(() => m.copied(base), e => e === failure);
  >     assert.deepEqual(events, ['spread', 'base.children', 'base.title']);
  >     throwsAt = undefined;
  >     assert.deepEqual(base.children, ['old']);
  >     assert.equal(base.title, 'old');
  >     assert.equal(base.retained, 1);
  >     console.log(ext, 'keys, spread exceptions, and unchanged source props: ok');
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js single: key, tag, child, title, jsxKeyed
  js multiple: key, tag, first, second, title, jsxsKeyed
  js dom: key, first, second, title, jsxsKeyed
  js copied: spread, base.children, base.title, base.retained, first, second, title, key, tag, jsxKeyed
  js keys, spread exceptions, and unchanged source props: ok
  mjs single: key, tag, child, title, jsxKeyed
  mjs multiple: key, tag, first, second, title, jsxsKeyed
  mjs dom: key, first, second, title, jsxsKeyed
  mjs copied: spread, base.children, base.title, base.retained, first, second, title, key, tag, jsxKeyed
  mjs keys, spread exceptions, and unchanged source props: ok
