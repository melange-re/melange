ReScript #8582: dynamically imported externals retain their FFI adapters.
Argument and result conversions agree with the declared OCaml function type.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (modules input scoped)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx))
  >  (compile_flags :standard (:include flags.sexp))
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ mkdir -p node_modules/audit-adapted-ffi
  $ cat > node_modules/audit-adapted-ffi/index.js <<'EOF'
  > "use strict";
  > const assert = require("node:assert/strict");
  > globalThis.auditLoads = (globalThis.auditLoads || 0) + 1;
  > exports.sum = function(...args) { return args.reduce((a, b) => a + b, 0); };
  > exports.unwrap = function(x) { return String(x); };
  > exports.optional = function(x, n) { return x === undefined ? n : -1; };
  > exports.nullable = function(x) { return x === 0 ? null : x === 1 ? undefined : 8; };
  > exports.nullValue = null;
  > exports.unit = function() { return arguments.length; };
  > exports.raw = function(x) { return x + 1; };
  > exports.phantom = function(prefix, x) { return prefix + x; };
  > exports.callback = function(fn) { assert.equal(fn.length, 0); return fn() + fn(); };
  > exports.defaultArgs = function(x, y = 1) { return x + y; };
  > exports.restArgs = function(...values) { return values.reduce((a,b) => a+b,0); };
  > exports.extraArity = function(x, unused) { return x; };
  > exports.encoding = function(x) { return String(x); };
  > exports.throwing = function() { throw globalThis.auditFailure; };
  > exports.Box = class { constructor(...values) { this.value = values.reduce((a,b) => a+b,0); } };
  > exports.scope = { nested: { sum: exports.sum, raw: exports.raw } };
  > EOF
  $ mkdir -p node_modules/audit-adapted-default node_modules/audit-adapted-class
  $ cat > node_modules/audit-adapted-default/package.json <<'EOF'
  > {"type":"module","main":"index.js"}
  > EOF
  $ cp node_modules/audit-adapted-default/package.json node_modules/audit-adapted-class/package.json
  $ cat > node_modules/audit-adapted-default/index.js <<'EOF'
  > export default function(...values) { return values.reduce((a,b) => a+b,0); }
  > EOF
  $ cat > node_modules/audit-adapted-class/index.js <<'EOF'
  > export default class { constructor(value) { this.value = value; } }
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
  > external raw : (int -> int [@u]) = "raw" [@@mel.module "audit-adapted-ffi"]
  > let use promise f = Js.Promise.then_ (fun fn -> Js.Promise.resolve (f fn)) promise
  > let run_sum () = use (Js.import sum) (fun fn -> fn [|1; 2; 3|])
  > let run_unwrap () = use (Js.import unwrap) (fun fn -> fn (`Text "payload"))
  > let run_optional () = use (Js.import optional) (fun fn -> fn ~x:None 7)
  > let run_nullable () = use (Js.import nullable) (fun fn ->
  >   Array.map (fun n -> match fn n with None -> -1 | Some n -> n) [|0; 1; 2|])
  > let run_unit () = use (Js.import unit_call) (fun fn -> fn ())
  > let load_raw () = Js.import raw
  > external uncurried_sum : (int array -> int [@u]) = "sum"
  >   [@@mel.module "audit-adapted-ffi"] [@@mel.variadic]
  > external phantom : (_ [@mel.as "prefix:"]) -> string -> string = "phantom"
  >   [@@mel.module "audit-adapted-ffi"]
  > external callback : (unit -> int [@mel.uncurry]) -> int = "callback"
  >   [@@mel.module "audit-adapted-ffi"]
  > external uncurried_callback : ((unit -> int [@mel.uncurry]) -> int [@u]) = "callback"
  >   [@@mel.module "audit-adapted-ffi"]
  > external encoding : ([ `One [@mel.as "one"] | `Two ][@mel.string]) -> string = "encoding"
  >   [@@mel.module "audit-adapted-ffi"]
  > external ignored : (int [@mel.ignore]) -> int -> int = "raw"
  >   [@@mel.module "audit-adapted-ffi"]
  > external throwing : int array -> int = "throwing"
  >   [@@mel.module "audit-adapted-ffi"] [@@mel.variadic]
  > external box : int array -> < value : int > Js.t = "Box"
  >   [@@mel.module "audit-adapted-ffi"] [@@mel.new] [@@mel.variadic]
  > external default_args : int -> int -> int = "defaultArgs" [@@mel.module "audit-adapted-ffi"]
  > external rest_args : int -> int -> int = "restArgs" [@@mel.module "audit-adapted-ffi"]
  > external extra_arity : int -> int = "extraArity" [@@mel.module "audit-adapted-ffi"]
  > external default_sum : int array -> int = "default" [@@mel.module "audit-adapted-default"] [@@mel.variadic]
  > external module_fn : int array -> int = "audit-adapted-default" [@@mel.module] [@@mel.variadic]
  > external module_class : int -> < value : int > Js.t = "audit-adapted-class" [@@mel.module] [@@mel.new]
  > external nullable_value : int option = "nullValue" [@@mel.module "audit-adapted-ffi"] [@@mel.return nullable]
  > external next : int -> int = "auditNext"
  > let run_uncurried () = use (Js.import uncurried_sum) (fun fn -> fn [|1;2;3|] [@u])
  > let run_phantom () = use (Js.import phantom) (fun fn -> fn "value")
  > let run_callback () = use (Js.import callback) (fun fn -> fn (fun () -> 7))
  > let run_uncurried_callback () = use (Js.import uncurried_callback) (fun fn -> fn (fun () -> 7) [@u])
  > let run_encoding () = use (Js.import encoding) (fun fn -> fn `One)
  > let run_ignored () = use (Js.import ignored) (fun fn -> let x = next 9 in fn x 9)
  > let run_throwing () = use (Js.import throwing) (fun fn -> fn [|1;2|])
  > let run_box () = use (Js.import box) (fun fn -> let b = fn [|1;2;3|] in b##value)
  > let run_default_args () = use (Js.import default_args) (fun fn -> fn 2 3)
  > let run_rest_args () = use (Js.import rest_args) (fun fn -> let partial = fn 2 in partial 3)
  > let run_extra_arity () = use (Js.import extra_arity) (fun fn -> fn 9)
  > let run_default_sum () = use (Js.import default_sum) (fun fn -> fn [|1;2;3|])
  > let run_module_fn () = use (Js.import module_fn) (fun fn -> fn [|1;2;3|])
  > let run_module_class () = use (Js.import module_class) (fun fn -> let b = fn 9 in b##value)
  > let run_nullable_value () = use (Js.import nullable_value) (function None -> -1 | Some n -> n)
  > let run_effects () = use (Js.import sum) (fun fn -> let a = next 1 in let b = next 2 in fn [|a;b|])
  > EOF
  $ cat > scoped.ml <<'EOF'
  > external sum : int array -> int = "sum"
  >   [@@mel.module "audit-adapted-ffi"] [@@mel.scope ("scope", "nested")] [@@mel.variadic]
  > let load () = Js.import sum
  > external raw : int -> int = "raw"
  >   [@@mel.module "audit-adapted-ffi"] [@@mel.scope ("scope", "nested")]
  > let load_raw () = Js.import raw
  > EOF
  $ cat > check.cjs <<'EOF'
  > "use strict";
  > const assert = require("node:assert/strict");
  > const fs = require("node:fs");
  > let effects = [];
  > globalThis.auditNext = n => { effects.push(n); return n; };
  > globalThis.auditFailure = new Error("foreign failure");
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const m = await import("./_build/default/out/input." + ext);
  >     if (ext === "js") assert.equal(globalThis.auditLoads, undefined);
  >     const cases = [
  >       ["sum", 6], ["unwrap", "payload"], ["optional", 7],
  >       ["nullable", [-1, -1, 8]], ["unit", 0], ["uncurried", 6],
  >       ["phantom", "prefix:value"], ["callback", 14], ["uncurried_callback", 14],
  >       ["encoding", "one"], ["box", 6], ["default_args", 5],
  >       ["rest_args", 5], ["extra_arity", 9], ["default_sum", 6],
  >       ["module_fn", 6], ["module_class", 9], ["nullable_value", -1]
  >     ];
  >     for (const [name, expected] of cases) {
  >       assert.deepEqual(await m["run_" + name](), expected, name);
  >       console.log(ext, name, "correct");
  >     }
  >     effects = [];
  >     assert.equal(await m.run_ignored(), 10);
  >     assert.deepEqual(effects, [9]);
  >     effects = [];
  >     assert.equal(await m.run_effects(), 3);
  >     assert.deepEqual(effects, [1, 2]);
  >     let thrown;
  >     assert.doesNotThrow(() => { thrown = m.run_throwing(); });
  >     await assert.rejects(thrown, e => e === globalThis.auditFailure);
  >     const target = await import("audit-adapted-ffi");
  >     assert.equal(await m.load_raw(), target.raw);
  >     assert.equal(globalThis.auditLoads, 1);
  >     const scoped = await import("./_build/default/out/scoped." + ext);
  >     assert.equal((await scoped.load())([1,2,3]), 6);
  >     assert.equal((await scoped.load_raw())(2), 3);
  >     const source = fs.readFileSync("./_build/default/out/input." + ext, "utf8");
  >     assert.doesNotMatch(source, /require\("audit-adapted-ffi"\)/);
  >     assert.doesNotMatch(source, /import .* from "audit-adapted-ffi"/);
  >     console.log(ext, "identity and lazy loading: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ echo '()' > flags.sexp
  $ dune build @melange
  $ node check.cjs
  js sum correct
  js unwrap correct
  js optional correct
  js nullable correct
  js unit correct
  js uncurried correct
  js phantom correct
  js callback correct
  js uncurried_callback correct
  js encoding correct
  js box correct
  js default_args correct
  js rest_args correct
  js extra_arity correct
  js default_sum correct
  js module_fn correct
  js module_class correct
  js nullable_value correct
  js identity and lazy loading: ok
  mjs sum correct
  mjs unwrap correct
  mjs optional correct
  mjs nullable correct
  mjs unit correct
  mjs uncurried correct
  mjs phantom correct
  mjs callback correct
  mjs uncurried_callback correct
  mjs encoding correct
  mjs box correct
  mjs default_args correct
  mjs rest_args correct
  mjs extra_arity correct
  mjs default_sum correct
  mjs module_fn correct
  mjs module_class correct
  mjs nullable_value correct
  mjs identity and lazy loading: ok
  $ echo '(--mel-cross-module-opt)' > flags.sexp
  $ dune build @melange
  $ node check.cjs
  js sum correct
  js unwrap correct
  js optional correct
  js nullable correct
  js unit correct
  js uncurried correct
  js phantom correct
  js callback correct
  js uncurried_callback correct
  js encoding correct
  js box correct
  js default_args correct
  js rest_args correct
  js extra_arity correct
  js default_sum correct
  js module_fn correct
  js module_class correct
  js nullable_value correct
  js identity and lazy loading: ok
  mjs sum correct
  mjs unwrap correct
  mjs optional correct
  mjs nullable correct
  mjs unit correct
  mjs uncurried correct
  mjs phantom correct
  mjs callback correct
  mjs uncurried_callback correct
  mjs encoding correct
  mjs box correct
  mjs default_args correct
  mjs rest_args correct
  mjs extra_arity correct
  mjs default_sum correct
  mjs module_fn correct
  mjs module_class correct
  mjs nullable_value correct
  mjs identity and lazy loading: ok
