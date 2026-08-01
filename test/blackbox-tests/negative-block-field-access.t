Negative constant field access on an immutable block does not crash the compiler

  $ . ./setup.sh
  $ cat > x.ml <<'EOF'
  > let block =
  >   ( Sys.opaque_identity 1,
  >     Sys.opaque_identity 2,
  >     Sys.opaque_identity 3 )
  > let field = Obj.field (Obj.repr block) (-1)
  > EOF
  $ melc x.ml -o x.js
  melc: internal error, uncaught exception:
        Invalid_argument("List.nth")
        
  [125]
