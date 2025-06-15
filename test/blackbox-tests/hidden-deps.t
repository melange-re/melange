
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
  > let x = Dep.x ()
  > let y = Hidden.x ()
  > EOF
  $ melc -nopervasives -nostdlib -I dep -H hidden --mel-stop-after-cmj x.ml --verbose
  File "initialization.cppo.ml", line 113, characters 30-37:
  [INFO] Compiler include dirs:
  Visible:
  - dep
  Hidden:
  - hidden
  File "x.ml", line 2, characters 8-14:
  2 | let y = Hidden.x ()
              ^^^^^^
  Error: Unbound module Hidden
  [2]

