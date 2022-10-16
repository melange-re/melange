(lang dune 2.9)

(executables_implicit_empty_intf true)

(formatting
 (enabled_for ocaml))

(generate_opam_files true)

(name melange)

(package
 (name melange)
 (homepage "https://github.com/melange-re/melange")
 (maintainers "Antonio Nuno Monteiro <anmonteiro@gmail.com>")
 (authors "Antonio Nuno Monteiro <anmonteiro@gmail.com>")
 (bug_reports "https://github.com/melange-re/melange/issues")
 (synopsis "Toolchain to produce JS from Reason/OCaml")
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
