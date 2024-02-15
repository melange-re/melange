module N = struct
  type t = { x : int}
end

module type X = sig
  type 'a f = {i : 'a }
  val forEach : 'a array ->  ('a -> unit) f -> unit [@u]
end

(* type annotation here interferes.. *)
let f (module X : X) (xs : N.t array) =
  X.forEach xs ({ X.i = fun x -> Js.log x.x} ) [@u]


;; Belt.List.forEachU [{N.x=3}] (fun[@u] x -> Js.log x.x)


module Foo = struct type record = {
                      foo: string;} end
let bar = [|{ Foo.foo = "bar" }|]

let _ = Belt.Array.mapU bar ((fun[@u] b  -> b.foo))
