


class type _y = object
  method height : int [@@mel.set {no_get}]
end [@u]
type y = _y Js.t
class type _y0 = object
  method height : int [@@mel.set] [@@mel.get {null}]
end [@u]
type y0 = _y0 Js.t

class type _y1 = object
  method height : int [@@mel.set] [@@mel.get {undefined}]
end[@u]
type y1 = _y1 Js.t

class type _y2 = object
  method height : int [@@mel.set] [@@mel.get {undefined; null}]
end [@u]
type y2 = _y2 Js.t

class type _y3 = object
  method height : int  [@@mel.get {undefined ; null}]
end[@u]
type y3 = _y3 Js.t


type yy2 = < height : int [@mel.get{undefined ; null}] [@mel.set] > Js.t


let fff (x : yy2) =
   x##height #= 2


let ff (x : y2) (z : yy2) =
   [ x ##height ;
    z##height
   ]
