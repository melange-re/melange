An exception should not resolve through a module alias with the same name.
This currently crashes during exception lookup.

  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > module Base = struct end
  > module M = struct
  >   module E = Base
  >   exception E
  > end
  > let e = M.E
  > EOF

  $ melc x.ml
  >> Fatal error: Cannot find address for: Base
  melc: internal error, uncaught exception:
        Melange_compiler_libs__Misc.Fatal_error
        
  [125]
