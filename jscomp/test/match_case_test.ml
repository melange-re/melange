let suites : Mt.pair_suites ref = ref []
let test_id = ref 0

let eq loc x y =
  incr test_id;
  suites :=
    (loc ^ " id " ^ string_of_int test_id.contents, fun _ -> Mt.Eq (x, y))
      :: suites.contents

let f x = match x with "xx'''" -> 0 | "xx\"" -> 1 | _ -> 4

let () =
  eq __LOC__ (f "xx'''") 0;
  eq __LOC__ (f "xx\"") 1

let () = Mt.from_pair_suites __MODULE__ suites.contents
