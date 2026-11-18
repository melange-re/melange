Read-only string readers should avoid copying the whole source to bytes.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.20)
  > (using melange 1.0)
  > EOF
  $ echo '(melange.emit (target out) (compile_flags :standard --mel-cross-module-opt) (preprocess (pps melange.ppx)))' > dune
  $ cat > reader.ml <<'EOF'
  > external retain : bytes -> bytes -> unit = "retainBytes" [@@mel.scope "globalThis"]
  > let reader b =
  >   let alias = b in
  >   fun () -> Char.code (Bytes.get alias 0)
  > let sum b =
  >   let total = ref 0 in
  >   for i = 0 to 2 do
  >     total := !total + Char.code (Bytes.get b i)
  >   done;
  >   !total
  > let mutate b =
  >   let alias = b in
  >   Bytes.set alias 0 'z';
  >   Char.code (Bytes.get b 0)
  > let escape_bytes b =
  >   let alias = b in
  >   retain alias b;
  >   fun () -> Char.code (Bytes.get b 0)
  > let return_bytes b = b
  > EOF
  $ cat > input.ml <<'EOF'
  > external source : unit -> string = "readSource" [@@mel.scope "globalThis"]
  > external offset : unit -> int = "readOffset" [@@mel.scope "globalThis"]
  > let read s i =
  >   let b = Bytes.unsafe_of_string s in
  >   let alias = b in
  >   Char.code (Bytes.get alias i)
  > let direct_read s i = Char.code (Bytes.get (Bytes.unsafe_of_string s) i)
  > let read16 s i = Bytes.get_uint16_ne (Bytes.unsafe_of_string s) i
  > let read32 s i = Bytes.get_int32_ne (Bytes.unsafe_of_string s) i
  > let bytes16 b i = Bytes.get_uint16_ne b i
  > let bytes32 b i = Bytes.get_int32_ne b i
  > let exists s = String.exists (fun c -> c = 'a') s
  > let exists_pred p s = String.exists p s
  > let for_all s = String.for_all (fun c -> c <> 'a') s
  > let mutable_reader s = Reader.sum (Bytes.unsafe_of_string s)
  > let first_later s =
  >   let seq = String.to_seq s in
  >   fun () -> match seq () with
  >     | Seq.Nil -> -1
  >     | Seq.Cons (c, _) -> Char.code c
  > let direct_readers first second =
  >   let rec collect acc = function
  >     | [] -> acc
  >     | s :: rest ->
  >         collect (Reader.reader (Bytes.unsafe_of_string s) :: acc) rest
  >   in
  >   match collect [] [first; second] with
  >   | [last; first] -> first (), last ()
  >   | _ -> assert false
  > let seq_readers first second =
  >   let rec collect acc = function
  >     | [] -> acc
  >     | s :: rest -> collect (String.to_seq s :: acc) rest
  >   in
  >   let head seq = match seq () with
  >     | Seq.Nil -> -1
  >     | Seq.Cons (c, _) -> Char.code c
  >   in
  >   match collect [] [first; second] with
  >   | [last; first] -> head first, head last
  >   | _ -> assert false
  > let mutate s = Reader.mutate (Bytes.unsafe_of_string s)
  > let escape_bytes s = Reader.escape_bytes (Bytes.unsafe_of_string s)
  > let return_bytes s = Reader.return_bytes (Bytes.unsafe_of_string s)
  > let effects () =
  >   Char.code (Bytes.get (Bytes.unsafe_of_string (source ())) (offset ()))
  > let bounds () =
  >   try ignore (read "" 0); false with Invalid_argument _ -> true
  > EOF
  $ dune build --disable-promotion --profile release @melange
  $ node <<'JS'
  > const t = require('./_build/default/out/input.js');
  > const source = 'a'.repeat(4096);
  > function measured(name, run, maxReads = 1) {
  >   const original = String.prototype.charCodeAt;
  >   let reads = 0, result;
  >   String.prototype.charCodeAt = function (index) {
  >     ++reads;
  >     return original.call(this, index);
  >   };
  >   try { result = run(); }
  >   finally { String.prototype.charCodeAt = original; }
  >   console.log(name, result, reads <= maxReads);
  > }
  > measured('direct_read', () => t.direct_read(source, 0));
  > measured('read16', () => t.read16(source, 0), 2);
  > measured('read32', () => t.read32(source, 0), 4);
  > measured('exists', () => t.exists(source));
  > measured('for_all', () => t.for_all(source));
  > measured('first_later', () => t.first_later(source)());
  > measured('mutable_reader', () => t.mutable_reader(source), 3);
  > console.log('alias_read', t.read('abc', 1));
  > console.log('mutable_reader', t.mutable_reader('abc'));
  > console.log('direct_readers', ...t.direct_readers('a', 'b'));
  > console.log('seq_readers', ...t.seq_readers('a', 'b'));
  > console.log('mutate', t.mutate('abc'));
  > let retained;
  > global.retainBytes = (left, right) => {
  >   console.log('retain', Array.isArray(left), typeof left[0], left === right);
  >   retained = left;
  > };
  > const later = t.escape_bytes('abc');
  > retained[0] = 122;
  > console.log('escape', later());
  > const returned = t.return_bytes('abc');
  > console.log('return', Array.isArray(returned), typeof returned[0], returned[0]);
  > const events = [];
  > global.readSource = () => { events.push('source'); return 'abc'; };
  > global.readOffset = () => { events.push('offset'); return 1; };
  > console.log('effects', t.effects(), events.join(','));
  > console.log('code_unit', t.read('\u1234', 0));
  > console.log('direct_code_unit', t.direct_read('\u1234', 0));
  > const assert = require('node:assert/strict');
  > function outcome(f) {
  >   try { return f(); }
  >   catch (e) { return [e.MEL_EXN_ID, e._1]; }
  > }
  > for (const text of ['', 'abc', '\u1234\ud800\uffff\u0100abcd']) {
  >   const bytes = Array.from({ length: text.length }, (_, i) => text.charCodeAt(i));
  >   for (let i = -1; i <= text.length; ++i) {
  >     assert.deepEqual(outcome(() => t.read16(text, i)), outcome(() => t.bytes16(bytes, i)));
  >     assert.deepEqual(outcome(() => t.read32(text, i)), outcome(() => t.bytes32(bytes, i)));
  >   }
  > }
  > console.log('wide_reads', true);
  > const visited = [];
  > const found = t.exists_pred(c => { visited.push(c); return c === 98; }, 'abc');
  > console.log('callback', found, visited.join(','));
  > const sentinel = {};
  > try { t.exists_pred(() => { throw sentinel; }, 'abc'); }
  > catch (e) { console.log('callback_exception', e === sentinel); }
  > console.log('bounds', t.bounds());
  > JS
  direct_read 97 true
  read16 24929 true
  read32 1633771873 true
  exists true true
  for_all false true
  first_later 97 true
  mutable_reader 291 true
  alias_read 98
  mutable_reader 294
  direct_readers 97 98
  seq_readers 97 98
  mutate 122
  retain true number true
  escape 122
  return true number 97
  effects 98 source,offset
  code_unit 4660
  direct_code_unit 4660
  wide_reads true
  callback true 97,98
  callback_exception true
  bounds true
