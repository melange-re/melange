(** JavaScript BigInt API *)

type t

external make : 'a -> t = "BigInt"

external asInt32 : (_[@mel.as {json|32|json}]) -> t -> t = "asIntN"
[@@mel.scope "BigInt"]

external asInt64 : (_[@mel.as {json|64|json}]) -> t -> t = "asIntN"
[@@mel.scope "BigInt"]

external asIntN : precision:int -> t -> t = "asIntN" [@@mel.scope "BigInt"]
external asUintN : precision:int -> t -> t = "asUintN" [@@mel.scope "BigInt"]

type toLocaleStringOptions = { style : string; currency : string }

external toLocaleString :
  locale:string -> ?options:toLocaleStringOptions -> string = "toLocaleString"
[@@mel.send.pipe: t]

external toString : t -> string = "toLocaleString" [@@mel.send]
