[@@@warning "-22"]
(* [@@@mel.config no_export] *)
(* let for_each n =
  ([%raw{|
	for (var key in n){
      console.log(key)
    }
  |}] : unit ); () *)



let sum : int -> int -> int  =  [%raw{|(a,b) => a + b
|}]

let v = sum 1 2

let f a = a + [%raw {|3|}]


let b = f 1
let c = f 2

let forIn =
   [%raw{|(o,foo)=> {
  for (var i in o){
    foo(o)
  }
  }|}]


let forIn : 'a -> (string -> unit [@u]) -> unit = forIn


(*
let%raw forIn : 'a -> (string -> unit [@u]) -> unit = fun o foo -> {|
  for (var i in o){
    foo(o)
  }
|}
*)
module N  : sig
  val log2 : string -> unit [@u]
end  = struct
let log = fun [@u] x -> Js.log x

let log2 : 'a -> unit [@u] = log
end

(* let log : 'a -> unit = fun%raw x -> {|console.log (x)|}   *)

;;   forIn   [%obj{x = 3 }]  (fun[@u] x -> Js.log x)
;;   forIn   [%obj{x = 3 ; y = 3}]  (fun[@u] x -> Js.log x)


let f3  : unit -> bool [@u] = [%raw"()=>true"]

let bbbb  = f3 () [@u]

;;assert (bbbb)

