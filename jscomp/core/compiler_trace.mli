type args = (string * string) list

val enabled : unit -> bool

val with_span :
  ?args:args -> category:string -> name:string -> (unit -> 'a) -> 'a

val instant : ?args:args -> category:string -> name:string -> unit -> unit
