type args = (string * string) list

let enabled () = false
let with_span ?args:_ ~category:_ ~name:_ f = f ()
let instant ?args:_ ~category:_ ~name:_ () = ()
