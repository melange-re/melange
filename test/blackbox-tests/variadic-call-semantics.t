ReScript #7030: cover variadic call semantics.
The printed cases characterize the current incorrect behavior.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > external global : int -> int array -> int = "auditVariadic" [@@mel.variadic]
  > external scoped : int -> int array -> int = "call" [@@mel.scope "auditScope"] [@@mel.variadic]
  > external method_ : 'a -> int -> int array -> int = "call" [@@mel.send] [@@mel.variadic]
  > external new_ : int -> int array -> 'a = "AuditVariadicCtor" [@@mel.new] [@@mel.variadic]
  > external next : int -> int = "auditTick"
  > external args : unit -> int array = "auditArgs"
  > let literal () = global 1 [|2; 3|]
  > let dynamic xs = global 1 xs
  > let scope_literal () = scoped 1 [|2; 3|]
  > let scope_dynamic xs = scoped 1 xs
  > let send_dynamic obj xs = method_ obj 1 xs
  > let send_literal obj = method_ obj 1 [|2; 3|]
  > let construct_dynamic xs = new_ 1 xs
  > let effects () = global (next 1) (args ())
  > let send_effects obj = method_ obj (next 1) (args ())
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js');
  > let hits = [];
  > globalThis.auditTick = n => { hits.push(n); return n; };
  > globalThis.auditArgs = () => { hits.push('array'); return [2,3]; };
  > globalThis.auditVariadic = (...xs) => xs.reduce((a,b) => a+b, 0);
  > globalThis.auditScope = {call(...xs) { return this === globalThis.auditScope ? xs.length : -1; }};
  > globalThis.AuditVariadicCtor = function(...xs) { this.args = xs; };
  > assert.deepEqual([m.literal(), m.dynamic([2,3]), m.dynamic([])], [6,6,1]);
  > assert.equal(m.scope_literal(), 3);
  > console.log('scoped dynamic receiver', m.scope_dynamic([2,3]));
  > const obj = {call(...xs) { return this === obj ? xs.length : -1; }};
  > assert.deepEqual([m.send_literal(obj),m.send_dynamic(obj,[2,3])], [3,3]);
  > const constructed = m.construct_dynamic([2,3]);
  > assert.ok(constructed instanceof globalThis.AuditVariadicCtor);
  > assert.deepEqual(constructed.args, [1,2,3]);
  > assert.deepEqual([m.effects(),hits], [6,[1,'array']]);
  > const getter = {get call() { hits.push('getter'); return (...xs) => xs.length; }};
  > hits = [];
  > console.log('method lookup before arguments', JSON.stringify([m.send_effects(getter),hits]));
  > EOF
  scoped dynamic receiver -1
  method lookup before arguments [3,[1,"array","getter"]]
