
  $ . ./setup.sh
  $ cat > x.re <<EOF
  > let obj = {"": someValue};
  > EOF
  $ melc -pp 'refmt --print=binary' -ppx melppx -impl x.re
  Fatal error: exception File "jscomp/common/lam_methname.ml", line 136, characters 2-8: Assertion failed
  melc: internal error, uncaught exception:
        Melangelib.Cmd_ast_exception.Error(_)
        
  [125]
