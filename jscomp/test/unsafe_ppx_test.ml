let x : string = [%mel.raw{|"\x01\x02\x03"|}]

let max : float -> float -> float [@u] =
  [%mel.raw "Math.max"  ]

let u v = max 1. v [@u]
(* let max2 : float -> float -> float = [%mel.raw {Math.max} ]   *)
[%%mel.raw {|

function $$test(x,y){
  return x + y;
}
|}]


let regression3 : float -> float -> float [@u] = [%mel.raw "Math.max"]

let regression4 : float ->  (float -> float [@u]) -> float [@u] =
  [%mel.raw "Math.max"]
let g a

  =
let regression  = ([%mel.raw{|function(x,y){
   return ""
}|}]  : float -> (string -> 'a) -> string) in

  let regression2 : float -> float -> float = [%mel.raw "Math.max"] in
  ignore @@ regression a failwith;
  ignore @@ regression2  3. 2.;
  ignore @@ regression3 3.  2. [@u];
  ignore @@ regression4 3. (fun[@u] x-> x) [@u]


let max2 : float -> float -> float [@u] = [%mel.raw "Math.max"]

let umax a b = max2 a b  [@u]
let u h = max2 3. h [@u]

let max3 = ([%mel.raw "Math.max"] :  float * float -> float [@u])
let uu h = max2 3. h [@u]

external test : int -> int -> int = "$$test"

let empty = ([%mel.raw {| Object.keys|} ] :  _ -> string array [@u]) 3 [@u]

let v = test 1 2

(* type v = width:int -> int [@u] *)
(* class type t = object *)
(*   method exit : ?code:int -> unit -> unit *)
(* end [@u] *)
(* see #570 *)

type vv = int -> int [@u]

;; Mt.from_pair_suites __MODULE__ Mt.[
    "unsafe_max", (fun _ -> Eq(2., max 1. 2. [@u]));
    "unsafe_test", (fun _ -> Eq(3,v));
    "unsafe_max2", (fun _ -> Eq(2, ([%mel.raw {|Math.max|} ] : int ->  int -> int [@u]) 1 2 [@u] ));
    "ffi_keys", ( fun _ -> Eq ([|"a"|], Ffi_js_test.keys [%mel.raw{| {a : 3}|}] [@u]))
]



