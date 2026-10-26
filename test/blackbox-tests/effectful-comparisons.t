Constant comparison results must retain evaluation of their operands.

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
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ cat > input.ml <<'EOF'
  > external hit : unit -> int = "comparisonHit"
  > external option_hit : unit -> int option = "comparisonOptionHit"
  > type record = { value : int }
  > let eq_array () = Js.Nullable.return [|hit ()|] = Js.Nullable.null
  > let eq_array_rev () = Js.Nullable.null = Js.Nullable.return [|hit ()|]
  > let neq_array () = Js.Nullable.return [|hit ()|] <> Js.Nullable.undefined
  > let neq_array_rev () = Js.Nullable.undefined <> Js.Nullable.return [|hit ()|]
  > let eq_typeof () = Js.Nullable.return (Js.typeof (hit ())) = Js.Nullable.null
  > let neq_typeof () = Js.Nullable.null <> Js.Nullable.return (Js.typeof (hit ()))
  > let eq_record () = Js.Nullable.return {value = hit ()} = Js.Nullable.null
  > let neq_record () = Js.Nullable.null <> Js.Nullable.return {value = hit ()}
  > let nullable_array () = Js.Nullable.isNullable (Js.Nullable.return [|hit ()|])
  > let nullable_record () = Js.Nullable.isNullable (Js.Nullable.return {value = hit ()})
  > let eq_some () = Some (option_hit ()) = None
  > let eq_some_rev () = None = Some (option_hit ())
  > let neq_some () = Some (option_hit ()) <> None
  > let physical_some () = Some (option_hit ()) == None
  > let physical_some_rev () = None == Some (option_hit ())
  > let and_false () = hit () = 1 && false
  > let or_true () = hit () = 1 || true
  > let skip_and () = false && hit () = 1
  > let skip_or () = true || hit () = 1
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > const cases = [['eq_array',false], ['eq_array_rev',false], ['neq_array',true], ['neq_array_rev',true], ['eq_typeof',false], ['neq_typeof',true], ['eq_record',false], ['neq_record',true], ['nullable_array',false], ['nullable_record',false], ['eq_some',false], ['eq_some_rev',false], ['neq_some',true], ['physical_some',false], ['physical_some_rev',false], ['and_false',false], ['or_true',true]];
  > (async () => {
  >   for (const [format,t] of [['CommonJS',require('./_build/default/out/input.js')], ['ESM',await import('./_build/default/out/input.mjs')]]) {
  >     const counts = [], throws = [];
  >     for (const [name,result] of cases) {
  >       let calls = 0;
  >       global.comparisonHit = () => { calls++; return 1; };
  >       global.comparisonOptionHit = () => { calls++; return undefined; };
  >       assert.equal(t[name](), result, name);
  >       counts.push(calls);
  >       const failure = new Error(name);
  >       global.comparisonHit = global.comparisonOptionHit = () => { throw failure; };
  >       let caught = false;
  >       try { t[name](); } catch (e) { assert.equal(e, failure); caught = true; }
  >       throws.push(Number(caught));
  >     }
  >     assert.equal(t.skip_and(), false);
  >     assert.equal(t.skip_or(), true);
  >     console.log(format + ' calls: ' + counts.join(','));
  >     console.log(format + ' throws: ' + throws.join(','));
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  CommonJS calls: 0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1
  CommonJS throws: 0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1
  ESM calls: 0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1
  ESM throws: 0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1
