let suites :  Mt.pair_suites ref  = ref []

let add_test =
  let counter = ref 0 in
  fun loc test ->
    incr counter;
    let id = (loc ^ " id " ^ (string_of_int !counter)) in
    suites := (id, test) :: ! suites

let eq loc x y =
  add_test loc (fun _ -> Mt.Eq (x, y))

let () = eq __LOC__ (Js.Cast.intOfBool true) 1

let () = eq __LOC__ (Js.Cast.intOfBool false) 0

let () = eq __LOC__ (Js.Cast.floatOfInt 0) 0.0

let () = eq __LOC__ (Js.Cast.floatOfInt 1) 1.0

let () = eq __LOC__ (Js.Cast.floatOfInt 123456789) 123456789.0

let () = Mt.from_pair_suites __MODULE__ !suites
