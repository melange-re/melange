type 'a compare = 'a -> 'a -> int
type ('a, 'id) cmp

external getCmp : ('a, 'id) cmp -> 'a compare = "%identity"
(** only used for data structures, not exported for client usage *)

module type S = sig
  type id
  type t

  val cmp : (t, id) cmp
end

type ('key, 'id) t = (module S with type t = 'key and type id = 'id)

module Make (M : sig
  type t

  val cmp : t compare
end) : S with type t = M.t

val make : ('a -> 'a -> int) -> (module S with type t = 'a)
