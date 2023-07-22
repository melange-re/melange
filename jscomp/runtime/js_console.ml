external log : 'a -> unit = "log" [@@mel.val] [@@mel.scope "console"]
external log2 : 'a -> 'b -> unit = "log" [@@mel.val] [@@mel.scope "console"]

external log3 : 'a -> 'b -> 'c -> unit = "log"
  [@@mel.val] [@@mel.scope "console"]

external log4 : 'a -> 'b -> 'c -> 'd -> unit = "log"
  [@@mel.val] [@@mel.scope "console"]

external logMany : 'a array -> unit = "log"
  [@@mel.val] [@@mel.scope "console"] [@@mel.splice]

external info : 'a -> unit = "info" [@@mel.val] [@@mel.scope "console"]
external info2 : 'a -> 'b -> unit = "info" [@@mel.val] [@@mel.scope "console"]

external info3 : 'a -> 'b -> 'c -> unit = "info"
  [@@mel.val] [@@mel.scope "console"]

external info4 : 'a -> 'b -> 'c -> 'd -> unit = "info"
  [@@mel.val] [@@mel.scope "console"]

external infoMany : 'a array -> unit = "info"
  [@@mel.val] [@@mel.scope "console"] [@@mel.splice]

external warn : 'a -> unit = "warn" [@@mel.val] [@@mel.scope "console"]
external warn2 : 'a -> 'b -> unit = "warn" [@@mel.val] [@@mel.scope "console"]

external warn3 : 'a -> 'b -> 'c -> unit = "warn"
  [@@mel.val] [@@mel.scope "console"]

external warn4 : 'a -> 'b -> 'c -> 'd -> unit = "warn"
  [@@mel.val] [@@mel.scope "console"]

external warnMany : 'a array -> unit = "warn"
  [@@mel.val] [@@mel.scope "console"] [@@mel.splice]

external error : 'a -> unit = "error" [@@mel.val] [@@mel.scope "console"]
external error2 : 'a -> 'b -> unit = "error" [@@mel.val] [@@mel.scope "console"]

external error3 : 'a -> 'b -> 'c -> unit = "error"
  [@@mel.val] [@@mel.scope "console"]

external error4 : 'a -> 'b -> 'c -> 'd -> unit = "error"
  [@@mel.val] [@@mel.scope "console"]

external errorMany : 'a array -> unit = "error"
  [@@mel.val] [@@mel.scope "console"] [@@mel.splice]

external trace : unit -> unit = "trace" [@@mel.val] [@@mel.scope "console"]
external timeStart : string -> unit = "time" [@@mel.val] [@@mel.scope "console"]

external timeEnd : string -> unit = "timeEnd"
  [@@mel.val] [@@mel.scope "console"]
