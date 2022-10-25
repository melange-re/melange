(lang dune 3.5)

(using directory-targets 0.1)

(executables_implicit_empty_intf true)

(formatting
 (enabled_for ocaml))

(generate_opam_files true)

(name melange)

(source
 (github melange-re/melange))

(authors "Antonio Nuno Monteiro <anmonteiro@gmail.com>")

(maintainers "Antonio Nuno Monteiro <anmonteiro@gmail.com>")

(homepage "https://github.com/melange-re/melange")

(bug_reports "https://github.com/melange-re/melange/issues")

(package
 (name melange)
 (synopsis "Toolchain to produce JS from Reason/OCaml")
 (depends
  (ocaml
   (and
    (>= "4.14.0")
    (< "4.15.0")))
  (melange-compiler-libs
   (>= "0.0.1-414"))
  (reason
   (>= "3.8.1"))
  (cmdliner
   (>= "1.1.0"))
  (base64
   (>= "3.0.0"))
  (ounit :with-test)))

(package
 (name mel)
 (synopsis
  "Build system for Melange that defers to Dune for build orchestration")
 (depends
  ocaml
  melange
  (cmdliner
   (>= "1.1.0"))
  luv
  (ounit :with-test)))
