let uchar_to_int u = Uchar.to_int u

let captures_after_effect a =
  let () = Js.log "hello" in
  fun b -> a + b
