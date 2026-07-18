
module N  = struct
  let add x y = x + y
end

module Deep = struct
  module N = struct
    let add x y = x + y
  end
end

module P = struct
  external fancy_add : int -> int -> int = "caml_nested_summary_fancy_add"
end

module Forward = struct
  let choose x y = Inner_target.choose x y
end

type point

type ffi_functions = {
  imul : int -> int -> int;
  basename : string -> string;
  point : int -> int -> point;
}

external math_imul : int -> int -> int = "imul" [@@mel.scope "Math"]
external path_basename : string -> string = "basename" [@@mel.module "path"]
external make_point : x:int -> y:int -> point = "" [@@mel.obj]

external unresolved_add : int -> int -> int =
  "caml_nested_summary_unresolved_add"

module Ffi = struct
  let imul x y = math_imul x y
  let basename path = path_basename path
  let point x y = make_point ~x ~y
  let unresolved_add x y = unresolved_add x y
end

module PackedFfi = struct
  let functions = {
    imul = (fun x y -> math_imul x y);
    basename = (fun path -> path_basename path);
    point = (fun x y -> make_point ~x ~y);
  }
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
