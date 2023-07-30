(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)

open Ppxlib

type attr = Parsetree.attribute
type t = attr list
type ('a, 'b) st = { get : 'a option; set : 'b option }

let assert_bool_lit (e : Parsetree.expression) =
  match e.pexp_desc with
  | Pexp_construct ({ txt = Lident "true"; _ }, None) -> true
  | Pexp_construct ({ txt = Lident "false"; _ }, None) -> false
  | _ ->
      Location.raise_errorf ~loc:e.pexp_loc
        "expect `true` or `false` in this field"

let warn_if_bs ~loc txt =
  match txt with
  | "bs" -> Bs_ast_invariant.warn ~loc Deprecated_uncurry_attribute
  | other ->
      if String.starts_with ~prefix:"bs." other then
        Bs_ast_invariant.warn ~loc Deprecated_attribute_namespace

let process_method_attributes_rev (attrs : t) =
  let exception Local of string in
  try
    let ret =
      List.fold_left
        (fun (st, acc)
             ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr) ->
          warn_if_bs ~loc txt;
          match txt with
          | "mel.get" | "bs.get" | "get" (* @bs.get{null; undefined}*) ->
              let result =
                match Ast_payload.ident_or_record_as_config payload with
                | Error s -> raise (Local s)
                | Ok config ->
                    List.fold_left
                      (fun (null, undefined) ({ txt; loc }, opt_expr) ->
                        match txt with
                        | "null" ->
                            ( (match opt_expr with
                              | None -> true
                              | Some e -> assert_bool_lit e),
                              undefined )
                        | "undefined" ->
                            ( null,
                              match opt_expr with
                              | None -> true
                              | Some e -> assert_bool_lit e )
                        | "nullable" -> (
                            match opt_expr with
                            | None -> (true, true)
                            | Some e ->
                                let v = assert_bool_lit e in
                                (v, v))
                        | _ -> Error.err ~loc Unsupported_predicates)
                      (false, false) config
              in

              ({ st with get = Some result }, acc)
          | "mel.set" | "bs.set" | "set" ->
              let result =
                match Ast_payload.ident_or_record_as_config payload with
                | Error s -> raise (Local s)
                | Ok config ->
                    List.fold_left
                      (fun _st ({ txt; loc }, opt_expr) ->
                        (*FIXME*)
                        if txt = "no_get" then
                          match opt_expr with
                          | None -> `No_get
                          | Some e ->
                              if assert_bool_lit e then `No_get else `Get
                        else Error.err ~loc Unsupported_predicates)
                      `Get config
              in
              (* properties -- void
                    [@@set{only}]
              *)
              ({ st with set = Some result }, acc)
          | _ -> (st, attr :: acc))
        ({ get = None; set = None }, [])
        attrs
    in
    Ok ret
  with Local s -> Error s

type attr_kind =
  | Nothing
  | Meth_callback of attr
  | Uncurry of attr
  | Method of attr

let process_attributes_rev (attrs : t) : attr_kind * t =
  List.fold_left
    (fun (st, acc) ({ attr_name = { txt; loc }; _ } as attr) ->
      warn_if_bs ~loc txt;
      match (txt, st) with
      | ("u" | "bs"), (Nothing | Uncurry _) ->
          (Uncurry attr, acc) (* TODO: warn unused/duplicated attribute *)
      | ("mel.this" | "bs.this" | "this"), (Nothing | Meth_callback _) ->
          (Meth_callback attr, acc)
      | ("mel.meth" | "bs.meth" | "meth"), (Nothing | Method _) ->
          (Method attr, acc)
      | ("u" | "bs" | "mel.this" | "bs.this" | "this"), _ ->
          Error.err ~loc Conflict_bs_bs_this_bs_meth
      | _, _ -> (st, attr :: acc))
    (Nothing, []) attrs

let process_pexp_fun_attributes_rev (attrs : t) =
  List.fold_left
    (fun (st, acc) ({ attr_name = { txt; loc }; _ } as attr) ->
      warn_if_bs ~loc txt;
      match txt with
      | "mel.open" | "bs.open" -> (true, acc)
      | _ -> (st, attr :: acc))
    (false, []) attrs

let process_bs (attrs : t) =
  List.fold_left
    (fun (st, acc) ({ attr_name = { txt; loc }; _ } as attr) ->
      warn_if_bs ~loc txt;
      match (txt, st) with
      | ("u" | "bs"), _ -> (true, acc)
      | _, _ -> (st, attr :: acc))
    (false, []) attrs

