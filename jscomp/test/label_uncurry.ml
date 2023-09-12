

open Js.Fn

type t = x:int -> y:string -> int [@u]

type u =  (x:int -> y:string -> int) arity2

let f (x : t) : u = x

let u : u = fun [@u] ~x ~y -> x + int_of_string y

let u1  (f : u) =
  (f  ~y:"x" ~x:2  [@u]) |. Js.log ;
  (f  ~x:2 ~y:"x"   [@u]) |. Js.log
let h = fun [@u] ~x:unit -> 3

let a = u1 u



type u0 = ?x:int -> y : string -> int [@u]

(*let f = fun[@u] ?x y -> x + y *)

(* let h (x :u0) = x ~y:"x" ~x:3 [@u] *)
