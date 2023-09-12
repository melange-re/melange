

external map : 'a array -> ('a -> 'b [@u])  -> 'b array = "map" [@@mel.send]
external mapi : 'a array -> ('a -> int -> 'b [@u])  -> 'b array = "map" [@@mel.send]

external parseInt : string -> int = "parseInt"
external parseInt_radix : string -> int -> int = "parseInt"

let f v =
  if v mod 2 = 0 then
    fun v -> v * v
  else  fun v -> v + v

let v  = mapi [|1;2;3 |] (fun [@u] a b   -> f a b)

let vv  = mapi [|1;2;3 |] (fun [@u] a b->  a + b)

let hh = map [|"1";"2";"3"|] (fun [@u] x -> parseInt x)

let u = (fun [@u] () -> 3)

let vvv = ref 0
let fff () =
    (* No inline *)
    Js.log "x";
    Js.log "x";
    incr vvv

let g = fun [@u] () -> fff ()
(* will be compiled into
  var g = function () { fff (0)}
  not {[ var g = fff ]}
*)
let abc x y z =
    Js.log "xx";
    Js.log "yy";
    x + y + z

let abc_u = fun [@u] x y z -> abc x y z
(* cool, it will be compiled into
{[ var absc_u = abc ]}
*)
let () = g () [@u]
;; Mt.from_pair_suites __MODULE__ Mt.[
    __LOC__, (fun _ -> Eq(v, [|0; 1;  4 |] ));
    __LOC__, (fun _ -> Eq(vv, [|1;3;5|]));
    __LOC__, (fun _ -> Eq(hh, [|1;2;3|]));
    (* __LOC__, (fun _ -> Eq(

         map (map [| 1;2;3|]  ( (fun [@u] x -> fun y -> x + y)))
          ( fun [@u] y -> (y 0)  * (y 1) ), [|2; 6 ; 12|]
      )); *)
    (* __LOC__, (fun _ -> Eq(
        mapi [|1;2;3|] (Js.Internal.fn_mk2 (fun x  -> let y =  x * x in fun i -> y + i )),
        [|1; 5 ; 11|]
      )) *)
]


(* FIXME: *)
let bar fn = fn ()
(* let hh0001 = fun%raw a b -> {| a + b|}
let hh0002 = fun%raw () -> {| console.log ("forgiving arity")|}  *)
;; bar [%raw {|function(){console.log("forgiving arity")}|}]
