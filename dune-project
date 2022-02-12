(lang dune 3.0)

(generate_opam_files true)
(using directory-targets 0.1)

(name melange)

(package
 (name melange)
 (depends
  (ocaml
   (and
    (>= "4.12.0")
    (< "4.13.0")))
  dune-action-plugin
  melange-compiler-libs
  reason
  cmdliner))
