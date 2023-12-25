val x : bool

val f : string [@@mel.inline "hello"]

val f1 :
  string
  [@@mel.inline {j|a|j}]

val f2 :
  string
  [@@mel.inline {j|中文|j}]

module N : sig
  val f3 : string [@@mel.inline {j|中文|j} ]
end


module N1 : functor () -> sig
  val f4 : string
  [@@mel.inline {j|中文|j}]
  val xx : float [@@mel.inline 3e-6]
end

val h : string
val hh : string

val f5 : bool [@@mel.inline true ]

val f6 : int [@@mel.inline 1]

(* val f7 : bool [@@mel.inline 1L] *)

val v : int64 [@@mel.inline 100L]
val u : int64 [@@mel.inline 1L ]
