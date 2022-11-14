type t

val create : source_name:string -> t
val add_mapping : t -> pp:Js_pp.t -> Location.t -> t
val to_string : t -> string
val to_channel : t -> out_channel -> unit
