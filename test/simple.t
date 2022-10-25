Set up a few directories we'll need

  $ mkdir -p lib
  $ mkdir -p app
  $ mkdir -p output/lib
  $ mkdir -p output/app

  $ echo "let t = 1" > lib/a.ml
  $ echo "let t = A.t" > app/b.ml

  $ PKG_NAME="-bs-package-name this"
  $ DUMMY_SPECS="-bs-package-output commonjs:.:.js"

Here, the package specs don't matter because:
1. we're in the same package
2. we'll decide the layout at linking time

  $ cd lib/
  $ melc $PKG_NAME $DUMMY_SPECS -bs-stop-after-cmj a.ml
  $ cd -
  $TESTCASE_ROOT

  $ cd app/
  $ melc $PKG_NAME $DUMMY_SPECS -I ../lib b.ml -bs-stop-after-cmj
  $ cd -
  $TESTCASE_ROOT

The linking step shouldn't need package specs.
Melange should just have a flag for module system, and you can define
the extension via `-o `

Just used for the module system and extension in this phase

  $ cd output/lib
  $ melc $PKG_NAME -bs-package-output commonjs:./lib:.js ../../lib/a.cmj -o a.js
  $ cd -
  $TESTCASE_ROOT

  $ cd output/app/
  $ melc $PKG_NAME -bs-package-output commonjs:./app:.js -I ../../lib ../../app/b.cmj -o b.js
  $ cd -
  $TESTCASE_ROOT

