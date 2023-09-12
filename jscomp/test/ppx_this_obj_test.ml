let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc (x, y) =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites

let v  =
  let x = 3. in
  object (self)
    method x () = x
    method say x = x *. self## x ()
    method hi x y = self##say x +. y
  end [@u]
(** compile infer
class type js_obj =  object
  method x : unit -> float
  method say : float -> float
  method hi : float -> float -> float
end [@u]
val js_obj : js_obj Js.t
*)

let v2  =
  let x = 3. in
  object (self)
    method hi x  = fun y -> self##say x +. y
    method say  = fun x ->  x *. self## x ()
    method x () = x
  end [@u]


let v3 =
  let x = 3. in
  object (self)
    method hi x y =
      let u = [%mel.obj{ x  }] in
      self##say u##x +. y +.x
    method say  = fun x ->  x *. self## x ()
    method x () = x
  end [@u]

let v4 =
  object
    method hi x y = x +. y
    method say x = x
    method x () = 1.
  end [@u]

(* let v5 =  *)
(*   object *)
(*     method x = x      *)
(*   end [@u]     *)

(** guarantee they have the same type *)
let collection = [| v ; v2 ; v3 ; v4 |]

let () =
  eq __LOC__ (11., v##hi 3. 2.);
  eq __LOC__ (11., v2##hi 3. 2.)

let () = Mt.from_pair_suites __MODULE__ !suites
