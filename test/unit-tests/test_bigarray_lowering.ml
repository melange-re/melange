open Melangelib

let loc = Debuginfo.Scoped_location.Loc_unknown

let convert primitive args =
  fst
    (Lam_convert.convert Ident.Set.empty (Lambda.Lprim (primitive, args, loc)))

let ccall = function
  | Lam.Lprim { primitive = Lam_primitive.Pccall { prim_name }; args; _ } ->
      (prim_name, args)
  | _ -> Alcotest.fail "expected a C primitive call"

let check_var message expected = function
  | Lam.Lvar actual ->
      Alcotest.(check bool) message true (Ident.same expected actual)
  | _ -> Alcotest.fail (message ^ ": expected a variable")

let check_dim_lowering dimension expected_index =
  let ba = Ident.create_local "ba" in
  let prim_name, args =
    convert (Lambda.Pbigarraydim dimension) [ Lambda.Lvar ba ] |> ccall
  in
  Alcotest.(check string) "runtime primitive" "caml_ba_dim" prim_name;
  match args with
  | [ ba_arg; Lam.Lconst (Lam.Constant.Const_int { i; _ }) ] ->
      check_var "bigarray argument" ba ba_arg;
      Alcotest.(check int32)
        "zero-based dimension index"
        (Int32.of_int expected_index)
        i
  | _ -> Alcotest.fail "caml_ba_dim should receive a bigarray and an index"

let test_dimension_lowering () =
  check_dim_lowering 1 0;
  check_dim_lowering 3 2

let test_access_lowering () =
  let ba = Ident.create_local "ba" in
  let i0 = Ident.create_local "i0" in
  let i1 = Ident.create_local "i1" in
  let i2 = Ident.create_local "i2" in
  let i3 = Ident.create_local "i3" in
  let value = Ident.create_local "value" in
  let kind = Lambda.Pbigarray_unknown in
  let layout = Lambda.Pbigarray_unknown_layout in
  let direct_get_name, direct_get_args =
    convert
      (Lambda.Pbigarrayref (false, 2, kind, layout))
      [ Lambda.Lvar ba; Lambda.Lvar i0; Lambda.Lvar i1 ]
    |> ccall
  in
  Alcotest.(check string)
    "specialized get primitive" "caml_ba_get_2" direct_get_name;
  Alcotest.(check int) "specialized get arity" 3 (List.length direct_get_args);
  let generic_get_name, generic_get_args =
    convert
      (Lambda.Pbigarrayref (false, 4, kind, layout))
      [
        Lambda.Lvar ba;
        Lambda.Lvar i0;
        Lambda.Lvar i1;
        Lambda.Lvar i2;
        Lambda.Lvar i3;
      ]
    |> ccall
  in
  Alcotest.(check string)
    "generic get primitive" "caml_ba_get_generic" generic_get_name;
  (match generic_get_args with
  | [ ba_arg; Lam.Lprim { primitive = Lam_primitive.Pmakearray; args; _ } ] ->
      check_var "generic get bigarray" ba ba_arg;
      Alcotest.(check int) "generic get index count" 4 (List.length args)
  | _ -> Alcotest.fail "generic get should pack indices into an array");
  let zero_get_name, zero_get_args =
    convert (Lambda.Pbigarrayref (false, 0, kind, layout)) [ Lambda.Lvar ba ]
    |> ccall
  in
  Alcotest.(check string)
    "zero-dimensional get primitive" "caml_ba_get_generic" zero_get_name;
  (match zero_get_args with
  | [ ba_arg; Lam.Lprim { primitive = Lam_primitive.Pmakearray; args = []; _ } ]
    ->
      check_var "zero-dimensional get bigarray" ba ba_arg
  | _ -> Alcotest.fail "zero-dimensional get should pass an empty index array");
  let direct_set_name, direct_set_args =
    convert
      (Lambda.Pbigarrayset (false, 3, kind, layout))
      [
        Lambda.Lvar ba;
        Lambda.Lvar i0;
        Lambda.Lvar i1;
        Lambda.Lvar i2;
        Lambda.Lvar value;
      ]
    |> ccall
  in
  Alcotest.(check string)
    "specialized set primitive" "caml_ba_set_3" direct_set_name;
  Alcotest.(check int) "specialized set arity" 5 (List.length direct_set_args);
  let generic_set_name, generic_set_args =
    convert
      (Lambda.Pbigarrayset (false, 4, kind, layout))
      [
        Lambda.Lvar ba;
        Lambda.Lvar i0;
        Lambda.Lvar i1;
        Lambda.Lvar i2;
        Lambda.Lvar i3;
        Lambda.Lvar value;
      ]
    |> ccall
  in
  Alcotest.(check string)
    "generic set primitive" "caml_ba_set_generic" generic_set_name;
  (match generic_set_args with
  | [
   ba_arg;
   Lam.Lprim { primitive = Lam_primitive.Pmakearray; args; _ };
   value_arg;
  ] ->
      check_var "generic set bigarray" ba ba_arg;
      Alcotest.(check int) "generic set index count" 4 (List.length args);
      check_var "generic set value" value value_arg
  | _ -> Alcotest.fail "generic set should pack indices into an array");
  let zero_set_name, zero_set_args =
    convert
      (Lambda.Pbigarrayset (false, 0, kind, layout))
      [ Lambda.Lvar ba; Lambda.Lvar value ]
    |> ccall
  in
  Alcotest.(check string)
    "zero-dimensional set primitive" "caml_ba_set_generic" zero_set_name;
  match zero_set_args with
  | [
   ba_arg;
   Lam.Lprim { primitive = Lam_primitive.Pmakearray; args = []; _ };
   value_arg;
  ] ->
      check_var "zero-dimensional set bigarray" ba ba_arg;
      check_var "zero-dimensional set value" value value_arg
  | _ -> Alcotest.fail "zero-dimensional set should pass an empty index array"

let suite =
  [
    ("dimension indices", `Quick, test_dimension_lowering);
    ("access primitives", `Quick, test_access_lowering);
  ]
