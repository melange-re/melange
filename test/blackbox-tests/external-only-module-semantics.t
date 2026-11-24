ReScript #7145: retain exported module values and initialization effects.
An external-only local module can disappear without deleting observable exports.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > module Exported = struct external f : int -> int = "auditFunction" end
  > module type S = sig external f : int -> int = "auditFunction" end
  > let packed = (module Exported : S)
  > let unpacked x = let module M = (val packed : S) in M.f x
  > module Use (X : S) = struct let call x = X.f x end
  > module Applied = Use (Exported)
  > module With_effect = struct
  >   external note : string -> unit = "auditNote"
  >   let () = note "module"
  > end
  > let local x = let module M = struct external f : int -> int = "auditFunction" end in M.f x
  > EOF
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx))
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ dune build @melange
  $ node --input-type=module <<'EOF'
  > import assert from 'node:assert/strict';
  > for (const ext of ["js", "mjs"]) {
  >   const events = [];
  >   globalThis.auditNote = x => events.push(x);
  >   globalThis.auditFunction = x => { events.push(x); return x + 1; };
  >   const path = "./_build/default/out/input." + ext;
  >   const m = await import(path);
  >   assert.deepEqual(events, ["module"]);
  >   assert.deepEqual(m.Exported, {});
  >   assert.deepEqual(m.With_effect, {});
  >   assert.strictEqual(m.packed, m.Exported);
  >   assert.equal(m.unpacked(2), 3);
  >   assert.equal(m.Applied.call(3), 4);
  >   assert.equal(m.local(4), 5);
  >   assert.deepEqual(events, ["module", 2, 3, 4]);
  >   await import(path);
  >   assert.deepEqual(events, ["module", 2, 3, 4]);
  >   assert.doesNotMatch(m.local.toString(), /\b(?:const|let|var) M\b/);
  > }
  > EOF
