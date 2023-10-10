  $ cat > input.js <<EOF
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/bin/jsoo_main.bc.js');
  > require(process.env.DUNE_SOURCEROOT + '/_build/default/bin/melange-cmijs.js');
  > console.log(ocaml.printML(ocaml.parseRE(\`let foo = <div />\`)));
  > EOF

  $ node input.js
  let foo = ((div ~children:[] ())[@JSX ])
