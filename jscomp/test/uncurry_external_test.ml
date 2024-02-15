
let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites



[%%raw{|
function sum(a,b){
  return a + b
}
|}]


external sum : float -> float -> float [@u] = "sum"


let h = sum 1.0 2.0 [@u]


let () =
  eq __LOC__ h 3.
let () = Mt.from_pair_suites __MODULE__ !suites
