let _ =
  begin
    assert (Js.Nullable.toOption (Js.Nullable.return "" ) = Some "");
    assert (Js.Undefined.toOption (Js.Undefined.return "" ) = Some "");
    assert (Js.Null.toOption (Js.Null.return "") = Some "")
  end
