Tests for deriving dynamicKeys

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

  $ cat > x.ml <<EOF
  > type chartDataItemType = { height : int; foo : string }
  > [@@deriving jsProperties]
  > 
  > let t = chartDataItemType ~height:2 ~foo:"bar"
  > EOF

  $ dune build ./.x.objs/melange/x.cmj

  $ cat > x.ml <<EOF
  > type chartDataItemType = { height : int; foo : string }
  > [@@deriving jsProperties, getSet]
  > 
  > let t = chartDataItemType ~height:2 ~foo:"bar"
  > let u = heightGet t
  > EOF

  $ dune build ./.x.objs/melange/x.cmj

