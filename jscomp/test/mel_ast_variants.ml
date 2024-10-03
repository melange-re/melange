type t = A | B | C | D | E

let toEnum x =
  match x with
  | A -> 0
  | B -> 1
  | C -> 2
  | D -> 3
  | E -> 4

let toString x =
  match x with
  | A -> "A"
  | B -> "B"
  | C -> "C"
  | D -> "D"
  | E -> "E"

let bar x =
  match x with
  | A -> 10
  | B | C | D -> 0
  | E -> 10

type b = True | False

let and_ x y =
  match (x, y) with
  | (True, False) -> False
  | (False, True) -> False
  | (False, False) -> False
  | (True, True) -> True

let id x =
  match x with
  | True -> True
  | False -> False

let not_ x =
  match x with
  | True -> False
  | False -> True

type state =
  | Empty
  | Int1 of int
  | Int2 of int
let st state =
  match state with
  | Empty -> 0
  | Int2 intValue
  | Int1 intValue -> 23

type show = No | After of int | Yes

let showToJs x =
  match x with
  | Yes | After _ -> true
  | No -> false

let third l =
  match l with
  | [1, 2, 3] -> true
  | _ -> false

type lst = Empty | Cons of int * lst

let third2 l =
  match l with
  | Cons(1, Cons(2, Cons(3, Empty))) -> true
  | _ -> false

module CustomizeTags = struct
  type t =
    | A [@mel.as "dd"]
    | B [@mel.as 12]
    | C
    | D of int [@mel.as "qq"]
    | E of int [@mel.as 42]
    | F of string

  let foo x =
    match x with
    | A -> 1
    | B -> 2
    | C -> 3
    | D(_) -> 4
    | E(_) -> 5
    | F(_) -> 6

  let a = A
  let b = B
  let c = C
  let d = D(42)
  let e = E(0)
end
