[@@@mel.config {
  flags = [|
    "-warn-error";
       "A-105";
  |]
}]



external f : int -> int = "xx"


let u () = f 3
let v = Js.Null.empty

let a, b ,c, d = (true, false, Js.Null.empty, Js.Undefined.empty)

module Textarea = struct
  type t
  external create : unit -> t  = "TextArea" [@@mel.new ]
  (* TODO: *)
  external set_minHeight : t -> int -> unit = "minHeight" [@@mel.set ]
  external get_minHeight : t ->  int = "minHeight" [@@mel.get]
  external draw : t -> string  -> unit = "string" [@@mel.send ]

end

(*
external never_used : Textarea.t ->  int -> int  = "minHeight" [@@mel.get]

let v = never_used (Textarea.create ()) 3
*)
module Int32Array = struct
  type t
  external create : int -> t = "Int32Array" [@@mel.new]
  external get : t -> int -> int = "" [@@mel.get_index]
  external set : t -> int -> int -> unit = "" [@@mel.set_index]
end

let v () =
  let u = Textarea.create () in
   Textarea.set_minHeight u 3 ;
   Textarea.get_minHeight u
   (* Textarea.set_minHeight_x *)


let f () =
  let module Array = Int32Array in
  let v  = Array.create 32 in
  begin
    v.(0) <- 3   ;
    v.(0)
  end

external removeItem : string -> unit  = "removeItem"
  [@@mel.scope "localStorage"]
