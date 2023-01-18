A test case for some exn in lam_convert

  $ export MELANGELIB="$INSIDE_DUNE/lib/melange"

  $ cat > x.ml <<EOF
  > let t = (Pervasives.abs_float  [@ocaml.alert "-deprecated"]);
  > EOF

  $ melc x.ml
  melc: internal error, uncaught exception:
        File "jscomp/core/lam_convert.ml", line 293, characters 17-23: Assertion failed
        
  [125]
