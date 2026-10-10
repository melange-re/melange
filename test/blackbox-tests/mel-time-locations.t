Generated mel.time scaffolding has containment-safe locations.

  $ . ./setup.sh
  $ cat > input.ml <<EOF
  > let value = [%mel.time 1]
  > EOF

  $ melc -ppx 'melppx -locations-check' -c input.ml > /dev/null

