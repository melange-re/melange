let f re =
  let _ = re |> Js.Re.exec ~str:"banana" in
  3
