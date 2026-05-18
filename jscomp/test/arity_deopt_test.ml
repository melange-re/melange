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

let utf_8_byte_length u =
  let u = Arity_deopt_helper.uchar_to_int u in
  if u <= 0x007F then 1
  else if u <= 0x07FF then 2
  else if u <= 0xFFFF then 3
  else 4

let captures_after_effect a = Arity_deopt_helper.captures_after_effect a

(* be careful! When you start optimize functions of [@u], its call site invariant
   (Ml_app) will not hold any more.
   So the best is never shrink functions which could change arity
*)

module Local_module_field = struct
  module Nested = struct
    let effects = ref []

    let x a =
      effects := "outer" :: !effects;
      fun b ->
        effects := "inner" :: !effects;
        a + b
  end

  let effects = ref []

  let x a =
    effects := "outer" :: !effects;
    fun b ->
      effects := "inner" :: !effects;
      a + b
end

let local_module_field_result = Local_module_field.x 1 2
let nested_module_field_result = Local_module_field.Nested.x 1 2

let () =
  begin
    eq __LOC__ 6 @@ f0 1 2 3 [@u] ;
        eq __LOC__ 6 @@ (f1 1 ) 2 3 [@u];
            eq __LOC__ 6   @@ ((f2 1 2 [@u]) 3);
            eq __LOC__ 6  @@ (f3 1 ) 2 3  [@u];
            eq __LOC__ 1 @@ utf_8_byte_length (Uchar.of_int 0x007F);
            eq __LOC__ 3 @@ utf_8_byte_length (Uchar.of_int 0x0800);
            eq __LOC__ 3 @@ captures_after_effect 1 2;
            eq __LOC__ 3 local_module_field_result;
            eq __LOC__ ["inner"; "outer"] !(Local_module_field.effects);
            eq __LOC__ 3 nested_module_field_result;
            eq __LOC__ ["inner"; "outer"] !(Local_module_field.Nested.effects)
  end
let () = Mt.from_pair_suites __MODULE__ !suites
