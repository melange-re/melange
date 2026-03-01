Backtrace shim should be deterministic and type-correct.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > let before = Printexc.backtrace_status ()
  > let () = Printexc.record_backtrace true
  > let bt = Printexc.get_callstack 16
  > 
  > let () =
  >   try
  >     Printexc.raise_with_backtrace Exit bt
  >   with
  >   | Exit -> ()
  > 
  > let after = Printexc.backtrace_status ()
  > let raw_len = Printexc.raw_backtrace_length (Printexc.get_raw_backtrace ())
  > let () = Js.log3 before after raw_len
  > EOF
  $ mkdir -p node_modules
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange.js" node_modules/melange.js
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange" node_modules/melange
  $ melc x.ml -o x.js
  $ node x.js
  false true 0
