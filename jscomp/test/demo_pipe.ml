type readline
external on :
  ([ `line of string -> unit
   | `close of unit -> unit]
     [@mel.string]) ->
  (readline [@mel.this]) ->
  readline =
  "on" [@@mel.send]
let register rl =
  rl
  |> on (`line (fun  x -> Js.log x ))
  |> on (`close (fun () -> Js.log "finished"))

