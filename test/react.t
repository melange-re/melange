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
  >  (compile_flags :standard -w -20)
  >  (preprocess (pps melange.ppx reactjs-jsx-ppx)))
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
        ocamlc .ppx/df8d19d63a600c50cc2fede8aa971a95/dune__exe___ppx.{cmi,cmo}
         refmt x.re.ml
      ocamlopt .ppx/df8d19d63a600c50cc2fede8aa971a95/dune__exe___ppx.{cmx,o}
      ocamlopt .ppx/df8d19d63a600c50cc2fede8aa971a95/ppx.exe
           ppx x.re.pp.ml
          melc .output.mobjs/melange/melange__X.{cmi,cmj,cmt}
          melc output/x.js
