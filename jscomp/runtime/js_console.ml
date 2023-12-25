external log : 'a -> unit = "log" [@@mel.scope "console"]
external log2 : 'a -> 'b -> unit = "log" [@@mel.scope "console"]
external log3 : 'a -> 'b -> 'c -> unit = "log" [@@mel.scope "console"]
external log4 : 'a -> 'b -> 'c -> 'd -> unit = "log" [@@mel.scope "console"]

external logMany : 'a array -> unit = "log"
[@@mel.scope "console"] [@@mel.variadic]

external info : 'a -> unit = "info" [@@mel.scope "console"]
external info2 : 'a -> 'b -> unit = "info" [@@mel.scope "console"]
external info3 : 'a -> 'b -> 'c -> unit = "info" [@@mel.scope "console"]
external info4 : 'a -> 'b -> 'c -> 'd -> unit = "info" [@@mel.scope "console"]

external infoMany : 'a array -> unit = "info"
[@@mel.scope "console"] [@@mel.variadic]

external warn : 'a -> unit = "warn" [@@mel.scope "console"]
external warn2 : 'a -> 'b -> unit = "warn" [@@mel.scope "console"]
external warn3 : 'a -> 'b -> 'c -> unit = "warn" [@@mel.scope "console"]
external warn4 : 'a -> 'b -> 'c -> 'd -> unit = "warn" [@@mel.scope "console"]

external warnMany : 'a array -> unit = "warn"
[@@mel.scope "console"] [@@mel.variadic]

external error : 'a -> unit = "error" [@@mel.scope "console"]
external error2 : 'a -> 'b -> unit = "error" [@@mel.scope "console"]
external error3 : 'a -> 'b -> 'c -> unit = "error" [@@mel.scope "console"]
external error4 : 'a -> 'b -> 'c -> 'd -> unit = "error" [@@mel.scope "console"]

external errorMany : 'a array -> unit = "error"
[@@mel.scope "console"] [@@mel.variadic]

external trace : unit -> unit = "trace" [@@mel.scope "console"]
external timeStart : string -> unit = "time" [@@mel.scope "console"]
external timeEnd : string -> unit = "timeEnd" [@@mel.scope "console"]
