type t

external getItem : t -> string -> string option = "getItem"
  [@@mel.send] [@@mel.return null_to_opt]

external setItem : t -> string -> string -> unit = "setItem" [@@mel.send]
external removeItem : t -> string -> unit = "removeItem" [@@mel.send]
external clear : t -> unit = "clear" [@@mel.send]

external key : t -> int -> string option = "key"
  [@@mel.send] [@@mel.return null_to_opt]

external length : t -> int = "length" [@@mel.get]
external localStorage : t = "localStorage" [@@mel.val]
external sessionStorage : t = "sessionStorage" [@@mel.val]
