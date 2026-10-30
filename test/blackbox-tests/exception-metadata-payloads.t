ReScript #6979: cover exception metadata payloads.
The printed cases characterize the current incorrect behavior.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
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
  > let rethrow_js x = try throw_js x with e -> raise e
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
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js');
  > globalThis.auditThrow = x => { throw x; };
  > const plain=m.value(7), record=m.record(7), exn=m.exception_value(7), caught=m.caught(7), fields=m.exception_fields(7);
  > assert.deepEqual([plain instanceof Error,record instanceof Error,m.open_match(plain),m.open_match(record)], [false,false,7,7]);
  > assert.deepEqual([caught instanceof Error,caught.name,m.exn_match(caught)], [true,'MelangeError',7]);
  > assert.deepEqual([m.exn_match(exn),m.alias_match(exn),m.exn_match(fields)], [7,7,7]);
  > assert.equal(m.equal(m.a,m.b), false);
  > assert.deepEqual([m.equal(exn,caught),m.equal(caught,exn),m.hash(exn) === m.hash(caught)], [true,true,true]);
  > assert.equal(m.equal(new Error('plain'),plain), false);
  > assert.throws(() => m.reraised(caught), e => e === caught);
  > const foreign = new Error('foreign');
  > assert.equal(m.catch_js(foreign), foreign);
  > assert.throws(() => m.rethrow_js(foreign), e => e === foreign);
  > const metadata=m.metadata('n','m','s',1), caughtMetadata=m.caught_metadata('n','m','s',1);
  > assert.deepEqual([m.metadata_match(metadata),m.metadata_match(caughtMetadata)], [['n','m','s',1],['n','m','s',1]]);
  > assert.deepEqual([m.equal(metadata,caughtMetadata),m.equal(caughtMetadata,metadata)], [true,true]);
  > for (const [field,values] of [['name',['changed','m','s',1]], ['message',['n','changed','s',1]],
  >                             ['stack',['n','m','changed',1]], ['cause',['n','m','s',2]]])
  >   console.log(field, m.equal(caughtMetadata,m.caught_metadata(...values)));
  > EOF
  name true
  message true
  stack true
  cause true
