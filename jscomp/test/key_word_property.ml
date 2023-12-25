(* [@@@mel.config {flags = [|
  "-bs-package-output"; "es6:."
|]}]
*)
(* FIXME it does not work*)


type t


external default :   t = "default" [@@mel.module "some-es6-module"]
external default2 :   t = "default2" [@@mel.module "some-es6-module"]
let default,default2  = default, default2


external oefault :   t = "default" [@@mel.module "./ome-es6-module"]
external oefault2 :   t = "default2" [@@mel.module "./ome-es6-module"]
let oefault,oefault2  = oefault, oefault2


type window
external window : window = "window"  [@@mel.module "vscode"]

let window = window
let mk window default = [%obj{window; default ; }]
type t_ = { window : int ; default : int }

let mk2 window default = [{window; default ; }]

let des v = [%obj{window = v##window ; default = v##default }]


let case = 3

let test =  [%obj{case ; window = 3}]

external switch : window -> string = "switch" [@@mel.send]

let u () = switch window




  (* 0,0,0,0,0,0,0,0,0,0,0,0,0,0 *)
