
let u = fun [@u] x y -> x + y

let h = u 1 2 [@u]

type u = < v : int ; y : int >
type ('a,'b) xx =
  (< case : (int ->  (int -> 'a [@u]) [@u]); .. >   as 'b)
type ('a,'b) xx_uncurry =
  (< case : int ->  (int -> 'a ); .. >  ) as 'b

type yy_uncurry = < x : int >
type yy = < x : int >
type number = float

class type date =
  object
    method toDateString : unit -> string
    method getTime : unit ->  number
    method setMilliseconds : number ->  number
    method setSeconds : number -> number
    method setSeconds__2 :  number -> number ->  number
    method setUTCFullYear__3 : number -> number ->   number -> number
    method toUTCString : unit -> string
    method toISOString : unit -> string
    method toJSON__ : unit -> string
    method toJSON__1 : 'a -> string
  end


let max2 : float -> float -> float [@u] =
  fun [@u] x y ->   x +. y

let hh = max2 1. 2. [@u]

external des : string -> (unit -> unit [@mel.uncurry]) -> unit = "des"

let f x =
  des x (fun () -> Js.log "hei")
