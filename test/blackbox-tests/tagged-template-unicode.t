ReScript #6810: cover tagged template unicode.

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
  > type result
  > external tag : (int,result) Js.TaggedTemplate.t = "auditTag"
  > let utf8 x = Js.TaggedTemplate.apply tag [|{js|“é £ × λ 漢 😀|js}; {js|終”|js}|] [|x|]
  > let bytes x = Js.TaggedTemplate.apply tag [|"“é £ × λ 漢 😀"; "終”"|] [|x|]
  > let escaping x = Js.TaggedTemplate.apply tag [|{js|`${literal}\n\uD83D\uDE00|js}; "\000\r\n\t"|] [|x|]
  > let line_separators x = Js.TaggedTemplate.apply tag [|{js|before between after|js}; ""|] [|x|]
  > EOF
  $ dune build @melange
  $ node --input-type=module <<'EOF'
  > import assert from 'node:assert/strict';
  > globalThis.auditTag = (strings, ...values) => ({strings, values});
  > for (const ext of ['js', 'mjs']) {
  >   const m = await import('./_build/default/out/input.' + ext);
  >   const unicode = ['“é £ × λ 漢 😀', '終”'];
  >   const first = m.utf8(7), again = m.utf8(8);
  >   assert.deepEqual([...first.strings], unicode);
  >   assert.deepEqual([...first.strings.raw], unicode);
  >   assert.deepEqual(first.strings.map(s => s.length), unicode.map(s => s.length));
  >   assert.equal(first.strings, again.strings);
  >   assert.ok(Object.isFrozen(first.strings));
  >   assert.ok(Object.isFrozen(first.strings.raw));
  >   assert.deepEqual(first.values, [7]);
  >   assert.deepEqual([...m.bytes(7).strings], unicode.map(s => Buffer.from(s,'utf8').toString('latin1')));
  >   assert.deepEqual([...m.escaping(7).strings], ['`${literal}\n😀','\0\r\n\t']);
  >   assert.deepEqual([...m.line_separators(7).strings], ['before\u2028between\u2029after','']);
  > }
  > EOF
