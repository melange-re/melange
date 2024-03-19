external empty : unit -> < .. > t = "" [@@mel.obj]

external assign : < .. > t -> < .. > t -> < .. > t = "assign"
[@@mel.scope "Object"]

external merge : (_[@mel.as {json|{}|json}]) -> < .. > t -> < .. > t -> < .. > t
  = "assign"
[@@mel.scope "Object"]
(** [merge obj1 obj2] assigns the properties in [obj2] to a copy of
      [obj1]. The function returns a new object, and both arguments are not
      mutated *)

external keys : _ t -> string array = "keys" [@@mel.scope "Object"]
