Test go to definition with modules that overlap with stdlib ones

  $ export BUILD_PATH_PREFIX_MAP="MELANGE_ROOT=$(dirname $INSIDE_DUNE):$BUILD_PATH_PREFIX_MAP"
  $ . ./setup.sh
  $ cat >dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

  $ cat > main.ml <<EOF
  > let bar = Stack.foo
  > let baz = Something.foo
  > EOF

  $ cat >dune <<EOF
  > (melange.emit
  >  (alias foo)
  >  (target foo)
  >  (emit_stdlib false)
  >  (libraries lib))
  > EOF

  $ mkdir lib
  $ cat > lib/stack.ml <<EOF
  > let foo = 1
  > EOF
  $ cat > lib/something.ml <<EOF
  > let foo = 1
  > EOF
  $ cat >lib/dune <<EOF
  > (library
  >  (name lib)
  >  (modes melange)
  >  (preprocess (pps melange.ppx))
  >  (wrapped false))
  > EOF

  $ dune build

Get definition of `Something` in `Something.foo`

  $ ocamlmerlin single locate -position 2:13 -verbosity 0 \
  > -filename main.ml < main.ml | jq '.value'
  {
    "file": "$TESTCASE_ROOT/lib/something.ml",
    "pos": {
      "line": 1,
      "col": 0
    }
  }


Get definition of `Stack` in `Stack.foo`

  $ ocamlmerlin single locate -position 1:13 -verbosity 0 \
  > -filename main.ml < main.ml | jq '.value'
  "Several source files in your path have the same name, and merlin doesn't know which is the right one: $TESTCASE_ROOT/lib/stack.ml, MELANGE_ROOT/install/default/lib/melange/stack.mli, MELANGE_ROOT/install/default/lib/melange/stack.ml"

