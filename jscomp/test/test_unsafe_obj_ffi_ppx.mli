class type _v = object
  method height : int  [@@mel.set]
  method width  : int [@@mel.set]
end[@u]
type v = _v Js.t

class type ['a] _g = object
  method method1 : int -> unit
  method method2 : int -> int -> 'a
end[@u]
type 'a g = 'a _g Js.t

val f : < length : float; width : float; .. > Js.t -> float

val h : v -> unit

val chain : < element : < length : int; .. > Js.t; .. > Js.t -> int

val g : 'a g -> 'a

(** Another proposal :

{[
  val g :
    [%mel.obj: <
           method1 : int -> unit ;
           method2 : int * int -> 'a ;
           ..
                    >
    ] -> 'a
]}
*)
