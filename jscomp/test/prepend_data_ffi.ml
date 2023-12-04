type config1_expect = <  v : int >  Js.t
external config1 : stdio:(_ [@mel.as "inherit"]) -> v:int -> unit ->  _  = "" [@@mel.obj]

let v1 : config1_expect = config1 ~v:3 ()

type config2_expect = <  v : int >  Js.t

external config2 : stdio:(_ [@mel.as 1 ]) -> v:int -> unit ->  _  = "" [@@mel.obj]
let v2 : config2_expect = config2 ~v:2 ()

(* external config3 : stdio:(_ [@mel.as {json|null|json}]) -> v:int -> unit ->  _  = "" [@@mel.obj] *)
(* let v_3 = config3 ~v:33 () *)

external on_exit :
    (_ [@mel.as "exit"]) ->
    (int -> string) ->
    unit = "process.on"


let () =
    on_exit (fun exit_code -> string_of_int exit_code)


external on_exit_int :
    (_ [@mel.as 1]) ->
    (int -> unit) ->
    unit = "process.on"


let () =
    on_exit_int (fun _ -> ())

external on_exit3 :     (int -> string ) -> (_ [@mel.as "exit"]) -> unit =
    "process.on"


let ()  = on_exit3 (fun i -> string_of_int i )

external on_exit4 :     (int -> string ) -> (_ [@mel.as 1]) -> unit =
    "process.on"



let () =
    on_exit4 (fun i -> string_of_int i)

external on_exit_slice :
    int -> (_ [@mel.as 3]) -> (_ [@mel.as "xxx"]) -> string array -> unit =
    "xx"    [@@mel.variadic]

let () =
    on_exit_slice 3 [|"a";"b"|]



type t

external on_exit_slice1 :
    int -> int array -> unit = "xx" [@@mel.send.pipe: t]

external on_exit_slice2 :
    int
    -> (_ [@mel.as 3])
    -> (_ [@mel.as "xxx"]) -> int array -> unit =
    "xx"    [@@mel.send.pipe: t]

external on_exit_slice3 :
    int
    -> (_ [@mel.as 3])
    -> (_ [@mel.as "xxx"])
    -> int array
    -> unit
    =
    "xx"    [@@mel.send.pipe: t] [@@mel.variadic]

external on_exit_slice4 :
    int
    -> (_ [@mel.as 3])
    -> (_ [@mel.as "xxx"])
    -> ([`a|`b|`c] [@mel.int])
    -> ([`a|`b|`c] )
    -> int array
    -> unit
    =
    "xx" [@@mel.send.pipe: t] [@@mel.variadic]


external on_exit_slice5 :
    int
    -> (_ [@mel.as 3])
    -> (_ [@mel.as {json|true|json}])
    -> (_ [@mel.as {json|false|json}])
    -> (_ [@mel.as {json|"你好"|json}])
    -> (_ [@mel.as {json| ["你好",1,2,3] |json}])
    -> (_ [@mel.as {json| [{ "arr" : ["你好",1,2,3], "encoding" : "utf8"}] |json}])
    -> (_ [@mel.as {json| [{ "arr" : ["你好",1,2,3], "encoding" : "utf8"}] |json}])
    -> (_ [@mel.as "xxx"])
    -> ([`a|`b|`c] [@mel.int])
    -> (_ [@mel.as "yyy"])
    -> ([`a|`b|`c] )
    -> int array
    -> unit
    =
    "xx" [@@mel.send.pipe: t] [@@mel.variadic]


(**
 TODO: bs.send conflicts with bs.val: better error message
*)
let f (x : t) =
    x |> on_exit_slice1 __LINE__ [|1;2;3|];
    x |> on_exit_slice2 __LINE__ [|1;2;3|];
    x |> on_exit_slice3 __LINE__ [|1;2;3|];
    x |> on_exit_slice4 __LINE__ `a `b [|1;2;3;4;5|];
    x |> on_exit_slice5 __LINE__ `a `b [|1;2;3;4;5|]

external process_on_exit : (_ [@mel.as "exit"]) -> (int -> unit) -> unit =
  "process.on"

let () =
    process_on_exit (fun exit_code ->
        Js.log( "error code: " ^ string_of_int exit_code ))


type process

external on_exit :  (_ [@mel.as "exit"]) -> (int -> unit) -> unit =
    "on" [@@mel.send.pipe: process]
let register (p : process) =
        p |> on_exit (fun i -> Js.log i )


external io_config :
    stdio:( _ [@mel.as "inherit"]) -> cwd:string -> unit -> _  = "" [@@mel.obj]

let config = io_config ~cwd:"." ()
