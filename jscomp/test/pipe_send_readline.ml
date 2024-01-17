(*  should give a warning on unused attribute..   [@@mel.xx] *)


type readline
external on :
  ([ `line of (string -> unit [@u])
   | `close of (unit -> unit [@u0])]
     [@mel.string]) ->
  'self =
  "on" [@@mel.send.pipe:readline as 'self]
let u rl =
  rl
  |> on (`line (fun [@u] x -> Js.log x ))
  |> on (`close (fun [@u0] () -> Js.log "finished"))




external send : string -> 'self   = "send" [@@mel.send.pipe: < hi : int > Js.t as 'self]


let xx h : int  =
  h
  |> send   "x"
  |> (fun x -> x ## hi)

let yy h =
  h
  |> send "x"
