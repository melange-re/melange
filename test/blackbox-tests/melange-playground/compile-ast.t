Compile a parsed AST using the original source for diagnostics and hover locations.

  $ cat > input.js <<'EOF'
  > const assert = require('node:assert/strict');
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/playground/mel_playground.bc.js');
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/playground/melange-cmijs.js');
  > for (const [source, parse, compile] of [
  >   ['let answer = 42', ocaml.parseML, ocaml.compileML],
  >   ['let answer = 42;', ocaml.parseRE, ocaml.compileRE],
  >   ['let answer = 1 + "two"', ocaml.parseML, ocaml.compileML],
  > ]) {
  >   assert.deepEqual(ocaml.compileAST(source, parse(source)), compile(source));
  > }
  > EOF

  $ node input.js
