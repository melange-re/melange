(lang dune 3.21)

(maintenance_intent "(latest)")

(using experimental_building_ocaml_compiler_with_dune 0.1)

(using menhir 3.0)

(using melange 1.0)

(using directory-targets 0.1)

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
   (and (>= "5.4") (< "5.5")))
  (cmdliner
   (>= "1.1.0"))
  dune-build-info
  vlq
  (cppo :build)
  (alcotest :with-test)
  (reason :with-test)
  (ppxlib (>= "0.36"))
  (menhir
   (>= 20201214))
  (reason-react-ppx
   (and :with-test :post))
  (merlin :with-test)))

(package
 (name melange-playground)
 (synopsis "The Melange compiler, bundled for the browser")
 (allow_empty)
 (depends
  ocaml
  (js_of_ocaml :dev)
  reason
  (melange (= :version))
  reason-react-ppx))
