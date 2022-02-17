(lang dune 2.5)

(formatting
 (enabled_for ocaml))

(generate_opam_files true)

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
