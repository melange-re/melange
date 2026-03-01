Invalid continuation values should fail predictably.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > let status =
  >   try
  >     ignore (Effect.Deep.continue (Obj.magic 0) ());
  >     "no-error"
  >   with
  >   | Invalid_argument _ -> "invalid"
  >   | _ -> "other"
  > 
  > let () = Js.log status
  > EOF
  $ mkdir -p node_modules
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange.js" node_modules/melange.js
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange" node_modules/melange
  $ melc x.ml -o x.js
  $ node x.js
  invalid
