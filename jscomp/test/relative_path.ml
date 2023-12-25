
(* include (struct *)
external foo: int = "foo"
[@@mel.module "./File.js"]
(* end : sig val foo : int end ) *)

external foo2: int -> int = "foo2"
[@@mel.module "./File.js"]

let bar = foo
