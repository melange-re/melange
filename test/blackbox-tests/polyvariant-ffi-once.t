Polymorphic-variant payload expansion must evaluate the argument exactly once.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > [%%mel.raw {|globalThis.event = function(name, value) { console.log(name, value); }
  > globalThis.reads = 0;
  > globalThis.source = {get event() { reads++; return {NAME:'click', VAL:reads}; }, get optional() { reads++; return 5; }};
  > globalThis.greet = function(x) { return x === undefined ? 'empty' : 'value'; }
  > |}]
  > external event : ([ `click of int | `keydown of int ] [@mel.string]) -> unit = "event" [@@mel.scope "globalThis"]
  > external source : < > Js.t = "source" [@@mel.scope "globalThis"]
  > external current : < > Js.t -> [ `click of int | `keydown of int ] = "event" [@@mel.get]
  > external optional_field : < > Js.t -> int option = "optional" [@@mel.get]
  > external reads : int = "reads" [@@mel.scope "globalThis"]
  > let calls = ref 0
  > let next () = incr calls; `click !calls
  > external greet : ?x:'a -> unit -> string = "greet" [@@mel.scope "globalThis"]
  > let[@inline never] optional b = incr calls; if b then Some 5 else None
  > let () =
  >  event(next()); Printf.printf "calls: %d\n" !calls;
  >  event(`click (incr calls; !calls)); Printf.printf "calls: %d\n" !calls;
  >  event(current source); Printf.printf "getters: %d\n" reads;
  >  print_endline(greet ?x:(optional_field source) ());
  >  Printf.printf "optional getters: %d\n" reads;
  >  print_endline(greet ?x:(optional false) ());
  >  print_endline(greet ?x:(optional true) ());
  >  print_endline(greet ~x:None ());
  >  print_endline(greet ~x:(Some None) ());
  >  Printf.printf "calls: %d\n" !calls;
  >  (try event (raise Exit) with Exit -> print_endline "caught")
  > EOF
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ echo '(melange.emit (target out) (libraries melange) (preprocess (pps melange.ppx)))' > dune
  $ dune build @melange
  $ node _build/default/out/input.js
  click 2
  calls: 2
  click 4
  calls: 4
  click 2
  getters: 2
  value
  optional getters: 4
  empty
  value
  empty
  value
  calls: 6
  caught
