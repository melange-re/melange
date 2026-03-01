open Import

val transform_groups :
  effectful:Ident.Set.t ->
  Lam_group.t list ->
  Lam_group.t list
