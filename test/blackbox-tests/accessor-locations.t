Generated accessors satisfy the PPX location invariant

  $ . ./setup.sh
  $ cat > accessor_intf.mli <<'EOF'
  > type 'a record = {
  >   first : 'a;
  >   second : (int * string) option;
  > }
  > [@@deriving accessors]
  > type 'a variant =
  >   | Nothing
  >   | Something of 'a * (int * string)
  > [@@deriving accessors]
  > EOF
  $ cp accessor_intf.mli accessor_impl.ml
  $ melc -ppx 'melppx -locations-check' -c accessor_intf.mli > /dev/null
  $ melc -ppx 'melppx -locations-check' -c accessor_impl.ml > /dev/null
