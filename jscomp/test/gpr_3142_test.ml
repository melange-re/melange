let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y = Mt.eq_suites ~test_id ~suites loc x y


type t =
  [ `a [@mel.as "x"]
  | `u [@mel.as "hi"]
  | `b [@mel.as {j|你|j} ]
  | `c [@mel.as {js|我|js}]
  ]
  [@@deriving jsConverter]

let v,u = tToJs, tFromJs


;; eq __LOC__ (v `a) "x"
;; eq __LOC__ (v `u) "hi"
;; eq __LOC__ (v `b) {j|你|j}
;; eq __LOC__ (v `c) {js|我|js}

;; eq __LOC__ (u "x")  (Some `a)
;; eq __LOC__ (u "hi") (Some `u)
;; eq __LOC__ (u {j|你|j}) (Some `b)
;; eq __LOC__ (u {js|我|js}) (Some `c)
;; eq __LOC__ (u "xx") None

let () = Mt.from_pair_suites __MODULE__ !suites
