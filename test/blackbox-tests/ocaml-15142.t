Variance composition must preserve possible invariance when the inner type may
be injective (ocaml/ocaml#15142).

  $ . ./setup.sh

An abstract outer type may be an invariant GADT.

  $ cat > invariant.ml <<'EOF'
  > type 'a q = Q
  > module M (X : sig type 'a t end) : sig
  >   type +-'a s
  >   val inj : 'a q X.t -> 'a s
  >   val prj : 'a s -> 'a q X.t
  > end = struct
  >   type 'a s = 'a q X.t
  >   let inj x = x
  >   let prj x = x
  > end
  > EOF
  $ melc -i invariant.ml
  File "invariant.ml", lines 6-10, characters 6-3:
   6 | ......struct
   7 |   type 'a s = 'a q X.t
   8 |   let inj x = x
   9 |   let prj x = x
  10 | end
  Error: Signature mismatch:
         ...
         Type declarations do not match:
           type 'a s = 'a q X.t
         is not included in
           type +-'a s
         Their variances do not agree.
         File "invariant.ml", line 3, characters 2-13: Expected declaration
         File "invariant.ml", line 7, characters 2-22: Actual declaration
  [2]

An alias of an abstract bivariant type may still be injective.

  $ cat > abstract_alias.ml <<'EOF'
  > type 'a outer
  > type +-'a bivariant
  > type +-'a alias = 'a bivariant
  > type +-'a t = 'a alias outer
  > EOF
  $ melc -i abstract_alias.ml
  File "abstract_alias.ml", line 4, characters 0-28:
  4 | type +-'a t = 'a alias outer
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: In this definition, expected parameter variances are not satisfied.
         The 1st type parameter was expected to be unrestricted,
         but it is invariant.
  [2]

A private row can also hide an injective parameter.

  $ cat > private_row.ml <<'EOF'
  > type 'a outer
  > module M (X : sig type +-'a p = private [< `X ] end) = struct
  >   type +-'a t = 'a X.p outer
  > end
  > EOF
  $ melc -i private_row.ml
  File "private_row.ml", line 3, characters 2-28:
  3 |   type +-'a t = 'a X.p outer
        ^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: In this definition, expected parameter variances are not satisfied.
         The 1st type parameter was expected to be unrestricted,
         but it is invariant.
  [2]

Concrete phantom aliases erase their parameter and remain bivariant.

  $ cat > phantom.ml <<'EOF'
  > type 'a outer
  > type 'a phantom = unit
  > type +-'a erased = 'a phantom outer
  > type +-'a alias = 'a phantom
  > type +-'a erased_alias = 'a alias outer
  > EOF
  $ melc -i phantom.ml
  type 'a outer
  type 'a phantom = unit
  type 'a erased = 'a phantom outer
  type 'a alias = 'a phantom
  type 'a erased_alias = 'a alias outer
