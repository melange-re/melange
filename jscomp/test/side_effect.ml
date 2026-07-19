Js.log __MODULE__

external register_named_value : string -> int -> unit =
  "caml_register_named_value"

let preserve_registration callback =
  let _unused = register_named_value "callback" (callback ()) in
  ()
