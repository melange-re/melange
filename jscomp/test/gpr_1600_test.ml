let f : (int * int -> int [@u]) = fun [@u] x -> let a,b = x in a + b


let[@ocaml.warning "-61"] obj : < hi : (int * int -> unit [@mel.meth]) > Js.t  = object
  method hi (x : int * int) =  Js.log x
end [@u]
(** expect *)

class type _a = object
  method empty : unit -> unit
  method currentEvents : unit -> (string * string) array
  method push : string * string -> unit
  method needRebuild : unit -> bool
end [@u]

type a = _a Js.t

let eventObj : < currentEvents : (unit -> (string * string) array [@mel.meth]);
    empty : (unit -> unit [@mel.meth]);
    needRebuild : (unit -> bool [@mel.meth]);
    push : (string * string -> unit [@mel.meth]) >
  Js.t =  object (self)
  val events : (string * string) array = [||]
  method empty () = ()
  method push a = Array.unsafe_set self##events 0 a
  method needRebuild () = Array.length self##events <>  0
  method currentEvents () = self##events
end [@u]

let f () = (eventObj : a)
