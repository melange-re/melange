(* https://github.com/melange-re/melange/issues/267 *)

let i ~(obj : < prop : 'a -> 'b ; .. > Js.t) s = s |> obj##prop

let f ~(obj : < prop : 'a -> 'b ; .. > Js.t) s =
  let p = obj##prop in
  s |> p
