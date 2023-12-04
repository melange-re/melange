open Js.Obj


type  x = < say : int -> int >




let f  (u : x ) = u # say 32

let f_js u = u#@say 32

let suites = Mt.[
  "caml_obj", (fun _ ->
  Eq (33, f (object method say x = 1 + x end)));
  "js_obj", (fun _ ->
    Eq(34, f_js [%obj{ say = fun [@u]  x -> x + 2 } ]));
  "js_obj2", (fun _ ->
    Eq(34,  [%obj { say = fun [@u]  x -> x + 2 }] #@say 32 ));
  "empty", (fun _ ->
    Eq(0, empty () |> keys |> Array.length));
  "assign", (fun _ ->
    Eq([%obj { a = 1 }], assign (empty ()) [%obj { a = 1 }]));
  "merge", (fun _ ->
    let original = [%obj { a = 1 }] in
    Eq([%obj { a = 2 }], merge original [%obj { a = 2 }]));
  "merge-preserves-original", (fun _ ->
    let original = [%obj { a = 1 }] in
    let _merged = merge original [%obj { a = 2 }] in
    Eq([%obj { a = 1 }], original));
    (*
  "assignMany", (fun _ ->
    let o1 = [%obj { a = 1; b = 1; c = 1 }] in
    let o2 = [%obj { b = 2; c = 2 }] in
    let o3 = [%obj { c = 3 }] in
    Eq([%obj { a = 1; b = 2; c = 3 }], assignMany o1 [| o2; o3 |]));
    *)
]

;; Mt.from_pair_suites __MODULE__ suites

(* class type say = object  *)
(*     method say : int -> int *)
(* end *)
(* create real js object with [this] semantics *)
(* fun _ -> let module N =  *)
(*     struct *)
(*       external mk : say:'a -> say Js.t = ""[@@mel.obj]  *)
(*     end  *)
(*   in  *)
