Known constant Some values do not need presence guards. Presence must remain distinct from payload truthiness.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.8)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit (target output) (alias melange))
  > EOF
  $ cat > input.ml <<'EOF'
  > let number () = let opt = Some 42 in match opt with Some x -> x | None -> 0
  > let zero () = let opt = Some 0 in match opt with Some x -> x | None -> 42
  > let false_payload () = let opt = Some false in match opt with Some x -> x | None -> true
  > let nested () = let opt = Some None in match opt with Some None -> 1 | Some (Some _) -> 2 | None -> 0
  > let deeper () = let opt = Some (Some None) in match opt with Some (Some None) -> 3 | _ -> 0
  > let absent () = match None with Some _ -> 1 | None -> 2
  > let effects f = let opt = Some 0 in match opt with Some x -> f x | None -> f 42
  > let payload_truthiness val1 val2 =
  >   let a = Some val1 in let b = Some val2 in
  >   match a, b with _, Some true | Some true, _ -> "a" | _ -> "b"
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const t = require('./_build/default/output/input.js');
  > for (const [name, expected] of [['number', 42], ['zero', 0], ['false_payload', false], ['nested', 1], ['deeper', 3], ['absent', 2]]) {
  >   assert.equal(t[name](), expected);
  >   console.log(name, 'presence guard:', /!== undefined/.test(t[name].toString()));
  > }
  > let calls = 0;
  > assert.equal(t.effects(x => { calls++; return x; }), 0);
  > assert.equal(calls, 1);
  > for (const a of [false, true]) for (const b of [false, true])
  >   assert.equal(t.payload_truthiness(a, b), a || b ? 'a' : 'b');
  > EOF
  number presence guard: true
  zero presence guard: true
  false_payload presence guard: true
  nested presence guard: true
  deeper presence guard: true
  absent presence guard: false
