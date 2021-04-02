(lang dune 2.5)

(generate_opam_files true)

(package
 (name melange)
 (depends
  (ocaml
   (= "4.12"))
  dune-action-plugin
  melange-compiler-libs
  reason
  cmdliner))
