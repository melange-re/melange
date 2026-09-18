Generated inline-literal types use the literal's source location.

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > foo.ml <<EOF
  > let answer = 42 [@@mel.inline]
  > EOF

  $ melc -ppx 'melppx -locations-check' -c foo.ml > /dev/null
  $ dune build
  $ ocamlmerlin single type-enclosing -position 1:13 -verbosity 0 \
  > -filename foo.ml < foo.ml | jq '.value[0]'
  {
    "start": {
      "line": 1,
      "col": 13
    },
    "end": {
      "line": 1,
      "col": 15
    },
    "type": "int",
    "tail": "no"
  }
