Lowered JSX preserves imported component identity and does not invoke components.
ReScript #6880.

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
  >       (runtime_deps component.cjs)
  >       (module_systems (commonjs js) (es6 mjs)))
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
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > const fs = require('node:fs');
  > globalThis.auditJsx=(component,props)=>({component,props});
  > (async () => {
  >   for (const ext of ['js', 'mjs']) {
  >     const m = await import('./_build/default/out/input.'+ext);
  >     const code = fs.readFileSync('./_build/default/out/input.'+ext, 'utf8');
  > const fixture=require('./_build/default/out/component.cjs');
  > assert.equal(m.component,fixture.component);
  > for(const f of [m.render,m.render_inline]) {
  >   const rendered=f('hello');
  >   assert.equal(rendered.component,fixture.component);
  >   assert.deepEqual(rendered.props,{id:'hello'});
  > }
  >     console.log(ext, 'controls: ok');
  >   }
  > 
  > 
  > })().catch(e => { console.error(e); process.exitCode=1; });
  > EOF
  $ node check.cjs
  js controls: ok
  mjs controls: ok
