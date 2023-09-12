external join : string array -> string = "join"
[@@mel.module "path"]  [@@mel.splice]

let () = Js.log (join [| "." ; __MODULE__  |])


(* let f x = join x *)
