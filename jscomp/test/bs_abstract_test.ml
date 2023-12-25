[@@@mel.config {flags = [|"-w";"+unused-type-declaration";"-warn-error"; "A"|]}]

type[@ocaml.warning "-69"] 'a linked_list =
  {
    hd : 'a ;
    mutable tl : 'a linked_list Js.null
  }
  [@@deriving jsProperties, getSet]



let v = linked_list ~hd:3 ~tl:Js.null

;; tlSet v (Js.Null.return v)

type[@warning "-unused-type-declaration"] t = int -> int -> bool [@u]
and x = {
  k : t;
  y : string
} [@@deriving jsProperties, getSet]


let x0 k = x ~k ~y:"xx"
let x1 k = x ~k ~y:"xx"

let f = x ~k:(fun[@u] x y -> x = y) ~y:"x"

type[@ocaml.warning "-69"] u = {
  x : int ;
  y0 : int -> int;
  y1 : int -> int -> int
} [@@deriving jsProperties, getSet]


let uf u =  u |. y0Get 1
let uf1 u = u |. y1Get 1
let uf2 u = u |. y1Get 1 2

type[@ocaml.warning "-69"] u1 = {
  x : int;
  yyyy : (int -> int [@u]);
  yyyy1 : (int -> int -> int  [@u]);
  yyyy2 : (int -> int) option  [@mel.optional]
} [@@deriving jsProperties, getSet]

let uff f =
  (f |. yyyyGet) 1 [@u]

let uff2 f =
  (f |. yyyy1Get) 1 2 [@u]

let uff3 f =
  match f |. yyyy2Get with
  | None -> 0
  | Some x  -> x 0



type[@ocaml.warning "-69"] u3 = {
  x : int;
  yyyy : (int -> int [@u]);
  yyyy1 : (int -> int -> int  [@u]);
  yyyy2 : (int -> int) option  [@mel.optional]
} [@@deriving jsProperties, getSet { light} ]


let fx v = v |. x
