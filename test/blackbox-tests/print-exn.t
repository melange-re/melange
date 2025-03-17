An example that uses exceptions runtime

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
  > let run f =
  >   try f () with
  >   | exn -> Printexc.exn_slot_id exn
  > let result = run (fun _ -> failwith "oops")
  > 
  > exception Custom
  > let () =
  >   Js.log2 (Printexc.exn_slot_id Custom) (Printexc.exn_slot_id Not_found);
  >   Js.log2 (Printexc.exn_slot_name Custom) (Printexc.exn_slot_name Not_found)
  > EOF

  $ dune build @melange
  $ node ./_build/default/melange/x.js
  1 -1
  Melange__X.Custom/1 Not_found

  $ cat > x.ml <<EOF
  > module Gen () = struct
  >   exception Custom
  > end
  > let () =
  >   let module Gen1 = Gen () in
  >   Js.log3 (Printexc.exn_slot_name Gen1.Custom) (Printexc.exn_slot_id Gen1.Custom) (Printexc.exn_slot_id Gen1.Custom);
  > exception Custom
  > let () =
  >   let module Gen2 = Gen () in
  >   Js.log3 (Printexc.exn_slot_name Gen2.Custom) (Printexc.exn_slot_id Gen2.Custom) (Printexc.exn_slot_id Gen2.Custom);
  > EOF

  $ dune build @melange
  $ node ./_build/default/melange/x.js
  Custom/1 1 1
  Custom/2 2 2
