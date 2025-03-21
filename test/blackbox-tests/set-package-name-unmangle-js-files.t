Set up a few directories we'll need

  $ . ./setup.sh
  $ mkdir -p lib/.objs/melange
  $ mkdir -p app/.objs/melange
  $ mkdir -p output/lib
  $ mkdir -p output/app

  $ echo "let t = 1" > lib/a.ml

Using Lib__A here just for demoing purposes, Dune gen'd wrapping modules would
make this work with Lib.A.t

  $ echo "let t = Lib__A.t" > app/B.ml

Build cmjs

  $ BSPKG="-bs-package-name myPackage"
  $ melc $BSPKG -bs-package-output lib/ -bs-stop-after-cmj lib/a.ml -o lib/.objs/melange/lib__A.cmj

  $ melc $BSPKG -bs-package-output app/ -I lib/.objs/melange -bs-stop-after-cmj app/B.ml -o app/.objs/melange/melange__B.cmj

Linking step

  $ melc $BSPKG -bs-package-output lib/ lib/.objs/melange/lib__A.cmj -o output/lib/a.js

Note casing is respected:
- module A was produced by a.ml, so output is a.js
- module B was produced by B.ml, so output is B.js

  $ melc $BSPKG -bs-module-type commonjs -I lib/.objs/melange -I output/lib app/.objs/melange/melange__B.cmj -o output/app/B.js
  $ melc $BSPKG -bs-module-type commonjs -I lib/.objs/melange -I output/lib app/.objs/melange/melange__B.cmj -o output/app/B.js

Path should point to proper name of the .js dep

  $ cat output/app/B.js
  // Generated by Melange
  'use strict';
  
  const Lib__A = require("../lib/lib__A.js");
  
  const t = Lib__A.t;
  
  module.exports = {
    t,
  }
  /* No side effect */
