[@@@ocaml.warning "-a"]

type t = {

  mutable hi : int
    [@bs.as "Content-Type"];
  mutable low : int
    [@bs.as "l"];
  mutable x : int;
    [@bs.as "open"]
} [@@deriving abstract]
  (* [@@bs.x] *)


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
  [@optional]
  [@as "lo-x"]
;
  hi : int
} [@@deriving abstract]


(**
external a : ?low:int -> hi:int -> a
low: a -> int option [@@bs.return undefined_to_opt]
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
    [@bs.optional] ;
    a1 : int option
    [@bs.optional];
    a2 : int option
    [@bs.optional];
    a3 : int option
    [@bs.optional];
    a4 : int option
    [@bs.optional];
    a5 : int option
    [@bs.optional];
    a6 : int option
    [@bs.optional];
    a7 : int option
    [@bs.optional];
    a8 : int option
    [@bs.optional];
    a9 : int option
    [@bs.optional]
    [@bs.as "xx-yy"];
    a10 : int option
    [@bs.optional];
    a11 : int option
    [@bs.optional];
    a12 : int option
    [@bs.optional];
    a13 : int option
    [@bs.optional];
    a14 : int option
    [@bs.optional];
    a15 : int option
    [@bs.optional] ;
  }
  [@@deriving abstract]


let u = css ~a9:3 ()
let v =
  match u |. a9Get with
  | None -> 0
  | Some x -> x
