Test go to definition with modules that overlap with stdlib ones

Similar to companion editor-stdlib-gotodef.t, but for ReasonReact

  $ . ./setup.sh

  $ cat >dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

  $ cat > main.re <<EOF
  > let bar = <Stack> {React.string("hey")} </Stack>
  > let baz = <Something> {React.string("hey")} </Something>
  > EOF

  $ cat >dune <<EOF
  > (melange.emit
  >  (alias foo)
  >  (target foo)
  >  (preprocess
  >   (pps melange.ppx reason-react-ppx))
  >  (libraries lib))
  > EOF

  $ mkdir lib
  $ cat > lib/stack.re <<EOF
  > [@react.component]
  > let make = (~children) => {
  >   <div className={"foo"}> children </div>;
  > };
  > EOF
  $ cat > lib/something.re <<EOF
  > [@react.component]
  > let make = (~children) => {
  >   <div className={"foo"}> children </div>;
  > };
  > EOF
  $ cat >lib/dune <<EOF
  > (library
  >  (name lib)
  >  (modes melange)
  >  (libraries reason-react)
  >  (preprocess
  >   (pps melange.ppx reason-react-ppx))
  >  (wrapped false))
  > EOF

  $ dune build

Going to definition in `<Something>`

  $ ocamlmerlin single locate -position 2:15 -verbosity 0 \
  > -filename main.re < main.re | jq '.value'
  {
    "file": "$TESTCASE_ROOT/lib/something.re",
    "pos": {
      "line": 1,
      "col": 0
    }
  }

Going to definition in `<Stack />`

  $ ocamlmerlin single locate -position 1:15 -verbosity 0 \
  > -filename main.re < main.re | jq '.value'
  {
    "file": "/home/me/code/melange/_build/install/default/lib/melange/stack.ml",
    "pos": {
      "line": 1,
      "col": 0
    }
  }

