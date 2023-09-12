let a = [%mel.obj { x = 3 ; y = [| 1|]} ]

let b =
  [%mel.obj { x = 3 ; y = [| 1 |]; z = 3; u = fun [@u] x y -> x + y } ]

let f obj =
  obj ## x + Array.length (obj ## y)

let h obj = obj#@u 1 2


let u = f  a

let v = f b

let vv = h b
