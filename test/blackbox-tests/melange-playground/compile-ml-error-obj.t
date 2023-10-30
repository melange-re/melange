  $ cat > input.js <<EOF
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/bin/jsoo_main.bc.js');
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/bin/melange-cmijs.js');
  > console.log(ocaml.compileML("let t = [%mel.obj 2]"));
  > EOF

  $ node input.js
  {
    js_warning_error_msg: 'Line 1, 8:\n  Error Expect a record expression here',
    row: 0,
    column: 8,
    endRow: 0,
    endColumn: 20,
    text: 'Expect a record expression here',
    type: 'error'
  }
