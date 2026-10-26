ReScript #7112: cover null undefined representations.

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
  > let null_value = Js.null
  > let undefined_value = Js.undefined
  > let null_option x = Js.Null.fromOption x
  > let undefined_option x = Js.Undefined.fromOption x
  > let map_null x = Js.Null.map ~f:(fun [@u] x -> x + 1) x
  > let bind_null x = Js.Null.bind ~f:(fun [@u] x -> Js.Null.return (x + 1)) x
  > let decode_null x = Js.Json.decodeNull x
  > let decode_object x = Js.Json.decodeObject x
  > let null_test x = Js.Json.test x Js.Json.Null
  > let object_test x = Js.Json.test x Js.Json.Object
  > type sentinel = Null [@mel.as null] | Undefined [@mel.as undefined] | Value of int
  > let null_sentinel = Null
  > let undefined_sentinel = Undefined
  > let sentinel_tag = function Null -> 0 | Undefined -> 1 | Value _ -> 2
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > 
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
  >       check(`7112/${ext}`, "null primitive", () => m.null_value, null);
  >       check(`7112/${ext}`, "undefined primitive", () => m.undefined_value, undefined);
  >       check(`7112/${ext}`, "null from None", () => m.null_option(undefined), null);
  >       check(`7112/${ext}`, "null from Some", () => m.null_option(7), 7);
  >       check(`7112/${ext}`, "undefined from None", () => m.undefined_option(undefined), undefined);
  >       check(`7112/${ext}`, "null map and bind", () => [m.map_null(null),m.bind_null(null),m.map_null(7),m.bind_null(7)], [null,null,8,8]);
  >       check(`7112/${ext}`, "JSON null decoder", () => [m.decode_null(null), m.decode_null(undefined)], [null,undefined]);
  >       check(`7112/${ext}`, "JSON object decoder", () => [m.decode_object(null),m.decode_object(undefined),m.decode_object({})], [undefined,undefined,{}]);
  >       check(`7112/${ext}`, "JSON tests", () => [m.null_test(null),m.null_test(undefined),m.object_test(null),m.object_test({})], [true,false,false,true]);
  >       check(`7112/${ext}`, "variant sentinels", () => [m.null_sentinel,m.undefined_sentinel,m.sentinel_tag(null),m.sentinel_tag(undefined)], [null,undefined,0,1]);
  >     console.log(ext, "controls: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js controls: ok
  mjs controls: ok
