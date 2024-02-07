type 'a t
type 'a value = { done_ : bool; value : 'a option }

external next : 'a t -> 'a value = "next" [@@mel.send]
external toArray : 'a t -> 'a array = "Array.from"
external toArrayWithMapper : 'a t -> ('a -> 'b) -> 'b array = "Array.from"
