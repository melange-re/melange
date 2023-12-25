

external f : int -> int = "x"
    (* [@@mel.scope "u"] [@@mel.scope "uuu"] *)
external ff : int -> int = "x"
let h  = f 3
let hh = ff 3
let f x y = x ^ y
