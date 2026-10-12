open Ppxlib
module Util = Melange_ppx__Ast_derive__Ast_derive_util

let check_location label expected actual =
  Alcotest.(check bool) label true (expected = actual)

let check_string label expected actual =
  Alcotest.(check string) label expected actual

let ghost loc = { loc with Location.loc_ghost = true }

let declaration () =
  let lexbuf = Lexing.from_string "type ('a, 'b) pair = 'a * 'b" in
  Location.init lexbuf "ast_derive_util_locations.ml";
  match Parse.implementation lexbuf with
  | [ { pstr_desc = Pstr_type (_, [ declaration ]); _ } ] -> declaration
  | _ -> Alcotest.fail "unexpected parsed structure"

let check_type_reference ~name_loc ~name core_type =
  check_location "type root" (ghost name_loc) core_type.ptyp_loc;
  match core_type.ptyp_desc with
  | Ptyp_constr ({ txt = Lident actual_name; loc }, [ _; _ ]) ->
      check_string "type name" name actual_name;
      check_location "type path" name_loc loc
  | _ -> Alcotest.fail "unexpected generated type reference"

let core_type_uses_type_name_location () =
  let declaration = declaration () in
  check_type_reference ~name_loc:declaration.ptype_name.loc
    ~name:declaration.ptype_name.txt
    (Util.core_type_of_type_declaration declaration)

let new_type_uses_type_name_location () =
  let declaration = declaration () in
  let core_type, new_declaration =
    Util.new_type_of_type_declaration declaration "abstract_pair"
  in
  check_type_reference ~name_loc:declaration.ptype_name.loc
    ~name:"abstract_pair" core_type;
  check_string "declaration name" "abstract_pair" new_declaration.ptype_name.txt

let () =
  Alcotest.run "AST derive util locations"
    [
      ( "locations",
        [
          Alcotest.test_case "core type uses type-name location" `Quick
            core_type_uses_type_name_location;
          Alcotest.test_case "new type uses type-name location" `Quick
            new_type_uses_type_name_location;
        ] );
    ]
