let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites


(* let f = fun x y  *)

(* let [@u] f x y = ..  *)


(* let! f x y =   *)
(*   let! x = f x y in *)
(*   let! y = f x y in    *)
(*   let! z = f x y in  *)
(*   return (x + y + z ) *)


(* let f x y =  *)
(*   let@bs z = f x y in  *)
(*   let@b y = f x y in    *)
(*   let@z z = f x y in  *)
(*   return (x + y + z ) *)


let f0 = fun [@u] x y -> fun z -> x + y + z
(* catch up. In OCaml we can not tell the difference from below
   {[
     let f = fun [@u] x y z -> x + y + z
   ]}
*)
let f1 = fun x -> fun [@u] y z -> x + y + z

let f2 = fun [@u] x y -> let a = x in fun z -> a + y +  z

let f3 = fun x -> let a = x in fun [@u] y z -> a + y + z
(* be careful! When you start optimize functions of [@u], its call site invariant
   (Ml_app) will not hold any more.
   So the best is never shrink functions which could change arity
*)
let () =
  begin
    eq __LOC__ 6 @@ f0 1 2 3 [@u] ;
        eq __LOC__ 6 @@ (f1 1 ) 2 3 [@u];
            eq __LOC__ 6   @@ ((f2 1 2 [@u]) 3);
            eq __LOC__ 6  @@ (f3 1 ) 2 3  [@u]
  end
let () = Mt.from_pair_suites __MODULE__ !suites
