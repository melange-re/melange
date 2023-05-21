let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y = Mt.eq_suites ~test_id ~suites loc x y




type test = {
  s : string option [@bs.optional];
  b : bool option [@bs.optional];
  i : int option  [@bs.optional];
} [@@deriving abstract]


let make ?s ?b ?i  = test ?s ?b ?i


let hh = (make ~s:"" ~b:false ~i:0 ())


;; eq __LOC__ (hh |. sGet) (Some "")
;; eq __LOC__ (hh |. bGet) (Some false)
;; eq __LOC__ (hh |. iGet) (Some 0)
;; Js.log hh
;; Mt.from_pair_suites __MODULE__ !suites
