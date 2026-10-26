ReScript #7043: cover record copy representations.

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
  > type r = { a:int; b:int; c:int; d:int; e:int; f:int; g:int; h:int; i:int; j:int; k:int }
  > let copy x = { x with b = 100 }
  > let dup x = Obj.dup x
  > let discard x = ignore { x with b = 100 }
  > type large = { f00:int; f01:int; f02:int; f03:int; f04:int; f05:int; f06:int; f07:int; f08:int; f09:int; f10:int; f11:int; f12:int; f13:int; f14:int; f15:int; f16:int; f17:int; f18:int; f19:int; f20:int }
  > let large_copy x = { x with f01 = 100 }
  > let large_discard x = ignore { x with f01 = 100 }
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
  >       const record=Object.fromEntries("abcdefghijk".split("").map((k,i)=>[k,i]));
  >       check(`7043/${ext}`, "record copy", () => m.copy(record), {...record,b:100});
  >       check(`7043/${ext}`, "key order", () => Object.keys(m.copy(record)), Object.keys(record));
  >       check(`7043/${ext}`, "Obj.dup array remains array", () => Array.isArray(m.dup([1,2])), true);
  >       check(`7043/${ext}`, "Obj.dup tuple content", () => m.dup([1,2]), [1,2]);
  >       const object=Object.assign(Object.create({inherited:7}),record); const symbol=Symbol("x");object[symbol]=8;
  >       const clone=m.dup(object);
  >       check(`7043/${ext}`, "own symbols copied, prototype flattened", () => [clone[symbol],Object.hasOwn(clone,"inherited"),Object.getPrototypeOf(clone)===Object.prototype], [8,false,true]);
  >       let reads=0;
  >       const getter={...record};Object.defineProperty(getter,"a",{enumerable:true,get(){reads++;return 7;}});
  >       m.copy(getter);check(`7043/${ext}`, "FFI getter read once by copy", () => reads, 1);
  >       const large=Object.fromEntries(Array.from({length:21},(_,i)=>[`f${String(i).padStart(2,"0")}`,i]));
  >       check(`7043/${ext}`, "large record copy", () => m.large_copy(large), {...large,f01:100});
  >       check(`7043/${ext}`, "large record key order", () => Object.keys(m.large_copy(large)), Object.keys(large));
  >     const js = require("node:fs").readFileSync("./_build/default/out/input." + ext, "utf8");
  >     const fn = js.slice(js.indexOf("function large_copy("));
  >     console.log(ext, "large copy uses runtime:", fn.slice(0, fn.indexOf("\n}")).includes("caml_obj_dup"));
  >     console.log(ext, "controls: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  js large copy uses runtime: true
  js controls: ok
  mjs large copy uses runtime: true
  mjs controls: ok
