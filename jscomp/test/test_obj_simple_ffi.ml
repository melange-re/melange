type t
external mk_obj_spec : ?displayName:string -> test:int -> config:int  -> hi:string ->
  unit ->  t =
  "" [@@mel.obj]
let v ?displayName () = mk_obj_spec ~test:3 ~config:3 ~hi:"ghos" ?displayName ()
let v2  = mk_obj_spec ~test:3 ~config:3 ~hi:"ghos"  ()
let v3  = mk_obj_spec ~test:3 ~config:3 ~hi:"ghos" ~displayName:"display" ()


class type x = object
  method tet : (x Js.t -> int -> int -> int  [@mel.this])
end


class type y = object
  method tet : y Js.t -> int -> int -> int  [@mel.this]
end


let u (x : x) : y = x

type h = < bark : 'self -> int -> int [@mel.this] > Js.t as 'self
type hh = < bark :( 'self -> int -> int [@mel.this]) > Js.t as 'self

let ff (x  : h) : hh = x

(* let f (u : x Js.t) =  *)
(*   u#.tet (1,2) *)


type 'a return = int -> 'a [@u]
type 'a u = int -> string -> 'a return  [@u]

type 'a u2 = int -> string -> int -> 'a [@u]

type 'a u3 = int -> string -> (int -> 'a [@u]) [@u]

(* let fff (x : 'a u) :  'a u2 =  *)
(*   x  *)


let fff (x : 'a u) :  'a u3 =
  x


type 'a ret = 'a -> int [@u]

type 'a u4 = < case : (int -> 'a ret ) >

type 'a u5 = < case : (int -> (int -> 'a [@u])) >

let ff ( x : 'a u4) : 'a u5 =  x


type 'a v0 = int -> 'a ret [@u]
type 'a v1 =  int -> ('a -> int [@u]) [@u]

type 'a xx = int -> 'a [@mel.this]
type 'a w0 = int -> 'a xx [@u]
type 'a w1 =  int -> (int -> 'a [@mel.this]) [@u]
let f (x : 'a w0) : 'a w1 =  x

type 'a v2 = int -> 'a ret [@mel.this]
type 'a v3 = int -> ('a -> int [@u]) [@mel.this]


let f (x : 'a v0) : 'a v1 = x
let ff (x : 'a v2 ) : 'a v3 = x

type 'a u6 = < case : int -> 'a ret  ; >

type 'a u7 = < case : int -> ('a  -> int [@u])  ; >

let fff (x : 'a u6) : 'a u7= x

let f : int -> int -> (int -> int -> int [@u]) [@u] =
  fun [@u] x y -> fun [@u] u v -> x + y + u + v


type 'a xx0 = < hi : int -> int [@mel.this] >
type 'a xx1 = < hi : (int -> int [@mel.this]) >


let f (x : 'a xx0) : 'a xx1 = x
