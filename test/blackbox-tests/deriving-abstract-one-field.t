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

  $ dune build --display=short ./.x.objs/melange/x.cmj
        ocamlc .ppx/9b08511fbad9c15355a1e1f8e80934bc/dune__exe___ppx.{cmi,cmo}
      ocamlopt .ppx/9b08511fbad9c15355a1e1f8e80934bc/build_info__Build_info_data.{cmx,o}
      ocamlopt .ppx/9b08511fbad9c15355a1e1f8e80934bc/dune__exe___ppx.{cmx,o}
      ocamlopt .ppx/9b08511fbad9c15355a1e1f8e80934bc/ppx.exe
           ppx x.pp.ml
          melc .x.objs/melange/x.{cmi,cmj,cmt}

Record with one field crashes

  $ dune clean

  $ cat > x.ml <<EOF
  > type chartDataItemType = { height: int; } [@@deriving abstract]
  > EOF

  $ dune build --display=short ./.x.objs/melange/x.cmj
        ocamlc .ppx/9b08511fbad9c15355a1e1f8e80934bc/dune__exe___ppx.{cmi,cmo}
      ocamlopt .ppx/9b08511fbad9c15355a1e1f8e80934bc/build_info__Build_info_data.{cmx,o}
      ocamlopt .ppx/9b08511fbad9c15355a1e1f8e80934bc/dune__exe___ppx.{cmx,o}
      ocamlopt .ppx/9b08511fbad9c15355a1e1f8e80934bc/ppx.exe
           ppx x.pp.ml
          melc .x.objs/melange/x.{cmi,cmj,cmt} (exit 2)
  File "x.ml", line 1:
  Error (warning 61 [unboxable-type-in-prim-decl]): This primitive declaration uses type chartDataItemType, whose representation
  may be either boxed or unboxed. Without an annotation to indicate
  which representation is intended, the boxed representation has been
  selected by default. This default choice may change in future
  versions of the compiler, breaking the primitive implementation.
  You should explicitly annotate the declaration of chartDataItemType
  with [@@boxed] or [@@unboxed], so that its external interface
  remains stable in the future.
  File "x.ml", line 1:
  Error (warning 61 [unboxable-type-in-prim-decl]): This primitive declaration uses type chartDataItemType, whose representation
  may be either boxed or unboxed. Without an annotation to indicate
  which representation is intended, the boxed representation has been
  selected by default. This default choice may change in future
  versions of the compiler, breaking the primitive implementation.
  You should explicitly annotate the declaration of chartDataItemType
  with [@@boxed] or [@@unboxed], so that its external interface
  remains stable in the future.
  [1]
