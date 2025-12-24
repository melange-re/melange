
  $ . ./setup.sh
  $ cat > foo.ml <<EOF
  > type t
  > external make : (string -> options:< .. >  Js.t -> t) [@u] = "Response"
  > [@@mel.new]
  > 
  > let t = (make "hi" ~options:[%mel.obj { a = 1 }]) [@u ]
  > EOF

  $ melc -ppx melppx foo.ml
  melc: internal error, uncaught exception:
        File "jscomp/core/lam_compile_external_call.ml", line 231, characters 20-26: Assertion failed
        
  [125]
