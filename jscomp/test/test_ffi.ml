external log  : 'a -> unit = "console.log"
(** we should also allow js function call from an external js module

*)

external log2 : 'a -> unit = "log" [@@mel.scope "console"]

external log3 : 'a -> unit = "log"
let v u =
  log3 u;
  log2 u;
  log u;
  u
