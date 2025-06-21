

external make_config : length:int -> width:int -> unit = ""
    [@@mel.obj]

external make_config :  length:'a -> width:int -> unit = ""
    [@@mel.obj]
(** Note that
    {[ 'a . length: 'a -> width:int -> unit
    ]} is a syntax error -- check where it is allowed
*)



external opt_make :
  length: int -> ?width:int -> (_ as 'event [@ocaml.warning "-unused-type-declaration"])  =
  "" [@@mel.obj]


external ff :
    hi:int ->
    lo:(_ [@mel.as 3]) ->
    lo2:(_ [@mel.as {json|{hi:-3 }|json}]) ->
    lo3:(_ [@mel.as -1]) ->
    lo4:(_ [@mel.as {json|-3|json}]) ->
     _ = "" [@@mel.obj]

let u = ff ~hi:2

external f : int -> int = "f" [@@genType.import "hh"]
