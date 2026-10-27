ReScript #6896: nullable tuple patterns must select the correct branch.
Check every option/nullable combination, default branches, and effects.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > external note : int -> unit = "auditNote"
  > external get : unit -> int Js.Nullable.t = "auditGet"
  > let select index pane dom =
  >   match (index, pane), Js.Nullable.toOption dom with
  >   | (Some i, Some p), Some element -> note 1; i + p + element
  >   | (Some i, Some p), None -> note 2; i - p
  >   | _ -> note 3; -99
  > let from_effect index pane = select index pane (get ())
  > let nested index pane dom =
  >   match index, pane with
  >   | Some i, Some p ->
  >     (match Js.Nullable.toOption dom with
  >      | Some element when element > 0 -> i + p + element
  >      | Some _ -> 0
  >      | None -> i - p)
  >   | _ -> -99
  > EOF
  $ cat > dune-project <<'EOF'
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange)
  >  (preprocess (pps melange.ppx))
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const m = await import("./_build/default/out/input." + ext);
  >     for (const i of [undefined, 0, 7]) for (const p of [undefined, 0, 3]) {
  >       for (const dom of [null, undefined, -2, 0, 5]) {
  >         const events = [];
  >         globalThis.auditNote = n => events.push(n);
  >         globalThis.auditGet = () => { events.push("get"); return dom; };
  >         const both = i !== undefined && p !== undefined;
  >         const branch = !both ? 3 : dom == null ? 2 : 1;
  >         const expected = !both ? -99 : dom == null ? i - p : i + p + dom;
  >         assert.equal(m.select(i, p, dom), expected);
  >         assert.deepEqual(events, [branch]);
  >         events.length = 0;
  >         assert.equal(m.from_effect(i, p), expected);
  >         assert.deepEqual(events, ["get", branch]);
  >         assert.equal(m.nested(i, p, dom), !both ? -99 : dom == null ? i - p : dom > 0 ? i + p + dom : 0);
  >       }
  >     }
  >     const failure = new Error("nullable input");
  >     globalThis.auditGet = () => { throw failure; };
  >     assert.throws(() => m.from_effect(undefined, undefined), e => e === failure);
  >     globalThis.auditNote = () => { throw failure; };
  >     assert.throws(() => m.select(7, 3, null), e => e === failure);
  >     const source = require("node:fs").readFileSync("./_build/default/out/input." + ext, "utf8");
  >     assert.doesNotMatch(source, /^\s*\w+\s*===\s*(null|undefined);\s*$/m);
  >     console.log(ext, "nullable tuple branches and effects: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js nullable tuple branches and effects: ok
  mjs nullable tuple branches and effects: ok