let is_bs (attr : attr) =
  match attr with
  | { attr_name = { Location.txt = "u" | "bs"; _ }; _ } -> true
  | _ -> false

let bs_get : attr =
  {
    attr_name = { txt = "mel.get"; loc = Location.none };
    attr_payload = Parsetree.PStr [];
    attr_loc = Location.none;
  }

let bs_get_index : attr =
  {
    attr_name = { txt = "mel.get_index"; loc = Location.none };
    attr_payload = Parsetree.PStr [];
    attr_loc = Location.none;
  }

let bs_get_arity : attr =
  {
    attr_name = { txt = "internal.arity"; loc = Location.none };
    attr_payload =
      PStr
        [
          {
            pstr_desc =
              Pstr_eval
                ( {
                    pexp_loc = Location.none;
                    pexp_loc_stack = [];
                    pexp_attributes = [];
                    pexp_desc =
                      Pexp_constant (Pconst_integer (string_of_int 1, None));
                  },
                  [] );
            pstr_loc = Location.none;
          };
        ];
    attr_loc = Location.none;
  }

let bs_set : attr =
  {
    attr_name = { txt = "mel.set"; loc = Location.none };
    attr_payload = PStr [];
    attr_loc = Location.none;
  }

let internal_expansive : attr =
  {
    attr_name = { txt = "internal.expansive"; loc = Location.none };
    attr_payload = PStr [];
    attr_loc = Location.none;
  }

let bs_return_undefined : attr =
  {
    attr_name = { txt = "mel.return"; loc = Location.none };
    attr_payload =
      PStr
        [
          {
            pstr_desc =
              Pstr_eval
                ( {
                    pexp_desc =
                      Pexp_ident
                        { txt = Lident "undefined_to_opt"; loc = Location.none };
                    pexp_loc = Location.none;
                    pexp_loc_stack = [];
                    pexp_attributes = [];
                  },
                  [] );
            pstr_loc = Location.none;
          };
        ];
    attr_loc = Location.none;
  }

type as_const_payload = Int of int | Str of string | Js_literal_str of string

let iter_process_bs_string_or_int_as (attrs : Parsetree.attributes) =
  let st = ref None in
  List.iter
    (fun ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr) ->
      match txt with
      | "mel.as" | "bs.as" | "as" ->
          if !st = None then (
            Bs_ast_invariant.mark_used_bs_attribute attr;
            match Ast_payload.is_single_int payload with
            | None -> (
                match payload with
                | PStr
                    [
                      {
                        pstr_desc =
                          Pstr_eval
                            ( {
                                pexp_desc =
                                  Pexp_constant
                                    (Pconst_string
                                      (s, _, ((None | Some "json") as dec)));
                                pexp_loc;
                                _;
                              },
                              _ );
                        _;
                      };
                    ] ->
                    if dec = None then st := Some (Str s)
                    else (
                      (match
                         Classify_function.classify
                           ~check:
                             (pexp_loc, Bs_flow_ast_utils.flow_deli_offset dec)
                           s
                       with
                      | Js_literal _ -> ()
                      | _ ->
                          Location.raise_errorf ~loc:pexp_loc
                            "an object literal expected");
                      st := Some (Js_literal_str s))
                | _ -> Error.err ~loc Expect_int_or_string_or_json_literal)
            | Some v -> st := Some (Int v))
          else Error.err ~loc Duplicated_bs_as
      | _ -> ())
    attrs;
  !st

