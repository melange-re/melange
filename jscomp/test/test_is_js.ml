let v = true

let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y = Mt.eq_suites ~test_id ~suites loc x y
let b loc x = Mt.bool_suites ~test_id ~suites loc x;;


b __LOC__  true;;


b __LOC__ true;;


let () = Mt.from_pair_suites __MODULE__ !suites
