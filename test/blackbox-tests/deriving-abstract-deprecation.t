Deprecations alerts for deriving abstract

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

Shows when using the creation function

  $ cat > x.ml <<EOF
  > type chartDataItemType = { height : int; foo : string } [@@deriving abstract]
  > 
  > let t = chartDataItemType ~height:2 ~foo:"bar"
  > EOF

  $ dune build ./.x.objs/melange/x.cmj
  File "x.ml", line 3, characters 8-25:
  3 | let t = chartDataItemType ~height:2 ~foo:"bar"
              ^^^^^^^^^^^^^^^^^
  Error (alert deprecated): chartDataItemType
  `@@deriving abstract' deprecated. Use `@@deriving jsProperties, getSet' instead.
  [1]

Shows when using setters or accessors

  $ cat > x.ml <<EOF
  > type chartDataItemType = { height : int; foo : string } [@@deriving abstract]
  > 
  > let t = chartDataItemType ~height:2 ~foo:"bar"
  > let u = heightGet t
  > EOF

  $ dune build ./.x.objs/melange/x.cmj
  File "x.ml", line 3, characters 8-25:
  3 | let t = chartDataItemType ~height:2 ~foo:"bar"
              ^^^^^^^^^^^^^^^^^
  Error (alert deprecated): chartDataItemType
  `@@deriving abstract' deprecated. Use `@@deriving jsProperties, getSet' instead.
  
  File "x.ml", line 4, characters 8-17:
  4 | let u = heightGet t
              ^^^^^^^^^
  Error (alert deprecated): heightGet
  `@@deriving abstract' deprecated. Use `@@deriving jsProperties, getSet' instead.
  [1]

