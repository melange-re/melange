(* class type _y = *)
(*   object method height#= : ([ `Arity_1 of int ], unit) Js.meth end *)
(* type y = _y Js.t *)
(* class type _y0 = *)
(*   object *)
(*     method height : int Js.null *)
(*     method height#= : ([ `Arity_1 of int ], unit) Js.meth *)
(*   end *)
(* type y0 = _y0 Js.t *)
(* class type _y1 = *)
(*   object *)
(*     method height : int Js.undefined *)
(*     method height#= : ([ `Arity_1 of int ], unit) Js.meth *)
(*   end *)
(* type y1 = _y1 Js.t *)
(* class type _y2 = *)
(*   object *)
(*     method height : int Js.null_undefined *)
(*     method height#= : ([ `Arity_1 of int ], unit) Js.meth *)
(*   end *)
(* type y2 = _y2 Js.t *)
(* class type _y3 = object method height : int Js.null_undefined end *)
(* type y3 = _y3 Js.t *)


class type _y = object
  method height : int [@@mel.set no_get]
end [@u]
type y = _y Js.t
class type _y0 = object
  method height : int [@@mel.set] [@@mel.get null]
end [@u]
type y0 = _y0 Js.t

class type _y1 = object
  method height : int [@@mel.set] [@@mel.get undefined]
end[@u]
type y1 = _y1 Js.t

class type _y2 = object
  method height : int [@@mel.set] [@@mel.get nullable]
end [@u]
type y2 = _y2 Js.t

class type _y3 = object
  method height : int  [@@mel.get nullable]
end[@u]
type y3 = _y3 Js.t


type yy2 =
    < height : int
     [@mel.get nullable]
     [@mel.set] > Js.t


val fff :
    yy2 -> unit

val ff :
    y2 ->
    yy2 ->
    int Js.nullable list
