module Foo :
  sig
    external makeProps : ?bar:string array -> string = ""[@@mel.obj ]
  end =
  struct external makeProps : ?bar:'bar -> string = ""[@@mel.obj ] end


type 'a arra = 'a array

external
  f0 :
  int -> int -> int array -> (int [@mel.this]) -> unit
  = "f0"
  [@@mel.send]
  [@@mel.variadic]

external
  f1 :
  int -> int -> y:int array -> (int [@mel.this]) -> unit
  = "f1"
  [@@mel.send]
  [@@mel.variadic]

