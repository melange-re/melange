


let () = Js.log (Inner_define.N.add 1 2)
let () = Js.log (Inner_define.Deep.N.add 3 4)

let nested_external_wrapper x y = Inner_define.P.fancy_add x y


open Inner_define

let f x =  
  N0.f1 x , N0.f2 x x, N0.f3 x x x,
  N1.f2 x x 
