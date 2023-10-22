let f xs =
  let _unused =
    match xs with
    | Some (l) -> Js.log "side effect"; [l; l]
    | None  -> [1; 2]
  in
  Js.log2 "nothing to see here" xs
