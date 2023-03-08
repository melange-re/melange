Test that belt and runtime libs work well together with both es6 and commonjs

  $ export MELANGELIB="$INSIDE_DUNE/lib/melange"
  $ cat > x.ml <<EOF
  > let nothing = Belt.List.map [] (fun x -> x)
  > let () = Js.log nothing
  > EOF

Try commonjs first

  $ cat > dune-project <<EOF
  > (lang dune 3.7)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >  (target melange)
  >  (alias melange)
  >  (libraries melange)
  >  (module_system commonjs))
  > EOF

  $ dune build @melange

  $ node ./_build/default/melange/x.js
  0

Now es6

  $ dune clean

  $ cat > dune <<EOF
  > (melange.emit
  >  (target melange)
  >  (alias melange)
  >  (libraries melange)
  >  (module_system es6))
  > EOF

  $ dune build @melange

  $ cat > ./_build/default/melange/package.json <<EOF
  > { "type": "module" }
  > EOF

  $ cat > ./_build/default/melange/node_modules/melange.belt/package.json <<EOF
  > { "type": "module" }
  > EOF

  $ node ./_build/default/melange/x.js 2>&1 | awk '/Cannot find module/'
  Error [ERR_MODULE_NOT_FOUND]: Cannot find module '$TESTCASE_ROOT/_build/default/melange/node_modules/melange.runtime/curry.mjs' imported from $TESTCASE_ROOT/_build/default/melange/node_modules/melange.belt/belt_List.js
