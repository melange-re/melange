(* let test _g =
    on_exit_slice3 __LINE__ [|1;2;3|]

*)

type t
external on_exit_slice3 :
    int
    -> h:(_ [@mel.as 3])
    -> (_ [@mel.as "xxx"])
    -> int array
    -> unit
    =
    "xx"    [@@mel.send.pipe: t] [@@mel.variadic]




 let test g =
    on_exit_slice3 __LINE__ [|1;2;3|] g




external hi : int array -> int option = "hi"
    [@@mel.variadic] [@@mel.return {null_to_opt}]
    [@@mel.send.pipe:int]


let test_hi x =
    match x |> hi [|1;2;3|] with
    | None -> 1
    | Some y -> Js.log y ; 2


external hi__2 : int array -> int option = "hi__2"
[@@mel.variadic] [@@mel.return nullable ]
[@@mel.send.pipe:int]

let test_hi__2 x =
    match x |> hi__2 [||]with
    | None -> 1
    | Some _ -> 2

type id = int -> int

external cb : string -> int array -> id = "cb"
[@@mel.variadic] [@@mel.send.pipe: int]


type id2 = int -> int [@u]
external cb2 : string -> int array -> id2 = "cb2"
[@@mel.variadic] [@@mel.send.pipe: int]


let test_cb x =
    ignore ((x |> cb "hI" [|1;2;3|] ) 3);
    ignore @@ (cb "hI" [|1;2;3|] x ) 3 ;
    (cb2 "hI" [|1;2;3|] x ) 3 [@u]


type u = int -> int [@u]
external v : u = "v"

let f  x =
    ignore @@ (v x [@u])

external fff0 : int -> int -> (_[@mel.as {json|[undefined,undefined]|json}]) -> int = "say"


let testUndefined () =
    fff0 1 2
