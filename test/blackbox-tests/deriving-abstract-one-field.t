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
  >  (preprocess (pps melange.ppx)))
  > EOF

Record with two fields works fine

  $ cat > x.ml <<EOF
  > type chartDataItemType = { height: int; foo: string } [@@deriving jsProperties]
  > EOF
  $ dune build ./.x.objs/melange/x.cmj

Record with one field also works fine

  $ cat > x.ml <<EOF
  > type chartDataItemType = { height: int; } [@@deriving jsProperties]
  > EOF
  $ dune build ./.x.objs/melange/x.cmj

  $ cat > x.ml <<EOF
  > type 'a t = { x : 'a }
  > external x : 'a t -> 'a = "%identity"
  > EOF
  $ dune build ./.x.objs/melange/x.cmj

  $ cat > x.mli <<EOF
  > type 'a t = { x : 'a }
  > external x : 'a t -> 'a = "%identity"
  > EOF
  $ dune build ./.x.objs/melange/x.cmi

