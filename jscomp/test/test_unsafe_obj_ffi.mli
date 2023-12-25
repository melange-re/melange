val f : < height : int; width : int; .. > Js.t -> int


val g :
  < method1 : int -> unit [@u];
    method2 : int ->  int -> unit [@u]; .. >
  Js.t -> unit
class type _metric = object method height : int [@@mel.set] method width : int [@@mel.set] end [@u]
val h : _metric Js.t -> unit
