(*
To work around unused attribute checking

- we mark it used in ppx stage
we can not mark it in parsing since it won't
works for reason
*)
type t = {
  mutable x : int [@mel.as "THIS_IS_NOT_EXPRESSIBLE_IN_BUCKLE"]
   (* test key word later *)
}



let f x  = { x}

let set x = x.x <- 3 ; x.x * 2

type x = t = private {
  mutable x : int [@mel.as "THIS_IS_NOT_EXPRESSIBLE_IN_BUCKLE"]
}

type t0 = { x: t0 ; y : int}

let f1 u =
match u with
| {x = { x = {x={y;_};_};_};_}   ->     y

type t1 = {
  mutable x' : int
}


let f2 (x : t1) =
  x.x' <- x.x' + 3;
  {x' = x.x' + 3}

type t2 = {
  mutable x' : int [@mel.as "open"]
}

let f3 (x : t2) =
  x.x' <- x.x' + 3;
  {x' = x.x' + 3}

type t3 = {
    mutable x' : int [@mel.as "in"]
  }

let f3 (x : t3) =
  x.x' <- x.x' + 3;
  {x' = x.x' + 3}

type entry  = {
  x : int  ; [@mel.as "EXACT_MAPPING_TO_JS_LABEL"]
  y : int ; [@mel.as "EXACT_2"]
  z : obj
}
and obj = {
  hi : int ; [@mel.as "hello"]
}


let f4  ({ x; y; z = {hi }}: entry) =
  (x + y + hi) * 2


(* type t5 = { *)
  (* x : int ; *)
  (* y : int [@mel.as "x"]  *)
  (* (* either x or y is a mistake *) *)
(* }    *)

(* let v5  = {x = 3 ; y = 2} *)

type t6 = {
  x : int [@mel.as "x"];
  y : int [@mel.as "y"]
}
(* allow this case *)


external ff : x:int -> h:(_[@mel.as 3]) -> _ = "" [@@mel.obj]
external ff2 : x:int -> h:(_[@mel.as 3]) -> <x:int> Js.t = "" [@@mel.obj]
let u () =
    ignore (ff ~x:3 );
    ff2 ~x:22
