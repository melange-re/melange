  $ cat > input.js <<EOF
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/playground/mel_playground.bc.js');
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/playground/melange-cmijs.js');
  > try { ocaml.parseRE("type t = 2") } catch (e) { console.log(e); };
  > EOF

  $ node input.js
  {
    message: 'File "_none_", line 1, characters 9-10:\nError: Syntax error\n\n',
    location: {
      startLine: 1,
      startLineStartChar: 10,
      endLine: 1,
      endLineEndChar: 10
    }
  }
