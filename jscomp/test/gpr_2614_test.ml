[@@@ocaml.warning "-a"]

type t = {

  mutable hi : int
    [@mel.as "Content-Type"];
  mutable low : int
    [@mel.as "l"];
  mutable x : int;
    [@mel.as "open"]
} [@@deriving jsProperties, getSet]
  (* [@@mel.x] *)


let v = t ~hi:3 ~low:2 ~x:2


let (a,b,c) = (v |. hiGet, v |. lowGet, v |. xGet)

(**

  v |. (hi, lo)
*)
let ff () =
  v |. hiSet 3;
  v |. lowSet 2


type a = {
  mutable low : string option
  [@mel.optional]
  [@mel.as "lo-x"]
;
  hi : int
} [@@deriving jsProperties, getSet]


(**
external a : ?low:int -> hi:int -> a
low: a -> int option [@@mel.return undefined_to_opt]
lowSet : a -> int -> unit
*)
let h0 =
  a ~hi:2 ~low:"x"

let h1 =   a ~hi:2 ~low:"x" ()

let h2 = a ~hi:2 ()

let hh x =
  x |. lowSet "3";
  x |. lowGet

(** should we make the type of

    lowSet : a -> string option -> unit
    lowSet : a -> string -> unit
*)

let hh2 x =
  match x |. lowGet with
  | None -> 0
  | Some _ -> 1


type css =
  {
    a0 : int option
    [@mel.optional] ;
    a1 : int option
    [@mel.optional];
    a2 : int option
    [@mel.optional];
    a3 : int option
    [@mel.optional];
    a4 : int option
    [@mel.optional];
    a5 : int option
    [@mel.optional];
    a6 : int option
    [@mel.optional];
    a7 : int option
    [@mel.optional];
    a8 : int option
    [@mel.optional];
    a9 : int option
    [@mel.optional]
    [@mel.as "xx-yy"];
    a10 : int option
    [@mel.optional];
    a11 : int option
    [@mel.optional];
    a12 : int option
    [@mel.optional];
    a13 : int option
    [@mel.optional];
    a14 : int option
    [@mel.optional];
    a15 : int option
    [@mel.optional] ;
  }
  [@@deriving jsProperties, getSet]


let u = css ~a9:3 ()
let v =
  match u |. a9Get with
  | None -> 0
  | Some x -> x
