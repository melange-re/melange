open Ppxlib

let location start stop =
  let position offset =
    { Lexing.dummy_pos with pos_fname = "input.ml"; pos_cnum = offset }
  in
  {
    Location.loc_start = position start;
    loc_end = position stop;
    loc_ghost = false;
  }

let parameter ~loc name =
  {
    pparam_desc =
      Pparam_val
        (Nolabel, None, Ast_builder.Default.ppat_var ~loc { txt = name; loc });
    pparam_loc = loc;
  }

let optional_parameter ~loc name =
  {
    pparam_desc =
      Pparam_val
        ( Optional name,
          None,
          Ast_builder.Default.ppat_var ~loc { txt = name; loc } );
    pparam_loc = loc;
  }

let parameter_locations = function
  | Pexp_record
      ( [
          (_, { pexp_desc = Pexp_function (parameters, _, Pfunction_body _); _ });
        ],
        None ) ->
      List.map (fun parameter -> parameter.pparam_loc) parameters
  | _ -> Alcotest.fail "unexpected uncurried function shape"

let test_uncurried_function () =
  let loc = location 0 40 in
  let first_loc = location 10 15 in
  let second_loc = location 20 26 in
  let mapper = new Ast_traverse.map in
  let body = Ast_builder.Default.eint ~loc 0 in
  let description =
    Melange_ppx__Ast_uncurry_gen.to_uncurry_fn ~loc mapper
      [ parameter ~loc:first_loc "first"; parameter ~loc:second_loc "second" ]
      body
  in
  let locations = parameter_locations description in
  Alcotest.(check (list int))
    "parameter starts"
    [ first_loc.loc_start.pos_cnum; second_loc.loc_start.pos_cnum ]
    (List.map (fun loc -> loc.Location.loc_start.pos_cnum) locations)

let test_optional_parameter_error () =
  let loc = location 0 40 in
  let parameter_loc = location 10 24 in
  let mapper = new Ast_traverse.map in
  let body = Ast_builder.Default.eint ~loc 0 in
  let error_loc =
    match
      Melange_ppx__Ast_uncurry_gen.to_uncurry_fn ~loc mapper
        [ optional_parameter ~loc:parameter_loc "value" ]
        body
    with
    | exception Location.Error error -> Location.Error.get_location error
    | _ -> Alcotest.fail "expected optional-parameter error"
  in
  Alcotest.(check int)
    "error start" parameter_loc.loc_start.pos_cnum error_loc.loc_start.pos_cnum

let find_parameter_location name expression =
  let result = ref None in
  let iterator =
    object (self)
      inherit Ast_traverse.iter as super

      method! function_param parameter =
        (match parameter.pparam_desc with
        | Pparam_val (_, _, { ppat_desc = Ppat_var { txt; _ }; _ })
          when String.equal txt name ->
            result := Some parameter.pparam_loc
        | Pparam_val _ | Pparam_newtype _ -> ());
        super#function_param parameter
    end
  in
  iterator#expression expression;
  !result

let test_object_self () =
  let loc = location 0 80 in
  let self_loc = location 7 13 in
  let method_loc = location 20 45 in
  let argument_loc = location 30 38 in
  let self_pattern =
    Ast_builder.Default.ppat_var ~loc:self_loc { txt = "self"; loc = self_loc }
  in
  let argument = parameter ~loc:argument_loc "argument" in
  let argument_expression =
    Ast_builder.Default.evar ~loc:argument_loc "argument"
  in
  let method_expression =
    Ast_builder.Default.pexp_function ~loc:method_loc [ argument ] None
      (Pfunction_body argument_expression)
  in
  let method_field =
    Ast_helper.Cf.method_ ~loc:method_loc
      { txt = "method_"; loc = method_loc }
      Public
      (Cfk_concrete
         (Fresh, Ast_helper.Exp.poly ~loc:method_loc method_expression None))
  in
  let mapper = new Ast_traverse.map in
  let expression =
    Ast_helper.Exp.mk ~loc
      (Melange_ppx__Ast_object.ocaml_object_as_js_object ~loc mapper
         self_pattern [ method_field ])
  in
  match find_parameter_location "self" expression with
  | Some parameter_loc ->
      Alcotest.(check int)
        "self parameter start" self_loc.loc_start.pos_cnum
        parameter_loc.loc_start.pos_cnum
  | None -> Alcotest.fail "missing generated self parameter"

let () =
  Alcotest.run "uncurried parameter locations"
    [
      ( "function",
        [
          Alcotest.test_case "preserved" `Quick test_uncurried_function;
          Alcotest.test_case "optional argument error" `Quick
            test_optional_parameter_error;
        ] );
      ("object", [ Alcotest.test_case "self pattern" `Quick test_object_self ]);
    ]
