Test to showcase "inconsistent assumption" issues when using melange ppx

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >  (target output)
  >  (alias mel)
  >  (emit_stdlib false)
  >  (libraries my_lib))
  > EOF

  $ mkdir lib
  $ cat > lib/dune <<EOF
  > (library
  >  (name my_lib)
  >  (preprocess (pps melange.ppx))
  >  (modes melange))
  > EOF

  $ cat > main.ml <<EOF
  > let t = My_lib.A.t
  > let u = My_lib.B.t
  > EOF

  $ cat > lib/a.ml <<EOF
  > let t = D.t
  > let u = C.t
  > EOF

  $ cat > lib/b.ml <<EOF
  > let t = [%mel.obj { a = C.t }]
  > EOF

  $ cat > lib/c.ml <<EOF
  > type t = < a : D.t > Js.t
  > let t: < a : D.t > Js.t = [%mel.obj { a = D.t }]
  > EOF

  $ cat > lib/d.ml <<EOF
  > type t = string
  > let t = "bar"
  > EOF

  $ dune build @mel

Now change D which is a leaf in the dep tree, notice error on revdeps A (direct)
and B (transitive)

  $ cat > lib/d.ml <<EOF
  > type t = int
  > let t = 2
  > EOF

  $ dune build @mel --display=short
           ppx lib/d.pp.ml
      ocamldep lib/.my_lib.objs/my_lib__D.impl.d
          melc lib/.my_lib.objs/melange/my_lib__D.{cmi,cmj,cmt}
          melc output/lib/d.js
          melc lib/.my_lib.objs/melange/my_lib__C.{cmi,cmj,cmt}
          melc lib/.my_lib.objs/melange/my_lib__A.{cmi,cmj,cmt}
          melc lib/.my_lib.objs/melange/my_lib__B.{cmi,cmj,cmt}
          melc .output.mobjs/melange/melange__Main.{cmi,cmj,cmt}
          melc output/main.js
