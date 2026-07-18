
module N  = struct
  let add x y = x + y
end

module Deep = struct
  module N = struct
    let add x y = x + y
  end
end

module ExternalAlias = Nested_call_target.Tree
module ExternalNAlias = Nested_call_target.Tree.N

module ExternalInclude = struct
  include Nested_call_target.Tree
end

module ExternalNInclude = struct
  include Nested_call_target.Tree.N
end

module P = struct
  external fancy_add : int -> int -> int = "caml_nested_summary_fancy_add"
end

module Js_call = struct
  external parse_int : string -> int = "parseInt"
  external imul : int -> int -> int = "imul" [@@mel.scope "Math"]
  external basename : string -> string = "basename" [@@mel.module "path"]
end

module Js_object = struct
  external make : x:int -> y:int -> < x : int; y : int > Js.t = "" [@@mel.obj]
end

module Forward = struct
  let external_target x = Nested_call_target.external_target x
end

module type S0 =  sig 
  val f1 : unit -> unit 
  val f2 : unit -> unit -> unit 
  val f3 : unit -> unit -> unit -> unit 
end 

module N0 : S0 = struct 
  let f4 _ _ _ = ()
  let f1 _ = ()
  let f2 _ _ = ()
  let f3 _ _ _ = ()
end

module N1 = struct 
  let f4 _ _ _ = ()
  let f1 _ = ()
  let f2 _ _ = ()
  let f3 _ _ _ = ()
end
