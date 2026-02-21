Validate prototype OCaml 5 effects support with low-level primitives adapted from
the OCaml testsuite effect-handler scenarios.

  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >  (target melange)
  >  (alias melange)
  >  (emit_stdlib false)
  >  (libraries melange))
  > EOF

  $ cat > x.ml <<EOF
  > type (_, _) continuation
  > type (_, _) stack
  > 
  > type _ eff = ..
  > type _ eff += Ping : int eff
  > 
  > external perform : 'a eff -> 'a = "%perform"
  > external alloc_stack
  >   : ('a -> 'b)
  >   -> (exn -> 'b)
  >   -> ('c eff -> ('c, 'b) continuation -> Obj.t -> 'b)
  >   -> ('a, 'b) stack
  >   = "caml_alloc_stack"
  > external runstack : ('a, 'b) stack -> ('c -> 'a) -> 'c -> 'b = "%runstack"
  > external reperform
  >   : 'a eff -> ('a, 'b) continuation -> Obj.t -> 'b
  >   = "%reperform"
  > 
  > let handle_ping : type c. c eff -> (c, int) continuation -> Obj.t -> int =
  >  fun eff _k _kt ->
  >   match eff with
  >   | Ping -> 41
  >   | _ -> failwith "unhandled"
  > 
  > let handle_outer : type c. c eff -> (c, int) continuation -> Obj.t -> int =
  >  fun eff _k _kt ->
  >   match eff with
  >   | Ping -> 99
  >   | _ -> failwith "unhandled"
  > 
  > let pass_to_parent : type c. c eff -> (c, int) continuation -> Obj.t -> int =
  >  fun eff k kt -> reperform eff k kt
  > 
  > let direct =
  >   let s = alloc_stack (fun x -> x) raise handle_ping in
  >   runstack s (fun () -> perform Ping + 1) ()
  > 
  > let nested =
  >   let outer = alloc_stack (fun x -> x) raise handle_outer in
  >   let inner = alloc_stack (fun x -> x) raise pass_to_parent in
  >   runstack outer (fun () -> runstack inner (fun () -> perform Ping) ()) ()
  > 
  > let () = Js.log2 direct nested
  > EOF

  $ dune build @melange
  $ node ./_build/default/melange/x.js
  41 99
