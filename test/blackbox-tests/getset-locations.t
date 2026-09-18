Generated getters and setters satisfy the PPX location invariant

  $ . ./setup.sh
  $ cat > getset_intf.mli <<'EOF'
  > type ('a, 'b) record = {
  >   mutable first : 'a;
  >   second : ('b * string) option [@mel.optional];
  > }
  > [@@deriving getSet]
  > EOF
  $ cp getset_intf.mli getset_impl.ml
  $ melc -ppx 'melppx -locations-check' -c getset_intf.mli > /dev/null
  $ melc -ppx 'melppx -locations-check' -c getset_impl.ml > /dev/null
