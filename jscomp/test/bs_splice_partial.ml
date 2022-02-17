

(* let test _g =
    on_exit_slice3 __LINE__ [|1;2;3|]

*)

type t
external on_exit_slice3 :
    int
    -> h:(_ [@bs.as 3])
    -> (_ [@bs.as "xxx"])
    -> int array
    -> unit
    =
    "xx"    [@@bs.send.pipe: t] [@@bs.splice]




 let test g =
    on_exit_slice3 __LINE__ [|1;2;3|] g




external hi : int array -> int option = "hi"
    [@@bs.splice] [@@bs.return {null_to_opt}]
    [@@bs.send.pipe:int]


let test_hi x =
    match x |> hi [|1;2;3|] with
    | None -> 1
    | Some y -> Js.log y ; 2


external hi__2 : int array -> int option = "hi__2"
[@@variadic] [@@return nullable ]
[@@bs.send.pipe:int]

let test_hi__2 x =
    match x |> hi__2 [||]with
    | None -> 1
    | Some _ -> 2

type id = int -> int

external cb : string -> int array -> id = "cb"
[@@variadic] [@@bs.send.pipe: int]


type id2 = int -> int [@bs]
external cb2 : string -> int array -> id2 = "cb2"
[@@variadic] [@@bs.send.pipe: int]


let test_cb x =
    ignore ((x |> cb "hI" [|1;2;3|] ) 3);
    ignore @@ (cb "hI" [|1;2;3|] x ) 3 ;
    (cb2 "hI" [|1;2;3|] x ) 3 [@bs]


type u = int -> int [@bs]
external v : u = "v" [@@bs.val]

let f  x =
    ignore @@ (v x [@bs])

external fff0 : int -> int -> (_[@bs.as {json|[undefined,undefined]|json}]) -> int = "say"
[@@bs.val]

let testUndefined () =
    fff0 1 2
