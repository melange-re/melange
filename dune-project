(lang dune 2.5)

(name bucklescript)

(generate_opam_files true)

(package
 (name bucklescript)
 (depends
  (ocaml-variants
   (= "4.12.0+BS"))
  dune-action-plugin
  reason))
