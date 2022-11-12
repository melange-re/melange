type t

val make : source_name:string -> output_name:string -> Ext_pp.t -> t
val write : t -> Location.t -> unit
val to_string : t -> string
