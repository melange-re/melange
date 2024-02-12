type 'a t

type 'a value = {
  done_ : bool Js_nullable.t; [@mel.as "done"]
  value : 'a Js_nullable.t;
}

external next : 'a t -> 'a value = "next" [@@mel.send]
external toArray : 'a t -> 'a array = "Array.from"
external toArrayWithMapper : 'a t -> f:('a -> 'b) -> 'b array = "Array.from"