external config :
  x : ('self_type -> 'x [@mel.this]) ->
  say :('self_type  -> 'x -> 'say [@mel.this]) ->
  (<
     x : unit -> 'x [@mel.meth];
     say : 'x -> 'say [@mel.meth]
  > Js.t as 'self_type)  = "" [@@mel.obj]


let v =
  let x = 3 in
  config
    ~x:(fun [@mel.this] _ -> x )
    ~say:(fun [@mel.this] self x -> self##x () + x)


(**
let x = 3 in
object (self : 'self_type)
   method x () = x
   method say x = self##x + x
end [@u]
*)
let u =
  v##x () + v##say 3


(* local variables: *)
(* compile-command: "bsc.exe -I ../runtime -drawlambda  unsafe_obj_external.ml" *)
(* end: *)
