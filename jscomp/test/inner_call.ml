


let () = Js.log (Inner_define.N.add 1 2)
let () = Js.log (Inner_define.Deep.N.add 3 4)
let () = Js.log (Inner_define.ExternalAlias.N.add 13 14)
let () = Js.log (Inner_define.ExternalNAlias.add 15 16)
let () = Js.log (Inner_define.ExternalInclude.N.add 17 18)
let () = Js.log (Inner_define.ExternalNInclude.add 19 20)
let () = Js.log (Inner_define.Js_call.imul 6 7)
let () = Js.log (Inner_define.Js_call.basename "/tmp/ffi.txt")
let () = Js.log (Inner_define.P.concat [[|1|]; [|2|]])

let nested_external_wrapper x y = Inner_define.P.fancy_add x y
let nested_js_call_wrapper value = Inner_define.Js_call.parse_int value
let nested_object_wrapper x y = Inner_define.Js_object.make ~x ~y

let nested_direct_external_wrapper x =
  Inner_define.Forward.external_target x


open Inner_define

let f x =  
  N0.f1 x , N0.f2 x x, N0.f3 x x x,
  N1.f2 x x 
