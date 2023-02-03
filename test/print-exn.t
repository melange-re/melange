An example that uses exceptions runtime

  $ export MELANGELIB="$INSIDE_DUNE/lib/melange"
  $ mkdir -p node_modules/melange
  $ ln -s $INSIDE_DUNE/lib node_modules/melange/lib

  $ cat > x.ml <<EOF
  > let run f =
  >   try f () with
  >   | exn -> Printexc.exn_slot_id exn
  > let result = run (fun _ -> failwith "oops")
  > EOF
  $ cat > dune-project <<EOF
  > (lang dune 3.7)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target melange)
  >  (alias melange)
  >  (module_system commonjs))
  > EOF
  $ dune build @melange
  $ node ./_build/default/melange/x.js 2>&1 | awk '/exn_slot_id/'
      return Printexc.exn_slot_id(Caml_js_exceptions.internalToOCamlException(raw_exn));
  TypeError: Printexc.exn_slot_id is not a function
