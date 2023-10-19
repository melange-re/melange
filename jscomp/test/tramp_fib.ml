[@@@mel.config {flags = [|"-w";"a";"-bs-noassertfalse"|]}]

let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y = Mt.eq_suites ~test_id ~suites loc x y


type 'a bounce = Continue of 'a | Suspend of (unit -> 'a bounce [@u])
(* https://eli.thegreenplace.net/2017/on-recursion-continuations-and-trampolines/ *)
(* http://gallium.inria.fr/seminaires/transparents/20141027.Frederic.Bour.pdf *)
(* http://www.usrsb.in/blog/blog/2012/08/12/bouncing-pythons-generators-with-a-trampoline/ *)
(* http://glat.info/jscheck/tomrec.html *)
let rec fib n k =
  match n with
  | 0 | 1 ->
    (* k (Continue 1) [@u] *)
    (* Suspend (fun [@u]() -> k (Continue 1 ) [@u]) *)
    k 1 [@u]
  | _ ->
    Suspend (fun [@u] () ->
      fib (n-1) (fun [@u] v0 ->
        fib (n-2) (fun [@u] v1 ->
          k (v0 + v1) [@u]
        (* match v0,v1 with
        | Continue v0, Continue v1 ->  *)
          (* k (Continue (v0 + v1)) [@u] *)
          (* Suspend (fun [@u]() -> k (Continue (v0 + v1)) [@u]) *)
        (* | _ -> assert false   *)
          (* FIXME: this branch completly gone*)
        )
      )
    )

let u = fib 10 (fun [@u] x -> Continue x)


let rec iter (bounce : 'a bounce) : 'a =
  match bounce with
  | Continue v -> v
  | Suspend f -> iter (f () [@u])


(* first it needs to be tailcall *)
let rec isEven n =
  match n with
  | 0 -> Continue true
  | 1 -> Continue false
  | _ -> Suspend (fun [@u] () -> isOdd (n - 1))
and isOdd n =
  match n with
  | 0 -> Continue false
  | 1 -> Continue true
  | _ ->
    isEven (n - 1)
    (* Suspend (fun [@u] () -> isEven (n - 1))       *)
;; eq __LOC__ (iter u) 89

;; eq __LOC__  (isEven 20_000 |. iter )  true

;; Mt.from_pair_suites __LOC__ !suites
