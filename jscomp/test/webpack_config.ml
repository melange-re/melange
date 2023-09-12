module type Config = sig
  val configx : Js.Json.t
end
module WebpackConfig: Config = struct
  external configx : Js.Json.t = "../../../webpack.config.js" [@@mel.module]
end

module WebpackDevMiddlewareConfig: Config = struct
  external configx : Js.Json.t = "../../../webpack.middleware.config.js" [@@mel.module]
end

external configX : unit ->  Js.Json.t = "configX"
[@@mel.module  "../../../webpack.middleware.config.js"]


let configX = configX
module U  : sig
  val configX : unit -> Js.Json.t
end = struct
    external configX : unit -> Js.Json.t =  "configX"
    [@@mel.module "../../../webpack.config.js" ]

end
 external hey : unit -> unit  = "xx" [@@mel.module "List"]
module A = struct
  external ff : unit -> unit = "ff" [@@mel.module "reactX", "List" ]
  external ff2 : unit -> unit = "ff2" [@@mel.module "reactX", "List" ]
end
module B = struct
  external ff : unit -> unit = "ff" [@@mel.module "reactV", "List"]
  external ff2 : unit -> unit = "ff2" [@@mel.module "reactV", "List"]
end

let f ()   = A.ff , A.ff2,  B.ff, B.ff2
 ;; hey ()

 ;; (List.length [1;2] , List.length []) |. ignore

type t
external ff : unit -> t = "ff" [@@mel.module "./local"]
