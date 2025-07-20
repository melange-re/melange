module Make (H : Hashtbl.HashedType) : Hash_set_gen.S with type key = H.t
