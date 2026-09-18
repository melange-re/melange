  $ . ./setup.sh
  $ cat > x.ml <<'EOF'
  > type t =
  >   < bark : string -> unit
  >   ; value : int [@mel.get] >
  >   Js.t
  > EOF

Generated object fields satisfy the ppxlib location invariant.

  $ melc -ppx 'melppx -locations-check' x.ml > /dev/null
