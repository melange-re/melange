Generated tuple-pipeline scaffolding has containment-safe locations.

  $ . ./setup.sh
  $ cat > input.ml <<EOF
  > let run value first second = value |. (first, second)
  > let run_effect make first second = make () |. (first, second)
  > module Functions = struct
  >   let first value = value
  >   let second value = value
  > end
  > let run_open value = value |. Functions.(first, second)
  > EOF

  $ melc -ppx 'melppx -locations-check' -c input.ml > /dev/null

