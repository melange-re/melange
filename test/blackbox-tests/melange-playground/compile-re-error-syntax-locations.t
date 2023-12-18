Some Reason errors dont have locations

  $ cat > input.js <<EOF
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/playground/mel_playground.bc.js');
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/playground/melange-cmijs.js');
  > console.log(ocaml.compileRE("let sum = item => swiftch (item) { | Leaf => 0 };").js_warning_error_msg.trim());
  > EOF

  $ node input.js
  File "_none_", line 1, characters 35-36:
  Error: Unclosed "{" (opened line 1, column 33)

But some do

  $ cat > input.js <<EOF
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/playground/mel_playground.bc.js');
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/playground/melange-cmijs.js');
  > console.log(ocaml.compileRE("let sum = item => swiftch (item) { 2 };"));
  > EOF

  $ node input.js
  {
    js_warning_error_msg: 'Line 1, 18:\n  Error Unbound value swiftch',
    row: 0,
    column: 18,
    endRow: 0,
    endColumn: 25,
    text: 'Unbound value swiftch',
    type: 'error'
  }
