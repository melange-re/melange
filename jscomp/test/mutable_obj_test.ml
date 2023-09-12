type u =
  < height : int [@mel.set] > Js.t




let f (x : u) =
  x##height#= 3  ;
  x##height * 2

let f ( x : < height : int [@mel.set{no_get}] > Js.t) =
  x##height#=3



type v =
   < dec : int -> < x : int ; y : float > Js.t [@u] [@mel.set]  >  Js.t

let f (x : v ) =
  x##dec#= (fun [@u] x -> [%mel.obj {x ; y = float_of_int x }])
