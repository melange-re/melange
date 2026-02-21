open Import

val enabled_from_env : unit -> bool

val transform_groups :
  enabled:bool ->
  effectful:Ident.Set.t ->
  Lam_group.t list ->
  Lam_group.t list
