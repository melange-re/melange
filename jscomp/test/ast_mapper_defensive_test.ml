let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let throw loc x  =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id),
     (fun _ -> Mt.ThrowAny(x))) :: !suites



type c = [
  | `c0
  | `c1
  | `c2
  ]
[@@deriving  jsConverter {  newType }  ]


let () = throw __LOC__ (fun _ -> ignore @@ cFromJs (Obj.magic 33))
(* ;; Js.log2    *)

;; Mt.from_pair_suites __MODULE__ !suites
