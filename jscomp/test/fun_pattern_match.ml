type u  = {x0 : int ; x1 : int ; x2 : int; x3 : int ; x4: int}


let f {x0;x1;x2;x3;x4} v =
    x0 + x1 + x2 + x3 + x4 + v


type b = {a : int; b: int }
let f2 {x0;x1;x2;x3;x4}  {a; b}=
    x0 + x1 + x2 + x3 + x4 + a + b

type binary_op =
  | PLUS
  | MINUS

type rank =
  | Uninitialized
  | Visited
  | Ranked of int


type binary_op_ticker = {
  op : binary_op;
  rhs: ticker;
  lhs: ticker;
}

and ticker_type =
  | Market
  | Binary_op of binary_op_ticker

and ticker = {
   mutable rank: rank;
}

let f3  =
  (fun {rank = lhs; _} {rank = rhs} ->
  (* generate curried version when pattern match against arguments *)
  match lhs, rhs with
  | Ranked x , Ranked y -> Stdlib.compare x y
  | _ -> assert false
  )


let f4
  {rank = lhs; _} {rank = rhs}  =
  match lhs, rhs with
  | Ranked x , Ranked y -> Stdlib.compare x y
  | _ -> assert false

(* #995 test case *)
let rec r = (let rec x = `A r and y = fun () -> x in y);;

let v = let (`A x) = r () in x ();;

Js.log v

;; let handle_tuple x y =
  match x, y with
  | (0,1) -> 2
  | (1,2) -> 3
  | (a,b) as x  -> Js.log x ; a + b
