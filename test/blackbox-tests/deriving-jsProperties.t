Tests for deriving dynamicKeys

  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > type chartDataItemType = { height : int; foo : string }
  > [@@deriving jsProperties]
  > 
  > let t = chartDataItemType ~height:2 ~foo:"bar"
  > EOF

  $ melc -ppx melppx x.ml -o x.cmj

  $ cat > x.ml <<EOF
  > type chartDataItemType = { height : int; foo : string }
  > [@@deriving jsProperties, getSet]
  > 
  > let t = chartDataItemType ~height:2 ~foo:"bar"
  > let u = heightGet t
  > EOF

  $ melc -ppx melppx x.ml -o x.cmj

