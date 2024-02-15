let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites



let () =
  eq __LOC__
  ("ghso ghso g"
  |. Js.String.split ~sep:" "
  |. Js.Array.reduce ~f:(fun x y ->  x ^  "-" ^ y) ~init:""
  ) "-ghso-ghso-g"



let () = Mt.from_pair_suites __MODULE__ !suites
