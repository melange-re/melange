


class type _u = object
  method height : int [@@mel.set]
end[@u]

type u = _u Js.t

let f (x : u) =
  x##height #= 3

class type v = object
  method height : int
end

let h (x : v) = x#height
