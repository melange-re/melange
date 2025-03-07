let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites

(**
[%%raw [@import "jscomp/test/xx.js"]] (* PATH relative to package.json *)
*)

[%%raw{|
function Make (){
  this.data = []
  for(var i = 0; i < arguments.length; ++i){
   this.data[i] = arguments[i]
}
}

Make.prototype.sum = function(){
  var result  = 0;
  for(var k = 0; k < this.data.length; ++k){
    result = result + this.data[k]
  };
  return result
}

Make.prototype.add = function(){

}
|}]

type t


external make : int -> int -> int -> int -> t = "Make"  [@@mel.new]


external sum : t -> unit -> int = "sum" [@@mel.send]

(* compile error *)
(* external join : string  -> string = "" [@@mel.module "path"] [@@mel.variadic] *)
external join : string array -> string = "join" [@@mel.module "path"] [@@mel.variadic]

external test : string array -> (t [@mel.this]) -> t = "test" [@@mel.send] [@@mel.variadic] (*FIXME*)

(* compile error *)
(* external test2 : int -> string -> t= "" [@@mel.send.pipe: t ] [@@mel.variadic] *)
let u = [|"x";"d" |]
let f x  =
  x
  |> test  [| "a"; "b" |]
  |> test  [| "a"; "b" |]
  (* |> test u *)

let v = make 1 2 3 4

let u = sum v ()


let () = eq __LOC__ u 10

;; Mt.from_pair_suites __MODULE__ !suites
