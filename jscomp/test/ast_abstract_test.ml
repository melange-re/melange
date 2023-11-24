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


type a =
  | A
  | B [@mel.as 3]
  | C
[@@deriving jsConverter { newType }]

let id  x =
    eq  __LOC__ (aFromJs (aToJs x ))  x
let a0 = aToJs A
let a1 = aToJs B

let () =
  id  A ;
  id  B ;
  id  C


type b =
  | D0
  | D1
  | D2
  | D3
[@@deriving jsConverter { newType }]


let b0 = bToJs D0
let b1 = bToJs D1

let idb v =
  eq __LOC__ (bFromJs (bToJs v )) v

let () = idb D0; idb D1; idb D2 ; idb D3
type c =
  | D0 [@mel.as 3]
  | D1
  | D2
  | D3
[@@deriving jsConverter  {newType }]

let c0 = cToJs D0

let idc v = eq __LOC__ (cFromJs (cToJs v)) v

let () = idc D0; idc D1 ; idc D2; idc D3
type h =
  | JsMapperEraseType
  | B [@@deriving accessors, jsConverter { newType } ]


type z =
  | ZFromJs
  | ZToJs
  | ZXx (* not overridden *)
  [@@deriving   accessors, jsConverter ]

;; Mt.from_pair_suites __MODULE__ !suites
