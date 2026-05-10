type t =
  | Unknown
  | Direct_primitive of Lam_primitive.t

val print : Format.formatter -> t -> unit
val is_unknown : t -> bool

val of_lambda :
  find_ident:(Ident.t -> t) ->
  find_external:(dynamic_import:bool -> Ident.t -> string -> t) ->
  Lam.t ->
  t
