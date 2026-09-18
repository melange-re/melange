open Ppxlib

let parse_core_type source =
  let lexbuf = Lexing.from_string source in
  Location.init lexbuf "object_field.ml";
  Parse.core_type lexbuf

let object_fields (typ : core_type) =
  match typ.ptyp_desc with
  | Ptyp_object (fields, Closed) -> fields
  | Ptyp_object (_, Open) | _ -> Alcotest.fail "expected a closed object type"

let map_core_type =
  let mapper =
    object (self)
      inherit Ast_traverse.map as super

      method! core_type typ =
        Melange_ppx__Ast_core_type_class_type.typ_mapper (self, super#core_type)
          typ
    end
  in
  mapper#core_type

let check_location message expected actual =
  let position position = position.Lexing.pos_cnum in
  Alcotest.(check int)
    (message ^ " start")
    (position expected.Location.loc_start)
    (position actual.Location.loc_start);
  Alcotest.(check int)
    (message ^ " end")
    (position expected.loc_end)
    (position actual.loc_end);
  Alcotest.(check bool) (message ^ " ghost") expected.loc_ghost actual.loc_ghost

let check_object_field_locations source =
  let typ = parse_core_type source in
  let original_fields = object_fields typ in
  let mapped_fields = object_fields (map_core_type typ) in
  Alcotest.(check int)
    "field count"
    (List.length original_fields)
    (List.length mapped_fields);
  List.iter2 original_fields mapped_fields ~f:(fun original mapped ->
      check_location "object field" original.pof_loc mapped.pof_loc)

let test_preserves_object_field_locations () =
  check_object_field_locations "< bark : int; value : string >";
  check_object_field_locations "< value : int [@mel.get] >"

let suite =
  [
    Alcotest.test_case "preserve object field locations" `Quick
      test_preserves_object_field_locations;
  ]
