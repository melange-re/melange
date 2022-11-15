(lang dune 3.5)

(using directory-targets 0.1)

(executables_implicit_empty_intf true)

(cram enable)

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

(license "LGPL-2.1-or-later")

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
  (cmdliner
   (>= "1.1.0"))
  (base64
   (>= "3.1.0"))
  (meldep
   (= :version))
  (cppo :build)
  (ounit :with-test)))

(package
 (name meldep)
 (synopsis
  "Melange counterpart to `ocamldep` that understands Melange-specific constructs")
 (depends
  ocaml
  (cmdliner
   (>= "1.1.0"))))

(package
 (name mel)
 (synopsis
  "Build system for Melange that defers to Dune for build orchestration")
 (depends
  ocaml
  (melange
   (= :version))
  (cmdliner
   (>= "1.1.0"))
  (luv
   (>= "0.5.11"))
  (ocaml-migrate-parsetree
   (>= "2.3.0"))
  (ounit :with-test)))
