
module N : sig 
  val add : int -> int -> int
end

module Deep : sig
  module N : sig
    val add : int -> int -> int
  end
end

module P : sig
  val fancy_add : int -> int -> int
end

module Forward : sig
  val choose : int -> int -> int
end

type point

type ffi_functions = {
  imul : int -> int -> int;
  basename : string -> string;
  point : int -> int -> point;
}

module Ffi : sig
  val imul : int -> int -> int
  val basename : string -> string
  val point : int -> int -> point
  val unresolved_add : int -> int -> int
end

module PackedFfi : sig
  val functions : ffi_functions
end



module type S0 =  sig 
  val f1 : unit -> unit 
  val f2 : unit -> unit -> unit 
  val f3 : unit -> unit -> unit -> unit 
end 

module N0 : S0 

module N1 : sig 
  val f2 : unit -> unit -> unit 
  val f3 : unit -> unit -> unit -> unit 
end
