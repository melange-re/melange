  $ cat > input.js <<EOF
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/bin/jsoo_main.bc.js');
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/bin/melange-cmijs.js');
  > console.log(ocaml.compileML(\`let +foo\`));
  > EOF

  $ node input.js
  {
    js_warning_error_msg: 'Line 1, 5:\n  Error Syntax error',
    row: 0,
    column: 5,
    endRow: 0,
    endColumn: 8,
    text: 'Syntax error',
    type: 'error'
  }
