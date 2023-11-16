let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites


external map :
     ('a -> 'b [@mel.uncurry]) -> 'b array =
     "map" [@@mel.send.pipe: 'a array]


[%%raw{|
function hi (cb){
    cb ();
    return 0;
}
|}]

external hi : (unit -> unit [@mel.uncurry]) -> unit = "hi"

let () =
    let xs = ref [] in
    hi (fun (() as x) -> xs := x ::!xs ) ;
    hi (fun (() as x) -> xs := x ::!xs ) ;
    eq __LOC__ !xs [();()]



let () =
    begin
    eq __LOC__
    ([|1;2;3|] |> map (fun x -> x + 1))
    ([|2;3;4|]);
    eq __LOC__
    ([|1;2;3|] |. Js.Array.map ~f:(fun x -> x + 1))
    ([|2;3;4|]);

    eq __LOC__
    ([|1;2;3|] |. Js.Array.reduce ~f:(+) ~init:0)
    6 ;

    eq __LOC__
    ([|1;2;3|] |. Js.Array.reducei ~f:(fun x y i -> x + y + i) ~init:0)
    9;

    eq __LOC__
    ([| 1;2;3|] |. Js.Array.some ~f:(fun x -> x <1))
    false ;

    eq __LOC__
    ([|1;2;3|] |. Js.Array.every ~f:(fun x -> x > 0))
    true

    end




let () =
    Mt.from_pair_suites __MODULE__ !suites
