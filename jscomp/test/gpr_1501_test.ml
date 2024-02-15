let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites


exception A
exception B of int

let () =

    eq __LOC__ "Not_found" (Printexc.to_string Not_found);
    eq __LOC__
      (Js.Re.test ~str:(Printexc.to_string A) [%re{|/Gpr_1501_test.A\/[0-9]+/|}])
      true;
    eq __LOC__
    (Js.Re.test ~str:(Printexc.to_string (B 1)) [%re{|/Gpr_1501_test.B\/[0-9]+\(1\)/|}]) true

let () =
    Mt.from_pair_suites __MODULE__ !suites
