Demonstrate how to use the `melc` PPX

  $ cat > x.ml <<EOF
  > let () =
  > #if MELANGE then
  >   Js.log("It's Melange");
  > #else
  >   Js.log2("Not Melange, type error, not 2 arguments");
  > #end
  > EOF


`melc --as-pp` can be used in e.g. Dune `(preprocess (action ..))` fields

  $ melc --as-pp x.ml > x.pp.ml

  $ head -c12 x.pp.ml
  Caml1999M031

Preprocess with `--as-ppx`

  $ melc --bs-no-builtin-ppx --as-pp x.ml > x.pp.ml
  $ head -c12 x.pp.ml
  Caml1999M031

  $ melc --as-ppx x.pp.ml x.pp2.ml
  $ head -c12 x.pp2.ml
  Caml1999M031

  $ rm -rf x.pp.ml x.pp2.ml

  $ cat > dune-project <<EOF
  > (lang dune 3.7)
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
