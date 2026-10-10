Generated mel.open wrappers have well-nested locations

  $ . ./setup.sh
  $ cat > locations.ml <<'EOF'
  > let classify = function [@mel.open]
  >   | Not_found -> 0
  >   | (Invalid_argument _ | Stack_overflow) -> 1
  >   | Sys_error _ -> 2
  > EOF
  $ melc -ppx 'melppx -locations-check' -c locations.ml > /dev/null
