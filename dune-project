(lang dune 2.9)

(executables_implicit_empty_intf true)

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
  melange-compiler-libs
  reason
  cmdliner))
