type t = Js | Bs_js | Mjs | Cjs | Unknown_extension

val to_string : t -> string
val of_string : string -> t
val default : t
