
let a =
let module N = struct
    external create : x : 'a0 -> y : 'a1 -> < x : 'a0 ; y : 'a1 > Js.t = ""[@@mel.obj]
  end in
  N.create ~x:3 ~y:[1;2;3]
