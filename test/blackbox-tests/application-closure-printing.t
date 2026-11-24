ReScript #7023: closure expressions in applications and string concatenation.
Importing the module checks syntax for the unsafe arity cast; runtime checks use typed applications.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx))
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ cat > input.ml <<'EOF'
  > external as_string : 'a -> string = "String"
  > external next : unit -> int = "applicationNext"
  > let first x _ = x
  > let unsafe : int -> int = Obj.magic first
  > let unsafe_result x = unsafe x
  > let unsafe_concat x = "value: " ^ as_string (unsafe x)
  > let reason error ?nested_level:_ () = string_of_int error
  > let correct_concat x = "value: " ^ reason x ()
  > let partial_concat x = "partial: " ^ as_string (first x)
  > let callback x = fun y -> x + y
  > let callback_concat x = "callback: " ^ as_string (callback x)
  > let choose flag x y = (if flag then fun z -> x + z else fun z -> x - z) y
  > let capture () = let x = next () in fun y -> x + y
  > let higher_order f x y = f x y
  > let applied x y = higher_order callback x y
  > EOF
  $ dune build @melange
  $ node --input-type=module <<'EOF'
  > import assert from "node:assert/strict";
  > let hits = 0;
  > globalThis.applicationNext = () => ++hits;
  > for (const ext of ["js", "mjs"]) {
  >   const file = "./_build/default/out/input." + ext;
  >   const m = await import(file);
  >   assert.equal(m.correct_concat(7), "value: 7");
  >   assert.match(m.partial_concat(3), /^partial: function/);
  >   assert.match(m.callback_concat(3), /^callback: function/);
  >   assert.equal(m.choose(true, 5, 2), 7);
  >   assert.equal(m.choose(false, 5, 2), 3);
  >   assert.equal(m.applied(5, 2), 7);
  >   hits = 0;
  >   const f = m.capture();
  >   assert.equal(hits, 1);
  >   assert.equal(f(10), 11);
  >   assert.equal(f(20), 21);
  >   assert.equal(hits, 1);
  > }
  > EOF

