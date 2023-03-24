Demonstrate how to use the React JSX PPX

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target output)
  >  (alias mel)
  >  (emit_stdlib false)
  >  (compile_flags :standard -w -20)
  >  (emit_stdlib false)
  >  (preprocess (pps reactjs-jsx-ppx)))
  > EOF
  $ cat > x.re <<EOF
  > module React = {
  >   let array = Obj.magic
  >   let string = Obj.magic
  >   let createElement = Obj.magic
  > };
  > module ReactDOMRe = {
  >   let createDOMElementVariadic = Obj.magic
  > };
  > module App = {
  >   [@react.component]
  >   let make = () =>
  >     ["Hello!", "This is React!"]
  >     ->Belt.List.map(greeting => <h1> greeting->React.string </h1>)
  >     ->Belt.List.toArray
  >     ->React.array;
  > };
  > let () =
  >   Js.log2("Here's two:", 2);
  >   ignore(<App />)
  > EOF

  $ dune build @mel --display=short
        ocamlc .ppx/70044eb4d353a0e693290a95e71c1a2e/dune__exe___ppx.{cmi,cmo}
         refmt x.re.ml
      ocamlopt .ppx/70044eb4d353a0e693290a95e71c1a2e/dune__exe___ppx.{cmx,o}
      ocamlopt .ppx/70044eb4d353a0e693290a95e71c1a2e/ppx.exe
           ppx x.re.pp.ml
          melc .output.mobjs/melange/melange__X.{cmi,cmj,cmt}
          melc output/x.js
