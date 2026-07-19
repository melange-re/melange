module Lam_ccall = Melangelib.Lam_ccall

let register_named_value_is_effectful () =
  let ccall = Lam_ccall.of_name "caml_register_named_value" in
  Alcotest.(check bool)
    "the unsupported registration is an effectful unit builtin" true
    (match Lam_ccall.behavior ccall with
    | Builtin (Unit, May_have_side_effects) -> true
    | Builtin _ | Conditional _ | External _ -> false)

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

let behaviors () =
  let check message prim_name predicate =
    Alcotest.(check bool)
      message true
      (predicate (Lam_ccall.behavior (Lam_ccall.of_name prim_name)))
  in
  check "pure builtin" "caml_string_repeat" (function
    | Builtin (String_repeat, No_side_effects) -> true
    | Builtin _ | Conditional _ | External _ -> false);
  check "conditional behavior" "caml_ml_open_descriptor_in" (function
    | Conditional Open_descriptor_in -> true
    | Builtin _ | Conditional Open_descriptor_out | External _ -> false);
  check "pure external" "caml_sys_get_config" (function
    | External No_side_effects -> true
    | Builtin _ | Conditional _ | External May_have_side_effects -> false);
  Alcotest.(check bool)
    "conditional resolution" true
    (match
       ( Lam_ccall.resolve_conditional Open_descriptor_in 0l,
         Lam_ccall.resolve_conditional Open_descriptor_out 2l,
         Lam_ccall.resolve_conditional Open_descriptor_in 1l )
     with
    | Some (Io, "stdin"), Some (Io, "stderr"), None -> true
    | _ -> false)

let suite =
  [
    Alcotest.test_case "register_named_value is effectful" `Quick
      register_named_value_is_effectful;
    Alcotest.test_case "result kinds" `Quick result_kinds;
    Alcotest.test_case "behaviors" `Quick behaviors;
  ]
