ReScript #6979: cover exception metadata payloads.
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
  > type open_ = ..
  > type open_ += Value of int | Record of { value:int }
  > exception Payload of int
  > exception Fields of { value:int }
  > exception Alias = Payload
  > let value x = Value x
  > let record x = Record {value=x}
  > let exception_value x = Payload x
  > let exception_fields x = Fields {value=x}
  > let caught x = try raise (Payload x) with exn -> exn
  > let open_match = function Value x -> x | Record {value} -> value | _ -> -1
  > let exn_match = function Payload x -> x | Fields {value} -> value | _ -> -1
  > let alias_match = function Alias x -> x | _ -> -1
  > let equal a b = a = b
  > let hash x = Hashtbl.hash x
  > let reraised exn = try raise exn with e -> raise e
  > external throw_js : 'a -> unit = "auditThrow"
  > external inspect : exn -> unit = "auditInspect"
  > let rethrow_js x = try throw_js x with e -> raise e
  > let inspect_and_rethrow x = try throw_js x with e -> inspect e; raise e
  > let catch_js x = try throw_js x; None with Js.Exn.Error e -> Some e
  > module Make () = struct exception E of int let value x = E x end
  > module A = Make ()
  > module B = Make ()
  > let a = A.value 1
  > let b = B.value 1
  > exception Metadata of { name:string; message:string; stack:string; cause:int }
  > let metadata name message stack cause = Metadata {name;message;stack;cause}
  > let caught_metadata name message stack cause =
  >   try raise (Metadata {name;message;stack;cause}) with exn -> exn
  > let metadata_match = function Metadata {name;message;stack;cause} -> (name,message,stack,cause) | _ -> assert false
  > EOF
  $ dune build @melange
  $ cat > check.cjs <<'EOF'
  > const assert = require("node:assert/strict");
  > let hits = [];
  > globalThis.auditThrow = x => { throw x; };
  > globalThis.auditInspect = x => { hits.push(x.MEL_EXN_ID); };
  > 
  > const characterized = new Set(["metadata payload name differs", "metadata payload message differs", "metadata payload stack differs", "metadata payload cause differs"]);
  > function check(group, name, run, expected) {
  >   const actual = run();
  >   if (characterized.has(name)) console.log(group, name, JSON.stringify(actual));
  >   else assert.deepStrictEqual(actual, expected, name);
  > }
  > (async () => {
  >   for (const ext of ["js", "mjs"]) {
  >     const m = await import("./_build/default/out/input." + ext);
  >       const plain=m.value(7), record=m.record(7), exn=m.exception_value(7), caught=m.caught(7), fields=m.exception_fields(7);
  >       check(`6979/${ext}`, "open variants are plain values", () => [plain instanceof Error,record instanceof Error,m.open_match(plain),m.open_match(record)], [false,false,7,7]);
  >       check(`6979/${ext}`, "raised exceptions are Error instances", () => [caught instanceof Error,caught.name,m.exn_match(caught)], [true,"MelangeError",7]);
  >       check(`6979/${ext}`, "exception and alias matching", () => [m.exn_match(exn),m.alias_match(exn),m.exn_match(fields)], [7,7,7]);
  >       check(`6979/${ext}`, "constructor generation distinguishes functors", () => m.equal(m.a,m.b), false);
  >       check(`6979/${ext}`, "raised/unraised equality", () => [m.equal(exn,caught),m.equal(caught,exn),m.hash(exn)===m.hash(caught)], [true,true,true]);
  >       check(`6979/${ext}`, "native Error distinct from plain extension", () => m.equal(new Error("plain"),plain), false);
  >       check(`6979/${ext}`, "rethrow OCaml identity", () => {try{m.reraised(caught);}catch(e){return e===caught;}}, true);
  >       const foreign=new Error("foreign");
  >       check(`6979/${ext}`, "catch foreign identity", () => m.catch_js(foreign)===foreign, true);
  >       check(`6979/${ext}`, "rethrow foreign identity", () => {try{m.rethrow_js(foreign);}catch(e){return e===foreign;}}, true);
  >       const metadata=m.metadata("n","m","s",1), caughtMetadata=m.caught_metadata("n","m","s",1);
  >       check(`6979/${ext}`, "metadata field payload matching", () => [m.metadata_match(metadata),m.metadata_match(caughtMetadata)], [["n","m","s",1],["n","m","s",1]]);
  >       check(`6979/${ext}`, "metadata fields raised/unraised equality", () => [m.equal(metadata,caughtMetadata),m.equal(caughtMetadata,metadata)], [true,true]);
  >       for(const [name,values] of [["name",["changed","m","s",1]],["message",["n","changed","s",1]],["stack",["n","m","changed",1]],["cause",["n","m","s",2]]])
  >         check(`6979/${ext}`, `metadata payload ${name} differs`, () => m.equal(caughtMetadata,m.caught_metadata(...values)), false);
  >     console.log(ext, "controls: ok");
  >   }
  > })().catch(e => { console.error(e); process.exitCode = 1; });
  > EOF
  $ node check.cjs
  6979/js metadata payload name differs true
  6979/js metadata payload message differs true
  6979/js metadata payload stack differs true
  6979/js metadata payload cause differs true
  js controls: ok
  6979/mjs metadata payload name differs true
  6979/mjs metadata payload message differs true
  6979/mjs metadata payload stack differs true
  6979/mjs metadata payload cause differs true
  mjs controls: ok
