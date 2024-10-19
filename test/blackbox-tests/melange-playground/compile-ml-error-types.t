  $ cat > input.js <<EOF
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/playground/mel_playground.bc.js');
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/playground/melange-cmijs.js');
  > console.log(ocaml.compileML(\`let foo = "" + 2\`));
  > EOF

  $ node input.js
  {
    js_warning_error_msg: 'Line 1, 10:\n' +
      '  Error This constant has type string but an expression was expected of type int',
    row: 0,
    column: 10,
    endRow: 0,
    endColumn: 12,
    text: 'This constant has type string but an expression was expected of type int',
    type: 'error'
  }
