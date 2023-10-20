Test that belt and runtime libs work well together with both es6 and commonjs

  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > let nothing = Belt.List.map [] (fun x -> x)
  > let () = Js.log nothing
  > EOF

Try commonjs first

  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >  (target melange)
  >  (alias melange)
  >  (libraries melange melange.belt)
  >  (emit_stdlib false)
  >  (module_systems commonjs))
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
  >  (libraries melange melange.belt)
  >  (emit_stdlib false)
  >  (module_systems es6))
  > EOF

  $ dune build @melange

  $ cat > ./_build/default/melange/package.json <<EOF
  > { "type": "module" }
  > EOF

  $ cat > ./_build/default/melange/node_modules/melange.js/package.json <<EOF
  > { "type": "module" }
  > EOF
  $ cat > ./_build/default/melange/node_modules/melange.belt/package.json <<EOF
  > { "type": "module" }
  > EOF

  $ cd _build/default
  $ node ./melange/x.js
  0
