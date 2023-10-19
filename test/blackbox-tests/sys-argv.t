Test case for Sys.argv

  $ . ./setup.sh

  $ export BUILD_PATH_PREFIX_MAP="/NODE_BIN_PATH=$(command -v node):$BUILD_PATH_PREFIX_MAP"

  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (libraries melange.node)
  >  (target js-out))
  > EOF

  $ cat > x.ml <<EOF
  > let () = Js.log Sys.executable_name
  > let () = Js.log Sys.argv
  > EOF

  $ dune build @melange

  $ node _build/default/js-out/x.js a b c
  /NODE_BIN_PATH
  [
    '/NODE_BIN_PATH',
    '$TESTCASE_ROOT/_build/default/js-out/x.js',
    'a',
    'b',
    'c'
  ]

Compare with Node.Process.argv

  $ cat > x.ml <<EOF
  > let () = Js.log Node.Process.argv
  > EOF

  $ dune build @melange

  $ node _build/default/js-out/x.js a b c
  [
    '/NODE_BIN_PATH',
    '$TESTCASE_ROOT/_build/default/js-out/x.js',
    'a',
    'b',
    'c'
  ]
