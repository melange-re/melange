  $ cat > input.js <<EOF
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/bin/jsoo_main.bc.js');
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/bin/melange-cmijs.js');
  > console.log(ocaml.compileML("external f : int = \"\""));
  > EOF

  $ node input.js
  {
    js_warning_error_msg: 'Line 1, 13:\n  Error External identifiers must be functions',
    row: 0,
    column: 13,
    endRow: 0,
    endColumn: 16,
    text: 'External identifiers must be functions',
    type: 'error'
  }
