


let () = Js.log (Inner_define.N.add 1 2)
let () = Js.log (Inner_define.Deep.N.add 3 4)
let () = Js.log (Inner_define.Forward.choose 8 5)
let () = Js.log (Inner_define.Ffi.imul 6 7)
let () = Js.log (Inner_define.Ffi.basename "/tmp/ffi.txt")
let () = Js.log (Inner_define.Ffi.point 1 2)

let nested_external_wrapper x y = Inner_define.P.fancy_add x y
let nested_unresolved_ffi x y = Inner_define.Ffi.unresolved_add x y


open Inner_define

let f x =  
  N0.f1 x , N0.f2 x x, N0.f3 x x x,
  N1.f2 x x 
