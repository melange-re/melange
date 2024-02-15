let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites


external map : 'a Js.Array.t -> ('a -> 'b [@u]) -> 'b Js.Array.t = "map" [@@mel.send]

let () =
  eq __LOC__
    (map [| 1;2;3;4 |] (fun[@u] x  -> x +  1))
    [|2;3;4;5|]

;; Mt.from_pair_suites __MODULE__ !suites
