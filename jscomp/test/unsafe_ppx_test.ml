let x : string = [%mel.raw{|"\x01\x02\x03"|}]

let max : float -> float -> float [@bs] =
  [%mel.raw "Math.max"  ]

let u v = max 1. v [@bs]
(* let max2 : float -> float -> float = [%mel.raw {Math.max} ]   *)
[%%mel.raw {|

function $$test(x,y){
  return x + y;
}
|}]


let regression3 : float -> float -> float [@bs] = [%mel.raw "Math.max"]

let regression4 : float ->  (float -> float [@bs]) -> float [@bs] =
  [%mel.raw "Math.max"]
let g a

  =
let regression  = ([%mel.raw{|function(x,y){
   return ""
}|}]  : float -> (string -> 'a) -> string) in

  let regression2 : float -> float -> float = [%mel.raw "Math.max"] in
  ignore @@ regression a failwith;
  ignore @@ regression2  3. 2.;
  ignore @@ regression3 3.  2. [@bs];
  ignore @@ regression4 3. (fun[@bs] x-> x) [@bs]


let max2 : float -> float -> float [@bs] = [%mel.raw "Math.max"]

let umax a b = max2 a b  [@bs]
let u h = max2 3. h [@bs]

let max3 = ([%mel.raw "Math.max"] :  float * float -> float [@bs])
let uu h = max2 3. h [@bs]

external test : int -> int -> int = "" [@@bs.val "$$test"]

let empty = ([%mel.raw {| Object.keys|} ] :  _ -> string array [@bs]) 3 [@bs]

let v = test 1 2

(* type v = width:int -> int [@bs] *)
(* class type t = object *)
(*   method exit : ?code:int -> unit -> unit *)
(* end [@bs] *)
(* see #570 *)

type vv = int -> int [@bs]

;; Mt.from_pair_suites __MODULE__ Mt.[
    "unsafe_max", (fun _ -> Eq(2., max 1. 2. [@bs]));
    "unsafe_test", (fun _ -> Eq(3,v));
    "unsafe_max2", (fun _ -> Eq(2, ([%mel.raw {|Math.max|} ] : int ->  int -> int [@bs]) 1 2 [@bs] ));
    "ffi_keys", ( fun _ -> Eq ([|"a"|], Ffi_js_test.keys [%mel.raw{| {a : 3}|}] [@bs]))
]



