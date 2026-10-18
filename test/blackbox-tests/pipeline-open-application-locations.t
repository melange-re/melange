Restored local opens in pipeline applications have well-formed locations.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > module M = struct
  >   let f a b c = a + b + c
  >   let b = 1
  >   let c = 2
  > end
  > let run a = a |. M.(f b c)
  > EOF

  $ melc -ppx 'melppx -locations-check' -c input.ml > /dev/null
