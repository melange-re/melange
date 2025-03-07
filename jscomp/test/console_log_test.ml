external min_int : int -> int -> int = "min"  [@@mel.scope "Math"]

(* ATTENTION: only built-in runtime would simplify it
   as
   {[
     var min_int = Math.min
   ]}
   otherwise it has to be expanded as
   {[
     var min_int = function(x,y){
       return Math.min(x,y)
     }
   ]}
   There are other things like [@mel.send] which does not like eta reduction

*)
let min_int = min_int

type t
external say : int -> (t [@mel.this]) -> int = "say"[@@mel.send]

let say = say

[@@@warning "-102"]
let v = Stdlib.compare
