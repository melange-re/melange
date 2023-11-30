let rec fib = function
  | 1 | 2 -> 1
  | n -> fib (n - 1 )  + fib (n - 2)
(** Imperative style *)
let sum n =
    let v  = ref 0 in
    for i = 0 to n do
       v := !v + i
    done;
    !v
(** List map *)
type 'a list =
  | Nil
  | Cons of 'a * 'a list

let rec map f = function
  | Nil -> Nil
  | Cons (x,xs) ->  Cons (f x, map f xs)

(** Test curry and uncurry calling convention *)
let test_curry x  y =  x + y
let f = test_curry 32

(** Create a typed binding for react *)
type t
type element
external document :  t = "document"
external getElementById : t -> string -> element = "getElementById" [@@mel.send ]

(** Phantom types *)
type config
type component
type attrs
type component_class

external config :
      ?display_name:string ->
        render:(unit -> component) -> unit ->
          config = "" [@@mel.obj ] (** make a json object *)
external attrs:
        ?alt: string ->
        ?autoPlay: bool ->
          unit -> attrs = "" [@@mel.obj]
external str : string -> component = "%identity"

type vdom
external vdom : vdom = "DOM" [@@mel.module "react"]


(* FIXME: investigate
   cases:
   {[
     [@@mel.module "package1" "same_name"]
     [@@mel.module "package2" "same_name"]
   ]}
   {[
     [@@mel.module "package" "name1"]
     [@@mel.module "package" "name2"]
   ]}
*)
external h1 : vdom -> ?attrs:attrs -> component array  -> component = "h1"
    [@@mel.send]  [@@mel.variadic]
external h2 : vdom -> ?attrs:attrs -> component array  -> component = "h2"
    [@@mel.send]  [@@mel.variadic]

external h3 : vdom ->  ?attrs:attrs -> component array  -> component = "h3"
    [@@mel.send]  [@@mel.variadic]

external h4 : vdom ->  ?attrs:attrs -> component array  -> component = "h4"
    [@@mel.send]  [@@mel.variadic]

external div : vdom -> ?attrs:attrs -> component array ->  component = "div"
    [@@mel.send]  [@@mel.variadic]

external createClass :
      config -> component_class = "createClass"
        [@@mel.module "react"]
external render : component_class -> element -> unit = "render"
    [@@mel.module "react-dom"]
;;
(** Do the rendering *)
render (
     createClass (
     (config
       ~render:(fun _ ->
         div vdom
              ~attrs:(attrs ~alt:"pic" ())
              [|
                h1 vdom [| str "hello react"|];
                h2 vdom [| str "type safe!" |];
  |]
               )
        ()))) (getElementById document "hi")
