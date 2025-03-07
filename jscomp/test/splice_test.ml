let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y = Mt.eq_suites ~test_id ~suites loc x y


module Caml_splice_call = struct
end
external f : int -> int array -> int = "Math.max"
  [@@mel.variadic]

;; f 1 [||] |. ignore

external send : int -> int array -> int = "send"
  [@@mel.variadic] [@@mel.send]

let f00 a b =
  a |. send [|b|]

external push : int array -> int -> int array -> unit =
  "push" [@@mel.send] [@@mel.variadic]

(* This is only test, the binding maybe wrong
  since in OCaml array'length is not mutable
*)
let () =
  let a = [||] in
  a |. push 1 [|2;3;4|];

  eq __LOC__ a [|1;2;3;4|]

let dynamic arr =
  let a = [||] in
  a |. push 1 arr ;
  eq __LOC__ a (Array.concat [[|1|]; arr])

;; dynamic [|2;3;4|]
;; dynamic [||]
;; dynamic [|1;1;3|]

(* Array constructor with a single parameter `x`
   just makes an array with its length set to `x`,
   so at least two parameters are needed
*)
external newArr : int -> int -> int array -> int array = "Array"
  [@@mel.variadic] [@@mel.new]

let () =
  let a = newArr 1 2 [|3;4|] in
  eq __LOC__ a [|1;2;3;4|]

let dynamicNew arr =
  let a = newArr 1 2 arr in
  eq __LOC__ a (Array.concat [[|1; 2|]; arr])

;; dynamicNew [|3;4|]
;; dynamicNew [||]
;; dynamicNew [|1;3|]

module Pipe = struct
  external push :  int -> int array -> (int array [@mel.this]) -> unit =
    "push" [@@mel.send] [@@mel.variadic]

  (* This is only test, the binding maybe wrong
     since in OCaml array'length is not mutable
  *)
  let () =
    let a = [||] in
    a |> push 1 [|2;3;4|];

    eq __LOC__ a [|1;2;3;4|]

  let dynamic arr =
    let a = [||] in
    a |> push 1 arr ;
    eq __LOC__ a (Array.concat [[|1|]; arr])

  ;; dynamic [|2;3;4|]
  ;; dynamic [||]
  ;; dynamic [|1;1;3|]

end

let f1 (c : int array) =  f 1 c

;; eq __LOC__ (f1  [|2;3|] ) 3
;; eq __LOC__ (f1  [||] ) 1
;; eq __LOC__ (f1 [|1;2;3;4;5;2;3|]) 5

;; Mt.from_pair_suites __FILE__ !suites
