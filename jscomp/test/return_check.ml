type element
type dom
external getElementById : string -> element option = "getElementById"
[@@mel.send.pipe:dom] [@@mel.return {null_to_opt}]

let test dom =
    let elem = dom |> getElementById "haha"  in
    match elem with
    | None -> 1
    | Some ui -> Js.log ui ; 2

(* external getElementById2 : dom -> string -> element option = ""
[@@mel.return null_to_opt] *)










external get_undefined : int array -> int -> int option = ""
[@@mel.get_index] [@@mel.return undefined_to_opt ]


let f_undefined xs i =
    match get_undefined xs i with
    | None -> assert false
    | Some k -> k


let f_escaped_not xs i =
    let x = get_undefined xs i in
    Js.log "hei" ;
    match x with
    | Some k -> k
    | None -> 1

let f_escaped_1 xs i =
    let x = get_undefined xs i in
    fun () ->
        match x with
        | Some k -> k
        | None -> 1 (* still okay *)

let f_escaped_2 xs i =
    Js.log (get_undefined xs i )


external get_null : int array -> int -> int option = ""
[@@mel.get_index] [@@mel.return  null_to_opt ]


let f_null xs i =
    match get_null xs i with
    | None -> assert false
    | Some k -> k

external get_null_undefined : int array -> int -> int option = ""
[@@mel.get_index] [@@mel.return nullable ]


let f_null_undefined xs i =
    match get_null_undefined xs i with
    | None -> assert false
    | Some k -> k


