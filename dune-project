(lang dune 3.8)

(using experimental_building_ocaml_compiler_with_dune 0.1)

(using menhir 2.1)

(using melange 0.1)

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
   (>= "4.13.0"))
  (cmdliner
   (>= "1.1.0"))
  (base64
   (>= "3.1.0"))
  dune-build-info
  (cppo :build)
  (ounit :with-test)
  (reason :with-test)
  (js_of_ocaml :with-test)
  ppxlib
  menhir
  (reactjs-jsx-ppx :with-test)))

(package
 (name rescript-syntax)
 (synopsis "ReScript syntax packaged as an opam library")
 (depends
  ocaml
  (melange
   (= :version))
  (ppxlib
   (>= "0.28.0"))))

(package
 (name melange_playground)
 (synopsis "The Melange compiler, bundled for the browser")
 (allow_empty)
 (depends
  ocaml
  js_of_ocaml
  (reason
   (= "dev"))
  (melange
   (= :version))
  (reactjs-jsx-ppx
   (= :version))))
