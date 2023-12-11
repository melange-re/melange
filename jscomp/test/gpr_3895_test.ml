let f re =
  let _ = re |> Js.Re.exec "banana" in
  3
