(** ES6 Set API *)

type 'a t

external make : unit -> 'a t = "Set" [@@mel.new]
external fromArray : 'a array -> 'a t = "Set" [@@mel.new]
external toArray : 'a t -> 'a array = "Array.from"
external size : 'a t -> int = "size" [@@mel.get]
external add : value:'a -> 'a t = "add" [@@mel.send.pipe: 'a t]
external clear : 'a t -> unit = "clear" [@@mel.send]
external delete : value:'a -> bool = "delete" [@@mel.send.pipe: 'a t]

(* commented out until Melange has a plan for iterators
   external entries : 'a t -> 'a array_iter = "entries" [@@mel.send] (* ES2015 *) *)

external forEach : f:('a -> unit) -> unit = "forEach" [@@mel.send.pipe: 'a t]
external has : value:'a -> bool = "has" [@@mel.send.pipe: 'a t]

(*
 external difference : other:'a t -> 'a t = "difference" [@@mel.send.pipe: 'a t]

 external intersection : other:'a t -> 'a t = "intersection"
   [@@mel.send.pipe: 'a t]

   external isDisjointFrom : other:'a t -> bool = "isDisjointFrom"
   [@@mel.send.pipe: 'a t]

   external isSubsetOf : other:'a t -> bool = "isSubsetOf" [@@mel.send.pipe: 'a t]

   external isSupersetOf : other:'a t -> bool = "isSupersetOf"
   [@@mel.send.pipe: 'a t]

   external symmetricDifference : other:'a t -> 'a t = "symmetricDifference"
   [@@mel.send.pipe: 'a t]

   external union : other:'a t -> 'a t = "union" [@@mel.send.pipe: 'a t] *)
