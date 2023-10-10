  $ cat > input.js <<EOF
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/bin/jsoo_main.bc.js');
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/bin/melange-cmijs.js');
  > console.log(ocaml.compileML("let t = 2;; 3;; 5"));
  > EOF

  $ node input.js
  {
    warning_errors: [
      {
        js_error_msg: 'Line 1, 12:\n' +
          '  Error: (warning 109 [bucklescript-toplevel-expr-unit]) Toplevel expression is expected to have unit type.',
        row: 0,
        column: 12,
        endRow: 0,
        endColumn: 13,
        text: 'Toplevel expression is expected to have unit type.',
        type: 'warning_as_error'
      },
      {
        js_error_msg: 'Line 1, 16:\n' +
          '  Error: (warning 109 [bucklescript-toplevel-expr-unit]) Toplevel expression is expected to have unit type.',
        row: 0,
        column: 16,
        endRow: 0,
        endColumn: 17,
        text: 'Toplevel expression is expected to have unit type.',
        type: 'warning_as_error'
      }
    ],
    type: 'warning_errors'
  }
