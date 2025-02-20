This test exercises our custom lexbuf feeding function for the playground that
always appends a newline at the end. The initial buffer size is 512 bytes so
we test that we can re-feed source code properly.

  $ cat > input.js <<EOF
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/playground/mel_playground.bc.js');
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/playground/melange-cmijs.js');
  > console.log(ocaml.compileRE(\`
  >   let f = {|this source code length is waaaaaaaaaay
  >     waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay
  >     waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay
  >     waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay
  >     waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay
  >     waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay
  >     waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay
  >     waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay
  >     waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay
  >     waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay
  >     waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay
  >     waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay
  >     over 512 chars
  >   |}; // end of line comment \`));
  > EOF

  $ node input.js
  {
    js_code: '// Generated by Melange\n' +
      '\n' +
      '\n' +
      'const f = "this source code length is waaaaaaaaaay\\n    waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay\\n    waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay\\n    waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay\\n    waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay\\n    waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay\\n    waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay\\n    waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay\\n    waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay\\n    waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay\\n    waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay\\n    waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay waaaaaaaaaay\\n    over 512 chars\\n  ";\n' +
      '\n' +
      'export {\n' +
      '  f,\n' +
      '}\n' +
      '/* No side effect */\n',
    warnings: [],
    type_hints: [
      {
        start: [Object],
        end: [Object],
        kind: 'expression',
        hint: 'string'
      },
      {
        start: [Object],
        end: [Object],
        kind: 'pattern_type',
        hint: 'string'
      },
      { start: [Object], end: [Object], kind: 'binding', hint: 'string' }
    ]
  }

