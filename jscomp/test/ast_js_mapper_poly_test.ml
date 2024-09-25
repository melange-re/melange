let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites


type u =
  [ `D
  | `C
  | `f [@mel.as "x"]
  ]
[@@deriving jsConverter]

let eqU (x : u) (y : u) = x = y
let eqUOpt (x : u option) y =
  match x,y with
  | Some x, Some y -> x = y
  | None, None -> true
  | _, _ -> false

let () =
  eq __LOC__ (eqUOpt (uFromJs "x") (Some `f )) true;
  eq __LOC__ (eqUOpt (uFromJs "D") (Some `D )) true;
  eq __LOC__ (eqUOpt (uFromJs "C") (Some `C )) true;
  eq __LOC__ (eqUOpt (uFromJs "f") (None )) true;
  eq __LOC__ (Array.map uToJs [|`D; `C ; `f|]) [|"D"; "C"; "x"|]



;;
let (+>) = Array.append
;; Mt.from_pair_suites  __MODULE__ !suites
