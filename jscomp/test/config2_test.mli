

class type v = object
  method hey : int -> int -> int
end [@u]

class type v2 = object
  method hey : int -> int -> int
end [@u]

type vv =
   <
    hey : int -> int -> int [@u]
  >  Js.t

type vv2 =
   <
    hey : int -> int -> int [@u]
  > Js.t


val test_v : v Js.t -> int
val test_vv : vv -> int
