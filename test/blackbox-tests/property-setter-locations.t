Generated property-setter wrappers have containment-safe locations.

  $ . ./setup.sh
  $ cat > input.ml <<EOF
  > let set obj =
  >   obj##value #= 1
  > EOF

  $ melc -ppx 'melppx -locations-check' -c input.ml > /dev/null
