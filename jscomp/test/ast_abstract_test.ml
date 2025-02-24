let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites



type 'a t =
  {
    x : int ;
    y : bool;
    z : 'a
  }

[@@deriving jsConverter { newType }]


let v0 = tToJs { x = 3 ; y  = false; z = false}
let v1 = tToJs { x = 3 ; y  = false; z = ""}


type x =
  [`a
  |`b
  |`c]

[@@deriving jsConverter { newType }]


let idx v =   eq __LOC__ (xFromJs (xToJs v)) v
let x0 = xToJs `a
let x1 = xToJs `b

let () =
  idx `a ;
  idx `b;
  idx `c

type h =
  | JsMapperEraseType
  | B [@@deriving accessors]


type z =
  | ZFromJs
  | ZToJs
  | ZXx (* not overridden *)
  [@@deriving   accessors]

;; Mt.from_pair_suites __MODULE__ !suites
