val h1 : < p : 'a; .. > Js.t -> 'a
val h2 : < m : (int -> int -> 'a [@u]); .. > Js.t -> 'a
val h3 : < hi : int -> int -> 'a; .. > Js.t -> 'a
val h4 : < hi : (int -> int -> 'a [@mel.meth]); .. > Js.t -> 'a

val h5 : < hi : int [@mel.set]; .. > Js.t -> unit
(* The inferred type is
val h5 : < hi#= : (int -> unit [@mel.meth]); .. > -> unit
We should propose the rescript syntax:
{ mutable "hi" : int  }
*)
val h6 : < p : 'a; .. > -> 'a
val h7 : < m : (int -> int -> 'a [@u]); .. > -> 'a
val h8 : < hi : int -> int -> 'a; .. > -> 'a

val chain_g : < x : < y : < z : int > > > -> int
