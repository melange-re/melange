type 'a t =
  | Return of 'a
  | Suspend of (('a -> unit) -> unit)

val return : 'a -> 'a t
val suspend : (('a -> unit) -> unit) -> 'a t
val map : ('a -> 'b) -> 'a t -> 'b t
val bind : 'a t -> ('a -> 'b t) -> 'b t
val run_with : 'a t -> ('a -> unit) -> unit
