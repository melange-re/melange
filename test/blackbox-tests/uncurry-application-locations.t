Uncurried applications generate location-contained call scaffolding

  $ . ./setup.sh

  $ cat > locations.ml <<'EOF'
  > let fn = fun [@u] x -> x
  > let _ = fn 1 [@u]
  > 
  > let zero = fun [@u] () -> 0
  > let _ = zero () [@u]
  > 
  > let call_method obj = obj##run 1
  > let call_method_zero obj = obj##run ()
  > let call_property obj = obj#@run 1
  > let call_property_zero obj = obj#@run ()
  > EOF

  $ melc -ppx 'melppx -locations-check' -c locations.ml > /dev/null
