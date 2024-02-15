module Curry = struct
end
module Block = struct
end


external map : 'a array -> ('a -> 'b [@mel.uncurry  ]) -> 'b array =
    "Array.prototype.map.call"



type id = int -> int
external map2 : int array ->  (int -> int  [@mel.uncurry ]) -> int array =
    "Array.prototype.map.cal"


(* [@mel.uncurry n] should not be documented,
    since such inconsistency could not be checked
*)

(* if we know the return value of type we could do more optimizations here *)
let xbs = map  [|1;2;3; 5 |] (fun x -> x + 1 )

let f (cb : int -> int ) =
    map [|1;2;3;4|] cb


let xs =
    map [|1;1;2|]
    (fun x y -> y + x + 1 )


external map2 :
    'a array -> 'b array -> ('a -> 'b -> 'c [@mel.uncurry])
    -> 'c array = "map2"



external ff :
    int -> (int [@mel.ignore]) -> (int -> int -> int [@mel.uncurry]) -> int
    = "ff"

external ff1 :
    int -> (_ [@mel.as 3 ]) -> (int -> int -> int [@mel.uncurry]) -> int
    = "ff1"


external ff2 :
    int -> (_ [@mel.as "3" ]) -> (int -> int -> int [@mel.uncurry]) -> int
    = "ff2"

external
 hi: (unit -> unit [@mel.uncurry 0]) -> int = "hi"

(**
fun (_){
    f 0
}

*)


let f_0 () =  hi (fun () -> () )
let f_01 () = hi (fun (() as x) -> if x = () then Js.log "x" ) (* FIXME: not inlined *)
let f_02 xs = hi (fun (() as x) -> xs := x ;  Js.log "x" )
let f_03 xs u = hi u
 (* arity adjust to [0] [ function (){return u (0)}] *)

let fishy x y z =
    map2 x y (fun x -> z x)

let h x y  z =
    map2 x y z


let h1 x y u z =
    map2 x y (z u)

let add3 x y z = x  + y + z

let h2 x  =
    ff x 2 (+)

let h3 x =
    ff x 2 (add3 1 )

let h4 x =
    ff1 x (add3  1)

let h5 x =
    ff2 x (add3 2)
let add x y =
    Js.log (x,y) ;
    x + y



let h6 x =
    ff2 x add




type elem
external optional_cb :
    (string -> ?props:elem -> int array -> elem [@mel.uncurry] (* This should emit a warning ? *)
    ) -> string -> int = "optional_cb"



(*
let fishy_unit = fun () -> Js.log 1

let fishy_unit_2 = fun [@u] (() as x) -> Js.log x

let v = fishy_unit_2 () [@u]

*)
(* Up is not a valid syntax, since you can not apply correctly *)


(* ^ should be an error instead of warning *)


(*
external ff :
    int ->
    (unit -> unit [@mel.uncurry]) ->
    int =
    ""

*)


(*
So if we pass
{[ (fun (() as x) ->  Js.log x  ) ]}

Then we call it on JS side
[g ()], we are passing undefined
to [x] which is incorrect.

We can also blame users
[()=>] is really not representable  in OCaml
You are writing the wrong FFI....

They need (fun ()[@u] -> ..)
Maybe we can create a sugar
{[ begin [@u]  .... end  ]}
*)

(*
external config :
    hi: (int -> int [@mel.uncurry]) ->
    lo: int ->
    unit ->
    _ = "" [@@mel.obj]

type expected =
    < hi : int -> int [@u];
      lo : int > Js.t

let f : expected =
    config
    ~hi:(fun x -> x + 1 )
    ~lo:3
    ()
*)
(** we auto-uncurry
so the inferred type would be
*)

(*
let v = ref 0



(**
There is a semantics mismatch when converting curried function into uncurried function
for example
`let u = f a b c in u d ` may have a side effect here when creating [u].
We should document it clearly
*)
let a4 = Js.Internal.js_fn_mk4 (fun x y z -> incr v ;  fun d -> 1 + d)


let () =
    ignore @@ a4 0 1 2 3 [@u]
    ignore @@ a4 0 1 2 3 [@u]

;;

Mt.from_pair_suites __MODULE__ !suites
*)

let unit_magic () =
    Js.log "noinline" ;
     Js.log "noinline" ;
     3

let f_unit_magic  = unit_magic ()

external f_0002 :  string  -> int array ->  unit = "f_0002" [@@mel.variadic]

let hh xs = f_0002 xs
