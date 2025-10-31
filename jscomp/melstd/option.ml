include Stdlib.Option

let bind o ~f = bind o f
let map ~f o = map f o
let iter ~f o = iter f o
let equal ~eq o0 o1 = equal eq o0 o1
let compare ~cmp o0 o1 = compare cmp o0 o1
