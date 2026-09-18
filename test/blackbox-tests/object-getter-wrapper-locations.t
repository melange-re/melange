Generated nullable getter types point at the source type.

  $ . ./setup.sh
  $ cat > location.ml <<'EOF'
  > type t = < value : int [@mel.get { null }] >
  > EOF
  $ ocamlc -ppx 'melppx -alert -fragile' -c location.ml
  File "location.ml", line 1, characters 19-22:
  1 | type t = < value : int [@mel.get { null }] >
                         ^^^
  Error: Unbound module Js
  [2]

Generated wrappers remain contained within their source fields.

  $ cat > containment.ml <<'EOF'
  > module Js = struct
  >   type 'a null = 'a
  >   type 'a undefined = 'a
  >   type 'a nullable = 'a
  > end
  > type t =
  >   < null : int [@mel.get { null }]
  >   ; undefined : string [@mel.get { undefined }]
  >   ; nullable : bool [@mel.get { nullable }] >
  > EOF
  $ ocamlc -ppx 'melppx -locations-check' -c containment.ml
