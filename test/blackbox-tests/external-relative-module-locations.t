Generated relative-module include scaffolding has containment-safe locations.

  $ . ./setup.sh
  $ cat > input.ml <<EOF
  > external value : int = "value" [@@mel.module "./module"]
  > EOF

  $ melc -ppx 'melppx -locations-check' -c input.ml > /dev/null

