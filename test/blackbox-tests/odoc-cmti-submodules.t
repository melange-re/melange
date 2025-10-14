Test that odoc can generate documentation from melange .cmti files including submodules

  $ . ./setup.sh

Check if odoc is available
  $ command -v odoc > /dev/null 2>&1 || { echo "odoc not found, skipping test"; exit 0; }

Setup test files:

  $ cat > test.mli << 'EOF'
  > (** Main module *)
  > type t = int
  > 
  > module Sub : sig
  >   (** A submodule *)
  >   type s = string
  >   val example : s
  > end
  > EOF

  $ cat > test.ml << 'EOF'
  > type t = int
  > module Sub = struct
  >   type s = string
  >   let example = "hello"
  > end
  > EOF

Compile with melc and verify cmti generation:

  $ melc -c -bin-annot test.mli test.ml
  $ ls -1 test.cm* | sort
  test.cmi
  test.cmj
  test.cmt
  test.cmti

Verify odoc can compile the cmti file:

  $ odoc compile test.cmti --pkg test -o test.odoc -I .
  $ odoc link test.odoc -o test.odocl

Generate markdown documentation:

  $ odoc html-generate test.odocl -o html/ --theme-uri odoc
  $ odoc support-files -o html/

Check that both main module and submodule HTML files are generated:

  $ find html -name "*.html" | grep -E "(Test/index|Test.Sub)" | sort
  html/test/Test/Sub/index.html (no-eol)
  html/test/Test/index.html (no-eol)

Verify the main module documentation includes the submodule reference:

  $ grep -o "module.*Sub" html/test/Test/index.html | head -1
  module Sub (no-eol)

Verify the submodule documentation exists and contains expected content:

  $ grep -o "type s" html/test/Test/Sub/index.html | head -1
  type s (no-eol)

  $ grep -o "val example" html/test/Test/Sub/index.html | head -1
  val example (no-eol)

Test that the documentation hierarchy is correct:

  $ test -f html/test/Test/index.html && echo "Main module documented"
  Main module documented

  $ test -f html/test/Test/Sub/index.html && echo "Submodule documented"
  Submodule documented

