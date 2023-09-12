let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites


let u = (fun [@u] a  b -> a + b )  1  2  [@u]

let nullary = fun [@u] () -> 3

let unary = fun [@u] a -> a + 3

let xx = unary  3 [@u]
let () =
  eq __LOC__ u 3

;;
external f : int -> int [@u] = "xx"

let h a =
  f a [@u]
;;
Mt.from_pair_suites __MODULE__ !suites
