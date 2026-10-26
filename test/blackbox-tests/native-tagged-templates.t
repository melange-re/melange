ReScript #6250 / Melange #342: native tagged-template interop via raw JavaScript.
Exercise the semantics a dedicated FFI feature must preserve, including observable
tag effects, receiver binding, frozen raw strings, and per-site array identity.

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
  > type result
  > let template : (int -> result [@u]) =
  >   [%mel.raw {|function(x) { return globalThis.auditTag`value:${x}`; }|}]
  > let escaped : (string -> result [@u]) =
  >   [%mel.raw {|function(x) { return globalThis.auditTag`line\n${x}\`\${literal}\\end`; }|}]
  > let multiple : (int -> 'a -> result [@u]) =
  >   [%mel.raw {|function(x, y) { return globalThis.auditTag`a${x}b${y}c`; }|}]
  > let receiver : (int -> result [@u]) =
  >   [%mel.raw {|function(x) { return globalThis.auditScope.tag`receiver:${x}`; }|}]
  > let empty : (unit -> result [@u]) =
  >   [%mel.raw {|function() { return globalThis.auditTag``; }|}]
  > let apply x = (template x [@u])
  > let apply_again x = (template x [@u])
  > let discard x = ignore (template x [@u])
  > let escaped_call x = (escaped x [@u])
  > let multiple_call x y = (multiple x y [@u])
  > let receiver_call x = (receiver x [@u])
  > let empty_call () = (empty () [@u])
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > const {execFileSync} = require("node:child_process");
  > let calls = 0;
  > globalThis.auditTag = (strings, ...values) => {
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
  >     const first = m.apply(1);
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

The dedicated FFI annotation is not recognized on the baseline compiler.

  $ cat > unsupported.ml <<'EOF'
  > external tag : string array -> int array -> string = "tag" [@@mel.tagged_template]
  > let call x = tag [|"value:"; ""|] [|x|]
  > EOF
  $ melc -ppx melppx -c unsupported.ml
  File "unsupported.ml", line 1, characters 62-81:
  1 | external tag : string array -> int array -> string = "tag" [@@mel.tagged_template]
                                                                    ^^^^^^^^^^^^^^^^^^^
  Alert unused: Unused attribute [@mel.tagged_template]
  This means such annotation is not annotated properly.
  For example, some annotations are only meaningful in externals
  
  File "unsupported.ml", line 1, characters 0-82:
  1 | external tag : string array -> int array -> string = "tag" [@@mel.tagged_template]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error (alert unprocessed): `[@mel.*]' attributes found in external declaration. Did you forget to preprocess with `melange.ppx'?
  [2]
