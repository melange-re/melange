module Foo :
  sig
    external makeProps : ?bar:string array -> string = ""[@@mel.obj ]
  end =
  struct external makeProps : ?bar:'bar -> string = ""[@@mel.obj ] end


type 'a arra = 'a array

external
  f0 :
  int -> int -> int array -> unit
  = "f0"
  [@@mel.send.pipe:int]
  [@@mel.variadic]

external
  f1 :
  int -> int -> y:int array -> unit
  = "f1"
  [@@mel.send.pipe:int]
  [@@mel.variadic]

