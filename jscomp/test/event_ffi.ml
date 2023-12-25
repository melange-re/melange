


(*
type process

external on : process ->
  [
  `beforeExit
  | `exit
  ] ->  unit Js.fn -> unit = "on" [@@mel.send]


external p : process = "process" [@@mel.val]


external on_hi : process ->
  [
  `hello
  | `xx
  ] ->  (unit*unit) Js.fn -> unit = "on" [@@mel.send]

type 'a t

external (!) : 'a t -> 'a = "identity"

let f x =
  !x # hey 3  + !x # v

let () =
  on p `exit (Js.Internal.fn_mk0 (fun _ -> prerr_endline "hello world"));
  on_hi p `xx (Js.Internal.fn_mk1 (fun _ -> prerr_endline "hello world"))

*)

let h0 x = x () [@u]
(* {[
     function h0 (x){
         return x ()
       }
   ]}
*)
let h00 x =  x () [@u]

let h1 x = (fun y -> x y [@u]) (* weird case *)
(*
bucklescript$bsc -bs-syntax-only -dsource -bs-eval 'let h1 x = fun y -> x y'
let h1 x y = x y
*)
let h10 x = x 3 [@u]

let h30 x = fun [@u] a ->  x 3 3 a [@u]
let h33 x =  x 1 2 3 [@u]
let h34 x = (x 1 2 3 [@u]) 4


let ocaml_run = fun[@u] b c -> (fun [@u] x y z -> x + y + z) 1  b c[@u]

let a0 =  (fun [@u]  () -> Js.log "hi")
let a1 () =  (fun[@u] x -> x )
let a2 =  (fun[@u] x y -> x + y)
let a3 =  (fun [@u] x y z -> x + y + z )
(* let a4 = Js.Internal.fn_mk4 (fun x y z -> let u = x * x + y * y + z * z in fun d -> u + d) *)

(* let a44 = Js.Internal.fn_mk4 (fun x y z d -> let u = x * x + y * y + z * z in  u + d) *)

(* let b44 () = Js.Internal.fn_mk4 (fun x y z d -> (x,y,z,d)) *)
(* polymoprhic restriction *)

let test_as : ('a -> 'a)  -> (_ as 'b)  ->  'b = List.map

let xx : unit -> ( _ -> unit [@u]) = fun () -> fun [@u] _ -> Js.log 3


(* let test_hihi = hihi _ [@u] *)

