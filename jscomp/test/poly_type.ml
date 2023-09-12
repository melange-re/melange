


class type history = object
  method pushState : 'a . 'a -> string  -> unit
end [@u]

let f (x : history Js.t) =
  x##pushState  3 "x";
  x##pushState None "x"
