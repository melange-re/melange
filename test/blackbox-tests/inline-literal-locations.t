Generated inline-literal types use the literal's source location.

  $ . ./setup.sh
  $ cat > foo.ml <<EOF
  > let answer = 42 [@@mel.inline]
  > EOF

  $ melc -ppx 'melppx -locations-check' -c foo.ml > /dev/null
  $ ocamlc -ppx 'melppx' -dparsetree -stop-after parsing foo.ml 2>&1 | \
  > awk '/core_type/ { print; getline; print }'
          core_type (foo.ml[1,0+13]..[1,0+15])
            Ptyp_constr "int" (foo.ml[1,0+13]..[1,0+15])
