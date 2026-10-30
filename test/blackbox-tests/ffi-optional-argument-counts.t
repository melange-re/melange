ReScript #6653: cover ffi optional argument counts.
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
  > external count : ?x:int -> ?y:int -> unit -> int = "auditCount"
  > external opt_undefined : ?x:int Js.undefined -> unit -> int = "auditCount"
  > external opt_unit : ?x:unit -> unit -> int = "auditCount"
  > external required_undefined : int Js.undefined -> int = "auditCount"
  > external ignored_before : (int [@mel.ignore]) -> ?x:int -> unit -> int = "auditCount"
  > external ignored_after : ?x:int -> (int [@mel.ignore]) -> unit -> int = "auditCount"
  > external unit_before : unit -> ?x:int -> unit -> int = "auditCount"
  > external tick : int -> int = "auditTick"
  > external construct : ?x:int -> unit -> < count : int > Js.t = "AuditCtor" [@@mel.new]
  > external send : 'a -> ?x:int -> unit -> int = "count" [@@mel.send]
  > let omitted () = count ()
  > let none () = count ?x:None ?y:None ()
  > let some () = count ~x:1 ()
  > let interior () = count ~y:2 ()
  > let dynamic x = count ?x ()
  > let explicit_undefined () = opt_undefined ~x:Js.undefined ()
  > let explicit_unit () = opt_unit ~x:() ()
  > let required () = required_undefined Js.undefined
  > let erased_before () = ignored_before 7 ()
  > let erased_after () = ignored_after 7 ()
  > let erased_effect () = ignored_before (tick 7) ()
  > let erased_unit () = unit_before () ()
  > let new_omitted () = construct ()
  > let send_omitted receiver = send receiver ()
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js');
  > const hits = [];
  > globalThis.auditCount = function() { return arguments.length; };
  > globalThis.auditTick = n => { hits.push(n); return n; };
  > globalThis.AuditCtor = function() { this.count = arguments.length; };
  > for (const [name, count] of [['omitted',0], ['none',0], ['some',1], ['interior',2], ['required',1]])
  >   assert.equal(m[name](), count, name);
  > for (const name of ['explicit_undefined', 'explicit_unit', 'erased_before', 'erased_after', 'erased_unit'])
  >   console.log(name, m[name]());
  > console.log('dynamic None', m.dynamic(undefined));
  > assert.equal(m.dynamic(7), 1);
  > console.log('ignored effect count', m.erased_effect());
  > assert.deepEqual(hits, [7]);
  > assert.equal(m.new_omitted().count, 0);
  > assert.equal(m.send_omitted({count: globalThis.auditCount}), 0);
  > EOF
  explicit_undefined 0
  explicit_unit 0
  erased_before 1
  erased_after 1
  erased_unit 1
  dynamic None 1
  ignored effect count 1
