
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

module Js_call : sig
  val parse_int : string -> int
end

module Js_object : sig
  val make : x:int -> y:int -> < x : int; y : int > Js.t
end

module Forward : sig
  val external_target : int -> int
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
