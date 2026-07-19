external float_equal : float -> float -> bool = "caml_eq_float"
external string_less_than : string -> string -> bool = "caml_string_lessthan"
external polymorphic_equal : 'a -> 'a -> bool = "caml_equal"

let normalize_float_equal left right =
  if float_equal left right then true else false

let negate_string_less_than left right =
  if string_less_than left right then false else true

let normalize_polymorphic_equal left right =
  if polymorphic_equal left right then true else false
