type t =
  | Unknown
  | Direct_primitive of Lam_primitive.t
  | Direct_external of {
      dynamic_import : bool;
      id : Ident.t;
      name : string;
    }

val print : Format.formatter -> t -> unit
val is_unknown : t -> bool

val of_lambda :
  find_ident:(Ident.t -> t) ->
  find_external:(dynamic_import:bool -> Ident.t -> string -> t) ->
  Lam.t ->
  t
