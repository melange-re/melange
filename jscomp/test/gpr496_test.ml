let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites


let expected =
  (true = false,
   false = true,
   false = false,
   true = true,
   Stdlib.compare false true ,
   Stdlib.compare true false,
   Stdlib.compare false false,
   Stdlib.compare true true
  )

let expected2 =
  ( false,
    false,
    true,
    true,
    -1,
    1,
    0,
    0
  )
let u =
  (true = false,
   false = true,
   false = false,
   true = true,
   Stdlib.compare false true,
   Stdlib.compare true false,
   Stdlib.compare false false,
   Stdlib.compare true true
  )


let () = eq __LOC__ expected u

let () = eq __LOC__ expected expected2

let ff (x: bool) y = min x (y ())
let () =
  eq __LOC__ (min true false) false

let () = Mt.from_pair_suites __MODULE__ !suites
