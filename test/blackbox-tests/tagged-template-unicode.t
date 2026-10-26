ReScript #6810: cover tagged template unicode.

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
  > external tag : (int,result) Js.TaggedTemplate.t = "auditTag"
  > let utf8 x = Js.TaggedTemplate.apply tag [|{js|“é £ × λ 漢 😀|js}; {js|終”|js}|] [|x|]
  > let bytes x = Js.TaggedTemplate.apply tag [|"“é £ × λ 漢 😀"; "終”"|] [|x|]
  > let escaping x = Js.TaggedTemplate.apply tag [|{js|`${literal}\n\uD83D\uDE00|js}; "\000\r\n\t"|] [|x|]
  > let line_separators x = Js.TaggedTemplate.apply tag [|{js|before between after|js}; ""|] [|x|]
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > globalThis.auditTag = (strings, ...values) => ({strings, values});
  > 
  > const characterized = new Set([]);
  > function check(group, name, run, expected) {
  >   const actual = run();
  >   if (characterized.has(name)) console.log(group, name, JSON.stringify(actual));
  >   else assert.deepStrictEqual(actual, expected, name);
  > }
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const m = await import("./_build/default/out/input." + ext);
  >       const unicode=["“é £ × λ 漢 😀","終”"];
  >       const first=m.utf8(7),again=m.utf8(8);
  >       check(`6810/${ext}`, "Unicode cooked fragments", () => [...first.strings], unicode);
  >       check(`6810/${ext}`, "Unicode raw fragments", () => [...first.strings.raw], unicode);
  >       check(`6810/${ext}`, "UTF-16 lengths", () => first.strings.map(s=>s.length), unicode.map(s=>s.length));
  >       check(`6810/${ext}`, "site identity and frozen arrays", () => [first.strings===again.strings,Object.isFrozen(first.strings),Object.isFrozen(first.strings.raw)], [true,true,true]);
  >       check(`6810/${ext}`, "interpolation", () => first.values, [7]);
  >       check(`6810/${ext}`, "ordinary strings preserve UTF-8 bytes", () => [...m.bytes(7).strings], unicode.map(s=>Buffer.from(s,"utf8").toString("latin1")));
  >       check(`6810/${ext}`, "escaping and controls", () => [...m.escaping(7).strings], ["`${literal}\n😀","\0\r\n\t"]);
  >       check(`6810/${ext}`, "Unicode line separators", () => [...m.line_separators(7).strings], ["before\u2028between\u2029after",""]);
  >     console.log(ext, "controls: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js controls: ok
  mjs controls: ok
