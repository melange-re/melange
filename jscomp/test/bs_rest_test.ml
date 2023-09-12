[%%mel.raw{|
function x(v){return [v]}
|}]

external f : 'a -> 'a array  [@u] = "x"

let u = f "3" [@u]
let v = f 3 [@u]


include (struct
external xxx :  'a -> 'a array  [@u] = "x"
end : sig
  val xxx : 'a -> 'a array  [@u]
end)


let u = xxx 3 [@u]
let xx = xxx "3" [@u]
(** Do we need both [bs.val] and [bs.call]* instead of just one [bs.val] *)
