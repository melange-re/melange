type t

module Pos : sig
  type t = Lexing.position

  val line_col : t -> Sourcemap.line_col
  val pp : Format.formatter -> t -> unit
end

val create : source_name:string -> t
val add_mapping : t -> pp:Js_pp.t -> Location.t -> t
val add_sources_content : t -> string -> t
val to_string : t -> string
val to_channel : t -> out_channel -> unit
