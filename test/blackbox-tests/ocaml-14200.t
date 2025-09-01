
  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > module M : sig
  >   type 'a t = private string
  >   type foo = private int
  >   type bar = private int
  >   val foo : foo t
  > end = struct
  >   type 'a t = string
  >   type foo = private int
  >   type bar = private int
  >   let foo = "foo"
  > end;;
  > type 'a priv = private int
  > module Bad : sig
  >   type +-'a t = private int
  >   val inj : 'a priv -> 'a t
  >   val prj : 'a t -> 'a priv
  > end = struct
  >   type 'a t = 'a priv
  >   let inj = Fun.id
  >   let prj = Fun.id
  > end
  > let cast x = x |> Bad.inj |> (fun x -> (x :> _ M.t)) |> Bad.prj;;
  > EOF

  $ melc x.ml
  File "x.ml", lines 17-21, characters 6-3:
  17 | ......struct
  18 |   type 'a t = 'a priv
  19 |   let inj = Fun.id
  20 |   let prj = Fun.id
  21 | end
  Error: Signature mismatch:
         ...
         Type declarations do not match:
           type 'a t = 'a priv
         is not included in
           type +-'a t = private int
         Their variances do not agree.
         File "x.ml", line 14, characters 2-27: Expected declaration
         File "x.ml", line 18, characters 2-21: Actual declaration
  [2]
