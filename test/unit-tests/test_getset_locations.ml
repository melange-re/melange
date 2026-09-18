open Ppxlib
module Abstract = Melange_ppx__Ast_derive__Ast_derive_abstract

let check_location label expected actual =
  Alcotest.(check bool) label true (expected = actual)

let ghost loc = { loc with Location.loc_ghost = true }

let declaration () =
  let lexbuf =
    Lexing.from_string
      {|type 'a record = {
  mutable first : ('a * int) option [@mel.optional];
  second : string;
}
|}
  in
  Location.init lexbuf "getset_locations.ml";
  match Parse.implementation lexbuf with
  | [ { pstr_desc = Pstr_type (_, [ declaration ]); _ } ] -> declaration
  | _ -> Alcotest.fail "unexpected parsed structure"

let check_type_locations expected_root core_type =
  check_location "generated type" expected_root core_type.ptyp_loc;
  let iterator =
    object
      inherit Ast_traverse.iter as super

      method! core_type core_type =
        Alcotest.(check bool)
          "generated core type is ghost" true core_type.ptyp_loc.loc_ghost;
        Alcotest.(check bool)
          "generated core type has a source position" true
          (core_type.ptyp_loc.loc_start.pos_cnum >= 0);
        super#core_type core_type
    end
  in
  iterator#core_type core_type

let rec find_value name = function
  | [] -> Alcotest.fail ("missing generated value " ^ name)
  | value :: values ->
      if value.pval_name.txt = name then value else find_value name values

let check_value ~field_name ~field_loc ~field_name_loc value =
  check_location "value description" field_loc value.pval_loc;
  check_location "value name" field_name_loc value.pval_name.loc;
  check_type_locations (ghost field_name_loc) value.pval_type;
  Alcotest.(check string) "value name" field_name value.pval_name.txt

let generated_getset_types_use_field_locations () =
  let declaration = declaration () in
  let fields =
    match declaration.ptype_kind with
    | Ptype_record fields -> fields
    | Ptype_abstract | Ptype_variant _ | Ptype_open ->
        Alcotest.fail "expected a record declaration"
  in
  let first, second =
    match fields with
    | [ first; second ] -> (first, second)
    | _ -> Alcotest.fail "unexpected field count"
  in
  let structure =
    Abstract.derive_getters_setters_str ~light:false [ declaration ]
  in
  let structure_values =
    List.map structure ~f:(fun item ->
        match item.pstr_desc with
        | Pstr_primitive value ->
            check_location "structure item" (ghost value.pval_loc) item.pstr_loc;
            value
        | _ -> Alcotest.fail "expected a primitive structure item")
  in
  let signature =
    Abstract.derive_getters_setters_sig ~light:false [ declaration ]
  in
  let signature_values =
    List.map signature ~f:(fun item ->
        match item.psig_desc with
        | Psig_value value ->
            check_location "signature item" (ghost value.pval_loc) item.psig_loc;
            value
        | _ -> Alcotest.fail "expected a value signature item")
  in
  let check values =
    List.iter
      ~f:(fun (name, field) ->
        check_value ~field_name:name ~field_loc:field.pld_loc
          ~field_name_loc:field.pld_name.loc (find_value name values))
      [ ("firstGet", first); ("firstSet", first); ("secondGet", second) ]
  in
  check structure_values;
  check signature_values

let suite =
  [
    Alcotest.test_case "generated types use field locations" `Quick
      generated_getset_types_use_field_locations;
  ]
