
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
  File "x.ml", line 22, characters 40-41:
  22 | let cast x = x |> Bad.inj |> (fun x -> (x :> _ M.t)) |> Bad.prj;;
                                               ^
  Error: This expression cannot be coerced to type 'a M.t; it has type 
         'a Bad.t but is here used with type 'b M.t
  [2]
