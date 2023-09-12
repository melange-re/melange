

let x = true [@@mel.inline]

let f = "hello" [@@mel.inline]

let f1 = {j|a|j} [@@mel.inline]

let f2  = {j|中文|j} [@@mel.inline]
(* Do we need fix
  let f2 : string = blabla
*)

module N : sig
  val f3 : string [@@mel.inline {j|中文|j} ]
end = struct
  let f3 = {j|中文|j} [@@mel.inline]
end

module N1 = functor () -> struct
  let f4 = {j|中文|j} [@@mel.inline]
  let xx = 3e-6 [@@mel.inline]
  let xx0 = 3e-6
end
let h = f

let hh = f ^ f

open N

module H = N1 ()
open H
let a,b,c,d,e =
  f,f1,f2,f3,f4

let f5 = true [@@mel.inline]

let f6 = 1 [@@mel.inline]

let f7 = 1L [@@mel.inline]

let f9 = 100L [@@mel.inline]

let v = 100L [@@mel.inline]
let u = 1L [@@mel.inline]

let () = Js.log (xx,xx0)
