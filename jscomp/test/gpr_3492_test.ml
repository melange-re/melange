let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y = Mt.eq_suites ~test_id ~suites loc x y

[%%mel.raw "function foo(a){return a()}"]

external foo : ((unit -> int)[@mel.uncurry ]) -> int = "foo"
let fn () =
   Js.log "hi";
   1


let () =
   eq __LOC__ (foo fn) 1

let () =
  Mt.from_pair_suites __FILE__ !suites
