
(*  should give a warning on unused attribute..   [@@mel.xx] *)


type readline
external on :
  ([ `line of (string -> unit [@u])
   | `close of (unit -> unit [@u])]
     [@mel.string]) ->
  (readline as 'self [@mel.this]) ->
  'self =
  "on" [@@mel.send]
let u rl =
  rl
  |> on (`line (fun [@u] x -> Js.log x ))
  |> on (`close (fun [@u] () -> Js.log "finished"))




external send :
  string ->
  (< hi : int > Js.t as 'self [@mel.this]) ->
  'self = "send" [@@mel.send]


let xx h : int  =
  h
  |> send   "x"
  |> (fun x -> x ## hi)

let yy h =
  h
  |> send "x"
