external xx : string -> unit = "xx" [@@mel.module "x", "X"]

type param

external executeCommands : string -> param array -> unit = "executeCommands"
[@@mel.scope "commands"] [@@mel.module "vscode"][@@mel.variadic]

external env : string Js.Dict.t = "env" [@@mel.scope "process"]

let f a b c  =
  executeCommands "hi"  [|a;b;c|];
  env

external hi : string = "hi"
[@@mel.module "z"] [@@mel.scope "a0", "a1", "a2"]
external ho : string = "ho"
 [@@mel.scope "a0","a1","a2"]
external imul : int -> int -> int = "imul"
 [@@mel.scope "Math"]
let f2 ()  =
  hi , ho, imul 1 2


type buffer
external makeBuffer : int -> buffer = "Buffer"
[@@mel.new] [@@mel.scope "global"]

external makeBuffer1 : int -> buffer = "Buffer"
[@@mel.new] [@@mel.scope "global", "a0","a1","a2"]

external makeBuffer2 : int -> buffer = "Buffer"
[@@mel.new] [@@mel.scope "global", "a0","a1","a2"] [@@mel.module "X","ZZ"]

external makeBuffer3 : int -> buffer = "makeBuffer3"
[@@mel.new] [@@mel.scope "global", "a0","a1","a2"] [@@mel.module "X", "Z"]

external max : float -> float -> float = "max"
  [@@mel.scope "Math"]
(* TODO: `bs.val` is not necessary, by default is good?
*)

type t
external create : unit -> t = "create" [@@mel.scope "mat4"] [@@mel.module "gl-matrix"]


(* external scope_f : t -> int = "" [@@mel.get] [@@mel.scope "hi"]*)

external getMockFn1 : t -> int -> string = ""
[@@mel.get_index] [@@mel.scope "a0"]

external getMockFn2 : t -> int -> string = ""
[@@mel.get_index] [@@mel.scope "a0", "a1"]

external getMockFn3 : t -> int -> string = ""
[@@mel.get_index] [@@mel.scope "a0", "a1", "a2"]

external setMocFn1 : t -> int -> string -> unit = ""
[@@mel.set_index] [@@mel.scope "a0"]

external setMocFn2 : t -> int -> string -> unit = ""
[@@mel.set_index] [@@mel.scope "a0", "a1"]

external setMocFn3 : t -> int -> string -> unit = ""
[@@mel.set_index] [@@mel.scope "a0", "a1", "a2"]

external getX1 : t -> int = "getX1"
[@@mel.get] [@@mel.scope "a0"]

external getX2 : t -> int = "getX2"
[@@mel.get] [@@mel.scope "a0", "a1"]

external getX3 : t -> int = "getX3"
[@@mel.get] [@@mel.scope "a0", "a1", "a2"]

external setX1 : t -> int -> unit = "setX1"
[@@mel.set] [@@mel.scope "a0"]

external setX2 : t -> int -> unit = "setX2"
[@@mel.set] [@@mel.scope "a0", "a1"]

external setX3 : t -> int -> unit = "setX3"
[@@mel.set] [@@mel.scope "a0","a1","a2"]

external setXWeird3 : t -> int -> unit = "setXWeird3"
[@@mel.set] [@@mel.scope "a0-hi","a1","a2"]

external send1 : t -> int -> unit = "send1"
[@@mel.send] [@@mel.scope "a0"]
external send2 : t -> int -> unit = "send2"
[@@mel.send] [@@mel.scope "a0","a1"]
external send3 : t -> int -> unit = "send3"
[@@mel.send] [@@mel.scope "a0","a1"]

external psend1 : int -> unit = "psend1"
[@@mel.send.pipe:t] [@@mel.scope "a0"]
external psend2 :  int -> unit = "psend2"
[@@mel.send.pipe:t] [@@mel.scope "a0","a1"]
external psend3 :  int -> unit = "psend3"
[@@mel.send.pipe:t] [@@mel.scope "a0","a1"]

let f3 x =
  ignore @@ makeBuffer 20;
  ignore @@ makeBuffer1 20;
  ignore @@ makeBuffer2 100;
  ignore @@ makeBuffer3 20;
  Js.log @@ max 1.0 2.0;
  (*Js.log @@ scope_f x ; *)
  Js.log @@ getMockFn1 x 0 ;
  Js.log @@ getMockFn2 x 0 ;
  Js.log @@ getMockFn3 x 0 ;
  setMocFn1 x 0 "x";
  setMocFn2 x 0 "x";
  setMocFn3 x 0 "x";
  Js.log @@ getX1 x ;
  Js.log @@ getX2 x ;
  Js.log @@ getX3 x;

  setX1 x 0 ;
  setX2 x 0 ;
  setX3 x 0 ;
  setXWeird3 x 0 ;

  send1 x 0;
  send2 x 0;
  send3 x 0;
  x|> psend1 0;
  x|> psend2 0;
  x|> psend3 0;
  create ()
