module Lam_ccall = Melangelib.Lam_ccall

let register_named_value_is_effectful () =
  let ccall = Lam_ccall.of_name "caml_register_named_value" in
  Alcotest.(check bool)
    "the registration call may have side effects" true
    (match Lam_ccall.effects ccall with
    | May_have_side_effects -> true
    | No_side_effects | Depends_on_arguments _ -> false);
  Alcotest.(check bool)
    "the unsupported registration itself lowers to unit" true
    (match Lam_ccall.lowering ccall with
    | Builtin Unit -> true
    | Builtin _ | Conditional _ | External -> false)

let suite =
  [
    Alcotest.test_case "register_named_value is effectful" `Quick
      register_named_value_is_effectful;
  ]
