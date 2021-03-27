(lang dune 2.5)

(generate_opam_files true)

(package
 (name melange)
 (depends
  (ocaml-variants
   (= "4.12.0+BS"))
  dune-action-plugin
  reason))
