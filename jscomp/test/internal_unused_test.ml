[@@@warning "A"]
[@@@warnerror "a"]
;; module [@internal.local] P0 = struct
  let a = 3 in
  Js.log a ; a + 2 |. ignore
end
open! P0

;; module [@internal.local] P1 = struct
  exception A
  let _a = 2
end
open! P1

let f () = raise A

let%private b = 3

let%private c = b + 2

[%%private
let d = c
let f = d
let h = fun[@u] a b -> a + b
]


let%private h0 = 1

let%private h1 = h0 + 1

let%private h2 = h1 + 1

[%%private
let h3 = 1
let h4 = h3 + 1
let h5 = h4 + 1
]

module N = struct
  let %private a = 3
  let b = a + 2
end

;; Js.log h5
;; Js.log h2

;; Js.log f

;; Js.log (h 1 2 [@u])

(* module%private X  = Arg
type x = X.spec *)
(* [%%debugger.chrome] *)

module H = functor () -> struct
  external %private x : int -> int =  "x"
  [@@mel.module "./x"]
end
