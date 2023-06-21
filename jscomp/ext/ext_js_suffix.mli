type t = Js | Bs_js | Mjs | Cjs | Custom_extension of string

val to_string : t -> string
val of_string : string -> t
val default : t
