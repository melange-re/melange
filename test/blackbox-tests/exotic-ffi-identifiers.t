ReScript #6658 / #6777 concern quoted uppercase type identifiers in its parser.
Cover supported Melange type paths, unusual FFI property names, and local mangling.
Empty property names are valid. Ordinary OCaml strings retain byte semantics,
including UTF-8 source bytes; this differs from ReScript Unicode strings.

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
  > module Upper = struct
  >   type t = { value : int }
  > end
  > type alias = Upper.t
  > let read_alias ({ Upper.value } : alias) = value
  > type fields = {
  >   upper : int [@mel.as "Upper"];
  >   dashed : int [@mel.as "a-b"];
  >   reserved : int [@mel.as "default"];
  >   unicode : int [@mel.as "λ"];
  >   digit : int [@mel.as "1st"];
  >   escaped : int [@mel.as "a\"b\\c"];
  >   empty : int [@mel.as ""];
  > }
  > external external_get_dash : fields -> int = "a-b" [@@mel.get]
  > external external_get_unicode : fields -> int = "λ" [@@mel.get]
  > external external_set_escaped : fields -> int -> unit = "a\"b\\c" [@@mel.set]
  > external index : fields -> string -> int = "" [@@mel.get_index]
  > let get_empty x = index x ""
  > external external_send_dash : 'a -> int -> int = "a-b" [@@mel.send]
  > let get_dash x = external_get_dash x
  > let get_unicode x = external_get_unicode x
  > let set_escaped x v = external_set_escaped x v
  > let send_dash x v = external_send_dash x v
  > let record () = {upper=1; dashed=2; reserved=3; unicode=4; digit=5; escaped=6; empty=7}
  > let read x = x.upper + x.dashed + x.reserved + x.unicode + x.digit + x.escaped + x.empty
  > let switch = 8
  > let name' = 9
  > let type_ = 10
  > let mangle () = switch + name' + type_
  > EOF
  $ dune build @melange
  $ node --input-type=module <<'EOF'
  > import assert from "node:assert/strict";
  > for (const ext of ["js", "mjs"]) {
  >   const file = "./_build/default/out/input." + ext;
  >   const m = await import(file);
  >   assert.equal(m.read_alias({value: 42}), 42);
  >   const r = m.record();
  >   assert.deepEqual(r, {Upper:1, "a-b":2, default:3, "\xce\xbb":4, "1st":5, 'a"b\\c':6, "":7});
  >   assert.equal(m.read(r), 28);
  >   assert.equal(m.get_dash(r), 2);
  >   assert.equal(m.get_unicode(r), 4);
  >   assert.equal(m.get_empty(r), 7);
  >   m.set_escaped(r, 11);
  >   assert.equal(r['a"b\\c'], 11);
  >   const receiver = {base: 10, "a-b"(x) {return this.base + x;}};
  >   assert.equal(m.send_dash(receiver, 2), 12);
  >   assert.equal(m.mangle(), 27);
  > }
  > EOF
