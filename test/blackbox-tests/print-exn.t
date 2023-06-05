An example that uses exceptions runtime

  $ cat > x.ml <<EOF
  > let run f =
  >   try f () with
  >   | exn -> Printexc.exn_slot_id exn
  > let result = run (fun _ -> failwith "oops")
  > 
  > exception Custom
  > let () =
  >   Js.log2 (Printexc.exn_slot_id Custom) (Printexc.exn_slot_id Not_found)
  > 
  > EOF
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
  $ dune build @melange
  $ node ./_build/default/melange/x.js
  7 -1
