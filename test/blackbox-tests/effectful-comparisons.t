Constant comparison results must retain evaluation of their operands.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.13)' '(using melange 0.1)' > dune-project
  $ echo '(melange.emit (target out) (emit_stdlib false) (libraries melange.js) (preprocess (pps melange.ppx)))' > dune
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
  $ node <<'JS'
  > const t = require('./_build/default/out/input.js');
  > for (const [name, compare] of Object.entries(t)) {
  >   let calls = 0, thrown = false;
  >   global.comparisonHit = () => { calls++; return 1; };
  >   global.comparisonOptionHit = () => { calls++; };
  >   const result = compare();
  >   const failure = new Error(name);
  >   global.comparisonHit = global.comparisonOptionHit = () => { throw failure; };
  >   try { compare(); } catch (error) { thrown = error === failure ? 'hit' : error; }
  >   console.log(name, result, calls, thrown);
  > }
  > JS
  eq_array false 1 hit
  eq_array_rev false 1 hit
  neq_array true 1 hit
  neq_array_rev true 1 hit
  eq_typeof false 1 hit
  neq_typeof true 1 hit
  eq_record false 1 hit
  neq_record true 1 hit
  nullable_array false 1 hit
  nullable_record false 1 hit
  eq_some false 1 hit
  eq_some_rev false 1 hit
  neq_some true 1 hit
  physical_some false 1 hit
  physical_some_rev false 1 hit
  and_false false 1 hit
  or_true true 1 hit
  skip_and false 0 false
  skip_or true 0 false
