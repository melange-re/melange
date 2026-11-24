val name : top:bool -> string -> string

val signature :
  top:bool ->
  Melange_compiler_libs.Env.t ->
  Melange_compiler_libs.Types.signature ->
  unit

val module_fields : string list -> unit
