Unhandled effects should surface as `Effect.Unhandled`.

  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > type _ Effect.t += E : int Effect.t
  > 
  > let status =
  >   try
  >     ignore (Effect.perform E);
  >     "no-error"
  >   with
  >   | Effect.Unhandled _ -> "unhandled"
  >   | _ -> "other"
  > 
  > let () = Js.log status
  > EOF
  $ mkdir -p node_modules
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange.js" node_modules/melange.js
  $ ln -sfn "$INSIDE_DUNE/runtime-export/x/node_modules/melange" node_modules/melange
  $ melc x.ml -o x.js
  $ node x.js
  unhandled
