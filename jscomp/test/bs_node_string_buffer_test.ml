let f  str =
  match Node.test str with
  | (Node.String, s) -> Js.log ("string", s)
  | (Node.Buffer, s) -> Js.log ("buffer", Node.Buffer.isBuffer s)


let () =
  begin
    f [%mel.raw {|"xx"|}];
    f [%mel.raw {|Buffer.from ('xx')|}]
  end
