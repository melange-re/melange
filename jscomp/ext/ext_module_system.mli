type t = NodeJS | Es6 | Es6_global

val default : t
val compatible : dep:t -> t -> bool
val runtime_dir : t -> string
val runtime_package_path : string -> string
val to_string : t -> string
val of_string_exn : string -> t
val of_string : string -> t option
