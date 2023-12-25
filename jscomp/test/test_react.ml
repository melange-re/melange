(** TODO: binding -- document.getElementById -- to mount node *)

type html_element

class type document =
  object
    method getElementById : string -> html_element
  end[@u]

type doc = document Js.t
external doc :  doc  = "doc"

class type con =
  object
    method log : 'a -> unit
  end[@u]

type console = con Js.t
external console : console  = "console"

let v = console##log "hey";;
let u = console
let v = doc##getElementById "haha"

external log : 'a -> unit = "console.log"
let v = log 32
type t
type element
external document :  t = "document"
external getElementById : t -> string -> element = "getElementById" [@@mel.send ]


type config
type component
external config :
      ?display_name:string ->
        render:(unit -> component) -> unit ->
          config = "" [@@mel.obj ]

type attrs
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

type component_class
external createClass :
      config -> component_class = "createClass"
        [@@mel.module "react"]

external render : component_class -> element -> unit = "render"
    [@@mel.module "react-dom"] (* TODO: error checking -- attributes todo*)
;;

render (
     createClass (
     (config
       ~render:(fun _ ->
         div vdom
              ~attrs:(attrs ~alt:"pic" ())
              [|
                h1 vdom [| str "hello react"|];
                h2 vdom [| str "type safe!" |];
                h3 vdom [| str "type safe!" |];
              |]
               )
        ()))) (getElementById document  "hi")



;;

let u = 33

external make: unit -> unit = "xxx" [@@mel.module]
external make2: unit -> unit = "xx" [@@mel.module "xxx"]
external make3: unit -> unit = "xxx" [@@mel.module "xxx"]
external make4: unit -> unit = "x" [@@mel.module "a/b/c"]
external make5: unit -> unit = "y" [@@mel.module "a/b/c"]

external make6: unit -> unit = "x" [@@mel.module "b/c"]
external make7: unit -> unit = "y" [@@mel.module "b/c"]

external make8: unit -> unit = "x" [@@mel.module "c"]
external make9: unit -> unit = "y" [@@mel.module "c"]

let f () =
   make ();
   make2 ();
   make3 ();
   make4 ();
   make5 ();
   make6 ();
   make7 ();
   make8 ();
   make9 ()
