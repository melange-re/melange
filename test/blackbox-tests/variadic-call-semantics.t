ReScript #7030: cover variadic call semantics.
The printed cases characterize the current incorrect behavior.

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
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > let hits = [];
  > globalThis.auditTick = n => { hits.push(n); return n; };
  > globalThis.auditArgs = () => { hits.push("array"); return [2, 3]; };
  > globalThis.auditVariadic = function(...xs) { return xs.reduce((a,b) => a+b, 0); };
  > globalThis.auditScope = { call: function(...xs) { return this === globalThis.auditScope ? xs.length : -1; } };
  > globalThis.AuditVariadicCtor = function(...xs) { this.args = xs; };
  > 
  > const characterized = new Set(["scoped dynamic receiver", "method lookup before arguments"]);
  > function check(group, name, run, expected) {
  >   const actual = run();
  >   if (characterized.has(name)) console.log(group, name, JSON.stringify(actual));
  >   else assert.deepStrictEqual(actual, expected, name);
  > }
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const m = await import("./_build/default/out/input." + ext);
  >       check(`7030/${ext}`, "literal and dynamic", () => [m.literal(),m.dynamic([2,3]),m.dynamic([])], [6,6,1]);
  >       check(`7030/${ext}`, "scoped literal receiver", () => m.scope_literal(), 3);
  >       check(`7030/${ext}`, "scoped dynamic receiver", () => m.scope_dynamic([2,3]), 3);
  >       const obj={ call:function(...args){return this===obj?args.length:-1;} };
  >       check(`7030/${ext}`, "send receiver", () => [m.send_literal(obj),m.send_dynamic(obj,[2,3])], [3,3]);
  >       check(`7030/${ext}`, "constructor", () => {const x=m.construct_dynamic([2,3]);return [x instanceof globalThis.AuditVariadicCtor,x.args];}, [true,[1,2,3]]);
  >       hits=[];check(`7030/${ext}`, "argument order", () => [m.effects(),hits], [6,[1,"array"]]);
  >       const getter={get call(){hits.push("getter");return function(...xs){return xs.length;};}};
  >       hits=[];check(`7030/${ext}`, "method lookup before arguments", () => [m.send_effects(getter),hits], [3,["getter",1,"array"]]);
  >     console.log(ext, "controls: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  7030/js scoped dynamic receiver -1
  7030/js method lookup before arguments [3,[1,"array","getter"]]
  js controls: ok
  7030/mjs scoped dynamic receiver -1
  7030/mjs method lookup before arguments [3,[1,"array","getter"]]
  mjs controls: ok
