Generated converters point back to the source type declaration

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target output)
  >  (emit_stdlib false)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > main.ml <<'EOF'
  > type record = {
  >   first : int;
  >   second : string;
  > }
  > [@@deriving jsConverter]
  > let converter = recordToJs
  > type variant = [ `First | `Second [@mel.as "second"] ]
  > [@@deriving jsConverter { newType }]
  > EOF

  $ melc -ppx 'melppx -locations-check' -mel-stop-after-cmj main.ml
  $ dune build
  $ ocamlmerlin single locate -position 6:18 -verbosity 0 \
  > -filename main.ml < main.ml | jq '.value'
  {
    "file": "$TESTCASE_ROOT/main.ml",
    "pos": {
      "line": 1,
      "col": 5
    }
  }
