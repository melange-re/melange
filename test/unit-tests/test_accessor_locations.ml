open Ppxlib
module Projector = Melange_ppx__Ast_derive__Ast_derive_projector

let check_location label expected actual =
  Alcotest.(check bool) label true (expected = actual)

let ghost loc = { loc with Location.loc_ghost = true }

let check_structure_item expected structure_item =
  let iterator =
    object
      inherit Ast_traverse.iter as super

      method! expression expression =
        check_location "expression" expected expression.pexp_loc;
        super#expression expression

      method! pattern pattern =
        check_location "pattern" expected pattern.ppat_loc;
        super#pattern pattern

      method! structure_item structure_item =
        check_location "structure item" expected structure_item.pstr_loc;
        super#structure_item structure_item

      method! value_binding value_binding =
        check_location "value binding" expected value_binding.pvb_loc;
        super#value_binding value_binding
    end
  in
  iterator#structure_item structure_item

let check_signature_item expected signature_item =
  let iterator =
    object
      inherit Ast_traverse.iter as super

      method! expression expression =
        check_location "expression" expected expression.pexp_loc;
        super#expression expression

      method! signature_item signature_item =
        check_location "signature item" expected signature_item.psig_loc;
        super#signature_item signature_item

      method! value_description value_description =
        check_location "value description" expected value_description.pval_loc;
        super#value_description value_description
    end
  in
  iterator#signature_item signature_item

let iter2_exn left right ~f =
  let rec loop left right =
    match (left, right) with
    | [], [] -> ()
    | x :: xs, y :: ys ->
        f x y;
        loop xs ys
    | _ -> Alcotest.fail "generated item count does not match source names"
  in
  loop left right

let declarations () =
  let lexbuf =
    Lexing.from_string
      {|type record = { field : int; another : string }
type variant = Nothing | Something of int * string
type abstract
|}
  in
  Location.init lexbuf "accessor_locations.ml";
  match Parse.implementation lexbuf with
  | [
   { pstr_desc = Pstr_type (_, [ record ]); _ };
   { pstr_desc = Pstr_type (_, [ variant ]); _ };
   { pstr_desc = Pstr_type (_, [ abstract ]); _ };
  ] ->
      (record, variant, abstract)
  | _ -> Alcotest.fail "unexpected parsed structure"

let declaration_name_locations declaration =
  match declaration.ptype_kind with
  | Ptype_record fields ->
      List.map ~f:(fun field -> ghost field.pld_name.loc) fields
  | Ptype_variant constructors ->
      List.map
        ~f:(fun constructor -> ghost constructor.pcd_name.loc)
        constructors
  | Ptype_abstract | Ptype_open -> [ declaration.ptype_name.loc ]

let generated_accessors_use_name_locations () =
  let record, variant, abstract = declarations () in
  List.iter
    ~f:(fun declaration ->
      let locations = declaration_name_locations declaration in
      iter2_exn (Projector.derive_structure [ declaration ]) locations
        ~f:(fun structure_item location ->
          check_structure_item location structure_item);
      iter2_exn (Projector.derive_signature [ declaration ]) locations
        ~f:(fun signature_item location ->
          check_signature_item location signature_item))
    [ record; variant; abstract ]

let suite =
  [
    Alcotest.test_case "generated accessors use name locations" `Quick
      generated_accessors_use_name_locations;
  ]
