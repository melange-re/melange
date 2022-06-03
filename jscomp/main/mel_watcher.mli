module Task : sig
  type info = { fd : Luv.Process.t; paths : string list }

  type t =
    ?on_exit:(Luv.Process.t -> exit_status:int64 -> term_signal:int -> unit) ->
    unit ->
    info
end

val watch : task:Task.t -> string list -> unit
