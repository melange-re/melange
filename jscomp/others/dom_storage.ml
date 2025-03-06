type t

external getItem : string -> (t[@mel.this]) -> string option = "getItem"
[@@mel.send] [@@mel.return null_to_opt]

external setItem : string -> string -> (t[@mel.this]) -> unit = "setItem"
[@@mel.send]

external removeItem : string -> (t[@mel.this]) -> unit = "removeItem"
[@@mel.send]

external clear : t -> unit = "clear" [@@mel.send]

external key : int -> (t[@mel.this]) -> string option = "key"
[@@mel.send] [@@mel.return null_to_opt]

external length : t -> int = "length" [@@mel.get]
external localStorage : t = "localStorage"
external sessionStorage : t = "sessionStorage"
