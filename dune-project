(lang dune 3.5)

(using directory-targets 0.1)

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
    (>= "4.14.0")
    (< "4.15.0")))
  melange-compiler-libs
  reason
  cmdliner
  base64
  luv))
