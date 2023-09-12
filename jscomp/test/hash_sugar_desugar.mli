

val h1 : < p : 'a; .. > -> 'a
val h2 : < m : (int -> int -> 'a [@u]); .. > -> 'a
val h3 : < hi : int -> int -> 'a; .. > -> 'a
val h4 : < hi : (int -> int -> 'a [@mel.meth]); .. > -> 'a

val h5 : < hi : int [@mel.set]; .. > -> unit
(* The inferred type is
val h5 : < hi#= : (int -> unit [@mel.meth]); .. > -> unit
We should propose the rescript syntax:
{ mutable "hi" : int  }
*)
val h6 : < p : 'a; .. > -> 'a
val h7 : < m : (int -> int -> 'a [@u]); .. > -> 'a
val h8 : < hi : int -> int -> 'a; .. > -> 'a

val chain_g : < x : < y : < z : int > > > -> int
