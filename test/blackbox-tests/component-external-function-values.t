Lowered JSX preserves imported component identity and does not invoke components.
ReScript #6880.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx))
  >  (runtime_deps component.cjs)
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ cat > component.cjs <<'EOF'
  > exports.component=function(){ throw new Error('component invoked while constructing element'); };
  > EOF
  $ cat > input.ml <<'EOF'
  > type props = { id : string }
  > type element
  > type component = (props -> element [@u])
  > external aliased : component = "component" [@@mel.module "./component.cjs"]
  > external inline : (props -> element [@u]) = "component" [@@mel.module "./component.cjs"]
  > external jsx : component -> props -> element = "auditJsx"
  > let component = aliased
  > let render id = jsx aliased {id}
  > let render_inline id = jsx inline {id}
  > EOF
  $ dune build @melange
  $ node --input-type=module <<'EOF'
  > import assert from 'node:assert/strict';
  > import fixture from './_build/default/out/component.cjs';
  > globalThis.auditJsx = (component,props) => ({component,props});
  > for (const ext of ['js', 'mjs']) {
  >   const m = await import('./_build/default/out/input.' + ext);
  >   assert.equal(m.component, fixture.component);
  >   for (const render of [m.render, m.render_inline])
  >     assert.deepEqual(render('hello'), {component:fixture.component, props:{id:'hello'}});
  > }
  > EOF
