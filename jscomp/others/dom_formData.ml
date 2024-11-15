(* Provides a way to easily construct a set of key/value pairs representing form fields and their values, which can then be easily sent using the XMLHttpRequest.send() method. It uses the same format a form would use if the encoding type were set to "multipart/form-data". *)

type t
type file
type blob
type entryValue

external make : unit -> t = "FormData" [@@mel.new]

external append : name:string -> value:string -> unit = "append"
[@@mel.send.pipe: t]

external delete : name:string -> unit = "delete" [@@mel.send.pipe: t]

external get : name:string -> entryValue option = "get"
[@@mel.send.pipe: t] [@@mel.return null_to_opt]

external getAll : name:string -> entryValue array = "getAll"
[@@mel.send.pipe: t]

external set : name:string -> value:string -> unit = "set" [@@mel.send.pipe: t]
external has : name:string -> bool = "has" [@@mel.send.pipe: t]
external keys : t -> string Js.Iterator.t = "keys" [@@mel.send]
external values : t -> entryValue Js.Iterator.t = "values" [@@mel.send]

external appendObject :
  name:string -> value:< .. > Js.t -> ?filename:string -> unit = "append"
[@@mel.send.pipe: t]

external appendBlob : name:string -> value:blob -> ?filename:string -> unit
  = "append"
[@@mel.send.pipe: t]

external appendFile : name:string -> value:file -> ?filename:string -> unit
  = "append"
[@@mel.send.pipe: t]

external setObject :
  name:string -> value:< .. > Js.t -> ?filename:string -> unit = "set"
[@@mel.send.pipe: t]

external setBlob : name:string -> value:blob -> ?filename:string -> unit = "set"
[@@mel.send.pipe: t]

external setFile : name:string -> value:file -> ?filename:string -> unit = "set"
[@@mel.send.pipe: t]

external entries : t -> (string * entryValue) Js.Iterator.t = "entries"
[@@mel.send]
