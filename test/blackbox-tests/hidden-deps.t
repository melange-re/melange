
  $ . ./setup.sh
  $ mkdir hidden dep
  $ cat > hidden/hidden.ml << EOF
  > let x () = "hello"
  > EOF
  $ cat > dep/dep.ml << EOF
  > let x () = Hidden.x ()
  > EOF

  $ melc hidden/hidden.ml --mel-stop-after-cmj
  $ ls hidden
  hidden.cmi
  hidden.cmj
  hidden.cmt
  hidden.ml

  $ melc -I hidden dep/dep.ml --mel-stop-after-cmj
  $ ls dep
  dep.cmi
  dep.cmj
  dep.cmt
  dep.ml

  $ cat > x.ml << EOF
  > let x = Dep.x () ^ " " ^ Hidden.x ()
  > EOF
  $ melc -I dep -I hidden --mel-stop-after-cmj x.ml

  $ cat > x.ml << EOF
  > let x = Dep.x () ^ " " ^ Hidden.x ()
  > EOF
  $ melc -I dep -H hidden --mel-stop-after-cmj x.ml --verbose
  File "initialization.cppo.ml", line 113, characters 30-37:
  [INFO] Compiler include dirs:
  Visible:
  - dep
  - /Users/anmonteiro/projects/melange/_build/default/jscomp/stdlib/.stdlib.objs/melange
  - /Users/anmonteiro/projects/melange/_build/default/jscomp/runtime/.js.objs/melange
  Hidden:
  - hidden
  File "x.ml", line 1, characters 25-33:
  1 | let x = Dep.x () ^ " " ^ Hidden.x ()
                               ^^^^^^^^
  Error: Unbound module Hidden
  [2]

