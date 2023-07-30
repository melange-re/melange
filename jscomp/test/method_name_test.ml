let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites


let f x i file v =
  x##case i ;
  x##case__set i v;
  x##_open file;
  x##open__ file ;
  x##_MAX_LENGTH

let ff x i v =
  x##make__config ;
  x##make_config;
  x##make__config #= v ;
  x##make_config #= v ;
  x##case__unsafe i ;
  x##_open__ 3
  (* x##__open 32; *)
  (* x##case_setUnsafe (i,v) *)
(* do we need polymorphism over [case#=]
   I can only think of [case#=] will have one type
   ['key -> 'value -> void ]
   unlike [case] which may have different return types
*)


let u = [%mel.obj { _Content'type = "x" }]

let h = [%mel.obj { _open = 3 ; _end = 32 } ]

let hg x =
  x##_open + x ##_end

let () = eq __LOC__ 35 (hg  h)

let () = Mt.from_pair_suites __MODULE__ !suites
