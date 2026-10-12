Constrained module patterns apply the package constraint once before binding
module fields.

  $ . ./setup.sh

  $ cat > constrained.ml <<'EOF'
  > module type S = sig
  >   type t
  >   val value : int
  >   val apply : int -> int
  > end
  > module M = struct
  >   type t = string
  >   let value = 41
  >   let apply x = x + 1
  > end
  > let { value; apply } : (module S) = (module M)
  > let result = apply value
  > EOF

  $ ocamlc -ppx 'melppx -locations-check' -c constrained.ml
  $ melc -ppx 'melppx -locations-check' constrained.ml -o constrained.js
  $ node <<'EOF'
  > const { result } = require("./constrained.js");
  > console.log(result);
  > EOF
  42

The package signature controls which module fields can be selected.

  $ cat > hidden.ml <<'EOF'
  > module type S = sig
  >   type t
  >   val visible : int
  > end
  > module M = struct
  >   type t = int
  >   let visible = 1
  >   let hidden = 2
  > end
  > let { visible; hidden } : (module S) = (module M)
  > EOF

  $ ocamlc -ppx 'melppx -locations-check' -c hidden.ml
  File "hidden.ml", line 10, characters 15-21:
  10 | let { visible; hidden } : (module S) = (module M)
                      ^^^^^^
  Error: Unbound value M.hidden
  [2]
