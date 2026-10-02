Generated type references satisfy the PPX location invariant in every deriver
that uses Ast_derive_util.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > type 'a properties = {
  >   mutable value : 'a;
  >   optional : string option; [@mel.optional]
  > }
  > [@@deriving jsProperties, getSet]
  > type 'a record = {
  >   first : 'a;
  >   second : int * string;
  > }
  > [@@deriving accessors]
  > type 'a variant =
  >   | Empty
  >   | Value of 'a * (int * string)
  > [@@deriving accessors]
  > type 'a converted = {
  >   converted_first : 'a;
  >   converted_second : int * string;
  > }
  > [@@deriving jsConverter { newType }]
  > type converted_variant = [ `First | `Second ]
  > [@@deriving jsConverter { newType }]
  > EOF
  $ cp input.ml interface.mli
  $ cp input.ml implementation.ml

  $ melc -ppx 'melppx -locations-check' -c interface.mli > /dev/null
  $ melc -ppx 'melppx -locations-check' -c implementation.ml > /dev/null
