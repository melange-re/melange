Generated property-access helper applications have containment-safe locations.

  $ . ./setup.sh
  $ cat > input.ml <<EOF
  > let nested object_ nested field = object_ ## (nested ## field)
  > let chained object_ value =
  >   object_ ## (first value) ## (second value)
  > EOF

  $ melc -ppx 'melppx -locations-check' -c input.ml > /dev/null
