Demonstrate how to use the `melc` PPX

  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > let () = Js.log("It's Melange");
  > EOF

`melc --as-pp` can be used in e.g. Dune `(preprocess (action ..))` fields.
It's not very useful since the melange ppx is separate, and it acts more like
`-stop-after-parsing`

  $ melc --as-pp x.ml > x.pp.ml

  $ head -c9 x.pp.ml
  Caml1999M

Preprocess with `--as-pp`

  $ melc --as-pp x.ml > x.pp.ml
  $ head -c9 x.pp.ml
  Caml1999M

  $ melc --as-ppx x.pp.ml x.pp2.ml
  $ head -c9 x.pp2.ml
  Caml1999M

  $ rm -rf x.pp.ml x.pp2.ml

  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (library
  >  (modes melange)
  >  (name x)
  >  (preprocess
  >   (action (run melc --as-pp %{input-file}))))
  > EOF

  $ dune build --display=short ./.x.objs/melange/x.cmj
          melc x.pp.ml
          melc .x.objs/melange/x.{cmi,cmj,cmt}
