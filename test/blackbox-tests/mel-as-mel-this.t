
  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > type t
  > external f: int -> (_ [@mel.as "x"] [@mel.this]) -> unit = "set"
  > [@@mel.send]
  > let () = f 3
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 2, characters 38-46:
  2 | external f: int -> (_ [@mel.as "x"] [@mel.this]) -> unit = "set"
                                            ^^^^^^^^
  Alert unused: Unused attribute [@mel.this]
  This means such annotation is not annotated properly.
  For example, some annotations are only meaningful in externals
  
  melc: internal error, uncaught exception:
        File "jscomp/core/lam_compile_external_call.ml", line 290, characters 35-41: Assertion failed
        
  [125]
