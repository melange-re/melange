Showcase an error with deriving abstract when the record has one field

  $ . ./setup.sh

  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (library
  >  (modes melange)
  >  (name x)
  >  (preprocess
  >   (pps melange.ppx)))
  > EOF

Record with two fields works fine

  $ cat > x.ml <<EOF
  > type chartDataItemType = { height: int; foo: string } [@@deriving abstract]
  > EOF

  $ dune build ./.x.objs/melange/x.cmj

Record with one field crashes

  $ dune clean
  $ cat > x.ml <<EOF
  > type chartDataItemType = { height: int; } [@@deriving abstract]
  > EOF

  $ dune build ./.x.objs/melange/x.cmj

  $ dune clean
  $ cat > x.ml <<EOF
  > type 'a t = { x : 'a }
  > external x : 'a t -> 'a = "%identity"
  > EOF

  $ dune build ./.x.objs/melange/x.cmj
  File "x.ml", line 2, characters 0-37:
  2 | external x : 'a t -> 'a = "%identity"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error (warning 61 [unboxable-type-in-prim-decl]): This primitive declaration uses type t, whose representation
  may be either boxed or unboxed. Without an annotation to indicate
  which representation is intended, the boxed representation has been
  selected by default. This default choice may change in future
  versions of the compiler, breaking the primitive implementation.
  You should explicitly annotate the declaration of t
  with [@@boxed] or [@@unboxed], so that its external interface
  remains stable in the future.
  [1]

