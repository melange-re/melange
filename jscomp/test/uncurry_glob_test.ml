



module M ( U : sig val f : int -> string -> string [@u] end ) =
struct
  let v = U.f 100 "x" [@u]
end


let f = fun [@u] () -> 3


let u = f () [@u]

let (+>) = fun [@u]  a (h : _ -> int [@u]) -> h a [@u]

let u h = 3 +> h  [@u]


