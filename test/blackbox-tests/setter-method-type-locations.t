Generated setter method types preserve source locations without overlapping.

  $ . ./setup.sh
  $ cat > valid.ml <<'EOF'
  > class type write_only = object
  >   method value : int [@@mel.set { no_get }]
  > end [@u]
  > class type read_write = object
  >   method value : string [@@mel.set]
  > end [@u]
  > type object_write_only =
  >   < value : bool [@mel.set { no_get }] > Js.t
  > type object_read_write =
  >   < value : float [@mel.set] > Js.t
  > EOF
  $ melc -ppx 'melppx -locations-check' -c valid.ml > /dev/null

The source type remains the location reported by the type checker.

  $ cat > error.ml <<'EOF'
  > class type write_only = object
  >   method value : missing [@@mel.set { no_get }]
  > end [@u]
  > EOF
  $ melc -ppx 'melppx -locations-check' -c error.ml
  File "error.ml", line 2, characters 17-24:
  2 |   method value : missing [@@mel.set { no_get }]
                       ^^^^^^^
  Error: Unbound type constructor missing
  [2]
