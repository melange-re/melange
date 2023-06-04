Setup

  $ . ./setup.sh
  $ echo 'let lib = "from lib"' > lib.ml
  $ echo 'let x = print_endline Lib.lib' > foo.ml

  $ melc --bs-stop-after-cmj --bs-package-output . --bs-module-name lib -o lib.cmj -c -impl lib.ml

  $ melc -I . --bs-stop-after-cmj --bs-package-output . --bs-module-name foo -o Foo.cmj -c -impl foo.ml

  $ melc --bs-module-type commonjs -o lib.bs.js lib.cmj
  $ melc -I . --bs-module-type commonjs -o foo.bs.js Foo.cmj

Require calls should share the correct extension

  $ node foo.bs.js
  from lib

