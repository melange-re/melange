type resp
external set_okay :
     resp -> (_ [@mel.as 200] ) -> unit = "statusCode" [@@mel.set]

external set_hi :
    resp -> (_ [@mel.as "hi"] ) -> unit =
    "hi"
[@@mel.set]


(* external ff_json  : hi:int -> lo:(_[@mel.as {json|null|json}]) -> _ = "" [@@mel.obj] *)

(* let uu : < hi : int; lo : string > Js.t = ff_json ~hi:3 *)

let f resp =
    set_okay resp ;
    set_hi resp
