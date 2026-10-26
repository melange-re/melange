Tagged-template FFI preserves native template semantics, including call-site identity.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (runtime_deps tag-fixture.cjs)
  >  (compile_flags -mel-cross-module-opt)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx))
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ cat > tag-fixture.cjs <<'EOF'
  > "use strict";
  > exports.tag = function(strings, ...values) {
  >   if (this !== undefined) throw new Error("unexpected module receiver");
  >   const tag = globalThis.auditTag;
  >   return tag(strings, ...values);
  > };
  > EOF
  $ cat > input.ml <<'EOF'
  > type result
  > external tag : ('a, result) Js.TaggedTemplate.t = "auditTag"
  > external receiver : (int, result) Js.TaggedTemplate.t = "tag"
  >   [@@mel.scope "auditScope"]
  > external imported : (int, result) Js.TaggedTemplate.t = "tag"
  >   [@@mel.module "./tag-fixture.cjs"]
  > external next : int -> int = "templateNext"
  > external get_tag : unit -> (int, result) Js.TaggedTemplate.t = "templateGetTag"
  > external scope : 'a = "auditScope"
  > external bind : ('a, 'b) Js.TaggedTemplate.t -> 'c -> ('a, 'b) Js.TaggedTemplate.t = "bind" [@@mel.send]
  > let apply x = Js.TaggedTemplate.apply tag [|"value:"; ""|] [|x|]
  > let apply_again x = apply x
  > let forced x = Js.TaggedTemplate.apply tag [|""; ""|] [|x|] [@@inline always]
  > let forced_again x = forced x
  > let factory () =
  >   let offset = ref 0 in
  >   fun x -> incr offset; Js.TaggedTemplate.apply tag [|""; ""|] [|x + !offset|]
  > let discard x = ignore (Js.TaggedTemplate.apply tag [|"value:"; ""|] [|x|])
  > let escaped_call x = Js.TaggedTemplate.apply tag [|"line\n"; "`${literal}\\end"|] [|x|]
  > let multiple_call x y = Js.TaggedTemplate.apply tag [|"a"; "b"; "c"|] [|Obj.repr x; Obj.repr y|]
  > let receiver_call x = Js.TaggedTemplate.apply (bind receiver scope) [|"receiver:"; ""|] [|x|]
  > let empty_call () = Js.TaggedTemplate.apply tag [|""|] [||]
  > let unicode_call x = Js.TaggedTemplate.apply tag [|{js|λ|js}; ""|] [|x|]
  > let imported_call x = Js.TaggedTemplate.apply imported [|"import:"; ""|] [|x|]
  > let selected flag x = Js.TaggedTemplate.apply (if flag then tag else imported) [|"selected:"; ""|] [|x|]
  > let dynamic flag = Js.TaggedTemplate.apply (get_tag ()) [|""; ""; ""|] [|next 1; (if flag then next 2 else next 3)|]
  > let effects () = Js.TaggedTemplate.apply tag [|""; ""; ""|] [|next 1; next 2|]
  > let site_one x = Js.TaggedTemplate.apply tag [|""; ""|] [|x|]
  > let site_two x = Js.TaggedTemplate.apply tag [|""; ""|] [|x|]
  > let choose flag x = if flag then site_one x else site_two x
  > let choose_direct flag x =
  >   if flag then Js.TaggedTemplate.apply tag [|""; ""|] [|x|]
  >   else Js.TaggedTemplate.apply tag [|""; ""|] [|x|]
  > EOF
  $ cat > consumer.ml <<'EOF'
  > let apply x = Input.apply x
  > let again x = Input.apply x
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > "use strict";
  > const assert = require("node:assert/strict");
  > const {execFileSync} = require("node:child_process");
  > let calls = 0, hits = [];
  > globalThis.templateNext = n => {hits.push(n); return n;};
  > globalThis.templateGetTag = () => {hits.push(0); return globalThis.auditTag;};
  > globalThis.auditTag = function(strings, ...values) {
  >   assert.equal(this, undefined);
  >   calls++;
  >   assert.equal(Object.isFrozen(strings), true);
  >   assert.equal(Object.isFrozen(strings.raw), true);
  >   return {strings, values};
  > };
  > globalThis.auditScope = {
  >   marker: {},
  >   tag(strings, ...values) { return {receiver: this.marker, strings, values}; }
  > };
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const file = "./_build/default/out/input." + ext;
  >     execFileSync(process.execPath, ["--check", file]);
  >     const m = await import(file);
  >     const consumer = await import("./_build/default/out/consumer." + ext);
  >     const first = m.apply(1);
  >     assert.equal(first.strings, consumer.apply(1).strings);
  >     assert.equal(first.strings, consumer.again(1).strings);
  >     assert.equal(m.forced(1).strings, m.forced_again(1).strings);
  >     assert.equal(m.factory()(1).strings, m.factory()(2).strings);
  >     assert.notEqual(m.site_one(1).strings, m.site_two(1).strings);
  >     assert.notEqual(m.choose_direct(true, 1).strings, m.choose_direct(false, 1).strings);
  >     assert.notEqual(m.choose(true, 1).strings, m.choose(false, 1).strings);
  >     assert.deepEqual([...m.unicode_call(1).strings], ["λ", ""]);
  >     assert.deepEqual([...m.imported_call(1).strings], ["import:", ""]);
  >     hits = [];
  >     assert.deepEqual(m.effects().values, [1, 2]);
  >     assert.deepEqual(hits, [1, 2]);
  >     hits = [];
  >     assert.deepEqual(m.dynamic(true).values, [1, 2]);
  >     assert.deepEqual(hits, [0, 1, 2]);
  >     for (const flag of [false, true]) assert.deepEqual(m.selected(flag, 4).values, [4]);
  >     const getTag = globalThis.templateGetTag, getError = {};
  >     globalThis.templateGetTag = () => {throw getError;};
  >     hits = [];
  >     assert.throws(() => m.dynamic(true), e => e === getError);
  >     assert.deepEqual(hits, []);
  >     globalThis.templateGetTag = getTag;
  >     assert.deepEqual([...first.strings], ["value:", ""]);
  >     assert.deepEqual(first.values, [1]);
  >     assert.equal(first.strings, m.apply(2).strings);
  >     assert.equal(first.strings, m.apply_again(3).strings);
  >     const escaped = m.escaped_call("x");
  >     assert.deepEqual([...escaped.strings], ["line\n", "`\${literal}\\end"]);
  >     assert.deepEqual([...escaped.strings.raw], ["line\\n", "\\`\\${literal}\\\\end"]);
  >     const object = {};
  >     const multi = m.multiple_call(7, object);
  >     assert.deepEqual([...multi.strings], ["a", "b", "c"]);
  >     assert.deepEqual(multi.values, [7, object]);
  >     assert.equal(multi.values[1], object);
  >     const received = m.receiver_call(9);
  >     assert.equal(received.receiver, globalThis.auditScope.marker);
  >     assert.deepEqual(received.values, [9]);
  >     const empty = m.empty_call();
  >     assert.deepEqual([...empty.strings], [""]);
  >     assert.deepEqual(empty.values, []);
  >     const before = calls;
  >     m.discard(1);
  >     assert.equal(calls, before + 1);
  >     const saved = globalThis.auditTag, thrown = {};
  >     globalThis.auditTag = () => { throw thrown; };
  >     assert.throws(() => m.discard(2), e => e === thrown);
  >     globalThis.auditTag = saved;
  >     console.log(ext, "native templates, effects, raw strings and site identity: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js native templates, effects, raw strings and site identity: ok
  mjs native templates, effects, raw strings and site identity: ok

Unsupported uses must produce diagnostics rather than compiler assertions.

  $ cat > dynamic.ml <<'EOF'
  > external tag : (int, string) Js.TaggedTemplate.t = "tag"
  > let call strings values = Js.TaggedTemplate.apply tag strings values
  > EOF
  $ melc -ppx melppx -o dynamic.js dynamic.ml
  File "dynamic.ml", line 2, characters 26-68:
  2 | let call strings values = Js.TaggedTemplate.apply tag strings values
                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: Js.TaggedTemplate.apply requires literal string and value arrays, with one more string than values
  [2]
  $ cat > count.ml <<'EOF'
  > external tag : (int, string) Js.TaggedTemplate.t = "tag"
  > let call x = Js.TaggedTemplate.apply tag [|"only"|] [|x|]
  > EOF
  $ melc -ppx melppx -o count.js count.ml
  File "count.ml", line 2, characters 13-57:
  2 | let call x = Js.TaggedTemplate.apply tag [|"only"|] [|x|]
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: Js.TaggedTemplate.apply requires literal string and value arrays, with one more string than values
  [2]
  $ cat > fragment.ml <<'EOF'
  > external tag : (int, string) Js.TaggedTemplate.t = "tag"
  > let call fragment x = Js.TaggedTemplate.apply tag [|fragment; ""|] [|x|]
  > EOF
  $ melc -ppx melppx -o fragment.js fragment.ml
  File "fragment.ml", line 2, characters 22-72:
  2 | let call fragment x = Js.TaggedTemplate.apply tag [|fragment; ""|] [|x|]
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: Js.TaggedTemplate.apply requires literal string and value arrays, with one more string than values
  [2]
  $ cat > partial.ml <<'EOF'
  > external tag : (int, string) Js.TaggedTemplate.t = "tag"
  > let call = Js.TaggedTemplate.apply tag
  > EOF
  $ melc -ppx melppx -o partial.js partial.ml
  File "partial.ml", line 2, characters 11-38:
  2 | let call = Js.TaggedTemplate.apply tag
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: Js.TaggedTemplate.apply requires literal string and value arrays, with one more string than values
  [2]
  $ cat > wrong_type.ml <<'EOF'
  > external tag : (int, string) Js.TaggedTemplate.t = "tag"
  > let call = Js.TaggedTemplate.apply tag [|""; ""|] [|"string"|]
  > EOF
  $ melc -ppx melppx -o wrong_type.js wrong_type.ml
  File "wrong_type.ml", line 2, characters 52-60:
  2 | let call = Js.TaggedTemplate.apply tag [|""; ""|] [|"string"|]
                                                          ^^^^^^^^
  Error: This constant has type string but an expression was expected of type
           int
  [2]
