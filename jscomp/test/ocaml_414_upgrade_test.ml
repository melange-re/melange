(* Tests a possible regression / deoptimization when upgrading to 4.14 *)
module N = struct
  type t = { x : int}
end

module type X = sig
  type 'a f = {i : 'a }
  val forEach : 'a array ->  ('a -> unit) f -> unit [@u]
end
module Y = struct
  type 'a f = { i : 'a}
  let forEach = fun [@u] xs f ->
    Belt.Array.forEach xs (( fun  x -> f.i x )  )
end


let f (module X : X) (xs : N.t array) =
  X.forEach xs ({ X.i = fun x -> Js.log x.x} ) [@u]

let g = fun  (module X: X) xs ->
  (Belt.Array.forEach xs (fun x -> Js.log x) )


let g_result = g (module Y) [||]
