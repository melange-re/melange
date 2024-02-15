[@@@warning "-30-104"]
type a =
  { u_x : int}
[@@deriving  accessors ]

type 'a b = {
  b_x  : int
}
and 'a c = {
  c_x : int
}
[@@deriving accessors]

type d =
  | D_empty
  | D_int of int
  | D_tuple of int * string
  | NewContent of string
  | D_tweak of (int * string)
  | Hei (* two hei derived, however, this hei is not accessible any more *)
and u =
  | Hei
and h = {d : d ; h : h list; u_X : int}
and e = { d : d }
[@@deriving accessors]



let v = d  @@ { d = d_int  3 }

let g = u_X

let h = [
  d_empty ;
  d_int 3 ;
  d_tuple 3 "hgo";
  d_tweak (3,"hgo");
  newContent "3"
]

type hh = Xx of int
[@@deriving accessors]

(* Not applicable to this type. *)
(* type xx = < x : int > Js.t [@@deriving accessors] *)

type t =
  | A of (int -> int [@u])
  [@@deriving accessors]


let f = a (fun [@u] x -> x)