(* duplicated @uncurry @string not allowed,
   it is worse in @uncurry since it will introduce
   inconsistency in arity
*)
let iter_process_bs_string_int_unwrap_uncurry (attrs : t) =
  let st = ref `Nothing in
  let assign v ({ attr_name = { loc; _ }; _ } as attr : attr) =
    if !st = `Nothing then (
      Bs_ast_invariant.mark_used_bs_attribute attr;
      st := v)
    else Error.err ~loc Conflict_attributes
  in
  List.iter
    (fun ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr) ->
      warn_if_bs ~loc txt;
      match txt with
      | "mel.string" | "bs.string" | "string" -> assign `String attr
      | "mel.int" | "bs.int" | "int" -> assign `Int attr
      | "mel.ignore" | "bs.ignore" | "ignore" -> assign `Ignore attr
      | "mel.unwrap" | "bs.unwrap" | "unwrap" -> assign `Unwrap attr
      | "mel.uncurry" | "bs.uncurry" | "uncurry" ->
          assign (`Uncurry (Ast_payload.is_single_int payload)) attr
      | _ -> ())
    attrs;
  !st

let iter_process_bs_string_as (attrs : t) : string option =
  let st = ref None in
  List.iter
    (fun ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr) ->
      match txt with
      | "mel.as" | "bs.as" | "as" ->
          if !st = None then (
            match Ast_payload.is_single_string payload with
            | None -> Error.err ~loc Expect_string_literal
            | Some (v, _dec) ->
                Bs_ast_invariant.mark_used_bs_attribute attr;
                st := Some v)
          else Error.err ~loc Duplicated_bs_as
      | _ -> ())
    attrs;
  !st

let external_attrs =
  [|
    "get";
    "set";
    "get_index";
    "return";
    "obj";
    "val";
    "module";
    "scope";
    "variadic";
    "send";
    "new";
    "set_index";
    Literals.gentype_import;
  |]

let first_char_special (x : string) =
  match String.unsafe_get x 0 with
  | '#' | '?' | '%' -> true
  | _ ->
      (* XXX(anmonteiro): Upstream considers "builtin" attributes ones that
         start with `?`. We keep the original terminology of `caml_` (and,
         incidentally, `nativeint_`). *)
      String.starts_with x ~prefix:"caml_"
      || String.starts_with x ~prefix:"nativeint_"

let prims_to_be_encoded (attrs : string list) =
  match attrs with
  | [] -> assert false (* normal val declaration *)
  | x :: _ when first_char_special x -> false
  | _ :: x :: _ when Ext_string.first_marshal_char x -> false
  | _ -> true

(**

   [@@inline]
   let a = 3

   [@@inline]
   let a : 3

   They are not considered externals, they are part of the language
*)

let rs_externals (attrs : t) pval_prim =
  match (attrs, pval_prim) with
  | _, [] -> false
  (* This is  val *)
  | [], _ ->
      (* No attributes found *)
      prims_to_be_encoded pval_prim
  | _, _ ->
      List.exists
        (fun { attr_name = { txt; loc = _ }; _ } ->
          String.starts_with txt ~prefix:"bs."
          || String.starts_with txt ~prefix:"mel."
          || Array.exists (fun (x : string) -> txt = x) external_attrs)
        attrs
      || prims_to_be_encoded pval_prim

let iter_process_bs_int_as (attrs : t) =
  let st = ref None in
  List.iter
    (fun ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr) ->
      warn_if_bs ~loc txt;
      match txt with
      | "mel.as" | "bs.as" | "as" ->
          if !st = None then (
            match Ast_payload.is_single_int payload with
            | None -> Error.err ~loc Expect_int_literal
            | Some _ as v ->
                Bs_ast_invariant.mark_used_bs_attribute attr;
                st := v)
          else Error.err ~loc Duplicated_bs_as
      | _ -> ())
    attrs;
  !st

let has_bs_optional (attrs : t) : bool =
  List.exists
    (fun ({ attr_name = { txt; loc }; _ } as attr) ->
      warn_if_bs ~loc txt;
      match txt with
      | "mel.optional" | "bs.optional" | "optional" ->
          Bs_ast_invariant.mark_used_bs_attribute attr;
          true
      | _ -> false)
    attrs

let is_inline : attr -> bool =
 fun { attr_name = { txt; loc }; _ } ->
  warn_if_bs ~loc txt;
  txt = "mel.inline" || txt = "bs.inline" || txt = "inline"

let has_inline_payload (attrs : t) = Ext_list.find_first attrs is_inline

(* We disable warning 61 in Melange externals since they're substantially
   different from OCaml externals. This warning doesn't make sense for a JS
   runtime *)
let unboxable_type_in_prim_decl : Parsetree.attribute =
  let open Ast_helper in
  {
    attr_name = { txt = "ocaml.warning"; loc = Location.none };
    attr_payload =
      PStr
        [
          Str.eval
            (Exp.constant
               (Pconst_string
                  ("-unboxable-type-in-prim-decl", Location.none, None)));
        ];
    attr_loc = Location.none;
  }
