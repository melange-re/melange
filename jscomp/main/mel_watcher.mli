module Task : sig
  type info = { fd : Luv.Process.t; paths : string list }

  type t =
    ?on_exit:(Luv.Process.t -> exit_status:int64 -> term_signal:int -> unit) ->
    unit ->
    info
end

module Job : sig
  type t = {
    mutable fd : Luv.Process.t option;
    mutable watchers : (string, Luv.FS_event.t) Hashtbl.t;
    task : Task.t;
  }

  val create : task:Task.t -> t
  val stop : t -> unit
  val restart : ?started:(Task.info -> unit) -> t -> unit
end

val watch : task:Task.t -> string list -> unit
