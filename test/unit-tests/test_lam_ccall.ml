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

let result_kinds () =
  let check expected prim_name =
    Alcotest.(check bool)
      prim_name expected
      (Lam_ccall.returns_boolean (Lam_ccall.of_name prim_name))
  in
  List.iter
    [
      "caml_eq_float";
      "caml_bytes_equal";
      "caml_int64_equal_nullable";
      "caml_signbit_float";
      "caml_string_greaterthan";
      "caml_bool_lessthan";
      "caml_int_equal_nullable";
      "caml_float_equal_null";
      "caml_string_equal_undefined";
      "caml_bool_min";
      "caml_bool_max";
      "caml_is_extension";
      "caml_sys_is_directory";
      "caml_equal";
      "caml_notequal";
      "caml_greaterequal";
    ]
    ~f:(check true);
  List.iter
    [
      "caml_add_float";
      "caml_bytes_compare";
      "caml_int64_compare";
      "caml_float_compare";
      "caml_bool_compare";
      "caml_int_min";
      "caml_int_max";
      "caml_exn_slot_id";
      "caml_sys_getcwd";
      "caml_compare";
      "caml_min";
      "caml_max";
      "unknown_external";
    ]
    ~f:(check false)

let suite =
  [
    Alcotest.test_case "register_named_value is effectful" `Quick
      register_named_value_is_effectful;
    Alcotest.test_case "result kinds" `Quick result_kinds;
  ]
