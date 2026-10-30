ReScript #8582: dynamically imported externals retain their FFI adapters.
The baseline records failures; the fix changes these observations to assertions.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (modules input)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx))
  >  (compile_flags :standard (:include flags.sexp))
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ mkdir -p node_modules/audit-adapted-ffi
  $ cat > node_modules/audit-adapted-ffi/index.js <<'EOF'
  > globalThis.auditLoads = (globalThis.auditLoads || 0) + 1;
  > exports.sum = function(...args) { return args.reduce((a, b) => a + b, 0); };
  > exports.unwrap = function(x) { return String(x); };
  > exports.optional = function(x, n) { return x === undefined ? n : -1; };
  > exports.nullable = function(x) { return x === 0 ? null : x === 1 ? undefined : 8; };
  > exports.unit = function() { return arguments.length; };
  > exports.raw = function(x) { return x + 1; };
  > exports.scope = { nested: { sum: exports.sum, raw: exports.raw } };
  > EOF
  $ cat > input.ml <<'EOF'
  > external sum : int array -> int = "sum"
  >   [@@mel.module "audit-adapted-ffi"] [@@mel.variadic]
  > external unwrap : ([ `Text of string | `Int of int ][@mel.unwrap]) -> string = "unwrap"
  >   [@@mel.module "audit-adapted-ffi"]
  > external optional : ?x:int option -> int -> int = "optional"
  >   [@@mel.module "audit-adapted-ffi"]
  > external nullable : int -> int option = "nullable"
  >   [@@mel.module "audit-adapted-ffi"] [@@mel.return nullable]
  > external unit_call : unit -> int = "unit" [@@mel.module "audit-adapted-ffi"]
  > external raw : int -> int = "raw" [@@mel.module "audit-adapted-ffi"]
  > let use promise f = Js.Promise.then_ (fun fn -> Js.Promise.resolve (f fn)) promise
  > let run_sum () = use (Js.import sum) (fun fn -> fn [|1; 2; 3|])
  > let run_unwrap () = use (Js.import unwrap) (fun fn -> fn (`Text "payload"))
  > let run_optional () = use (Js.import optional) (fun fn -> fn ~x:None 7)
  > let run_nullable () = use (Js.import nullable) (fun fn ->
  >   Array.map (fun n -> match fn n with None -> -1 | Some n -> n) [|0; 1; 2|])
  > let run_unit () = use (Js.import unit_call) (fun fn -> fn ())
  > let load_raw () = Js.import raw
  > EOF
  $ cat > scoped.ml <<'EOF'
  > external sum : int array -> int = "sum"
  >   [@@mel.module "audit-adapted-ffi"] [@@mel.scope ("scope", "nested")] [@@mel.variadic]
  > let load () = Js.import sum
  > external raw : int -> int = "raw"
  >   [@@mel.module "audit-adapted-ffi"] [@@mel.scope ("scope", "nested")]
  > let load_raw () = Js.import raw
  > EOF
  $ cat > check.mjs <<'EOF'
  > import assert from 'node:assert/strict';
  > import fs from 'node:fs';
  > for (const ext of ["js", "mjs"]) {
  >   const m = await import("./_build/default/out/input." + ext);
  >   if (ext === "js") assert.equal(globalThis.auditLoads, undefined);
  >   for (const name of ["sum", "unwrap", "optional", "nullable", "unit"])
  >     console.log(ext, name, JSON.stringify(await m["run_" + name]()));
  >   const target = await import("audit-adapted-ffi");
  >   assert.equal(await m.load_raw(), target.raw);
  >   assert.equal(globalThis.auditLoads, 1);
  >   const source = fs.readFileSync("./_build/default/out/input." + ext, "utf8");
  >   assert.doesNotMatch(source, /require\("audit-adapted-ffi"\)/);
  >   assert.doesNotMatch(source, /import .* from "audit-adapted-ffi"/);
  > }
  > EOF
  $ echo '()' > flags.sexp
  $ dune build @melange
  $ node check.mjs
  js sum undefined
  js unwrap "[object Object]"
  js optional -1
  js nullable [0,1,2]
  js unit 1
  mjs sum undefined
  mjs unwrap "[object Object]"
  mjs optional -1
  mjs nullable [0,1,2]
  mjs unit 1
  $ melc -ppx melppx -o scoped.js scoped.ml > scoped.log 2>&1; echo $?
  2
  $ echo '(--mel-cross-module-opt)' > flags.sexp
  $ dune build @melange
  $ node check.mjs
  js sum undefined
  js unwrap "[object Object]"
  js optional -1
  js nullable [0,1,2]
  js unit 1
  mjs sum undefined
  mjs unwrap "[object Object]"
  mjs optional -1
  mjs nullable [0,1,2]
  mjs unit 1
