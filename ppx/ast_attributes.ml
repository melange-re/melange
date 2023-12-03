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

open Import

type ('a, 'b) st = { get : 'a option; set : 'b option }

let assert_bool_lit (e : expression) =
  match e.pexp_desc with
  | Pexp_construct ({ txt = Lident "true"; _ }, None) -> true
  | Pexp_construct ({ txt = Lident "false"; _ }, None) -> false
  | _ ->
      Location.raise_errorf ~loc:e.pexp_loc
        "expected this expression to be a boolean literal (`true` or `false`)"

let warn_if_non_namespaced ~loc txt =
  if not (Mel_ast_invariant.is_mel_attribute txt) then
    Mel_ast_invariant.warn ~loc Deprecated_non_namespaced_attribute

let process_method_attributes_rev attrs =
  let exception Local of Location.t * string in
  try
    let ret =
      List.fold_left
        ~f:(fun
            (st, acc)
            ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr)
          ->
          match txt with
          | "mel.get" | "get" ->
              warn_if_non_namespaced ~loc txt;
              let result =
                match Ast_payload.ident_or_record_as_config payload with
                | Error s -> raise (Local (loc, s))
                | Ok config ->
                    List.fold_left
                      ~f:(fun (null, undefined) ({ txt; loc }, opt_expr) ->
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
                      ~init:(false, false) config
              in
              ({ st with get = Some result }, acc)
          | "mel.set" | "set" ->
              warn_if_non_namespaced ~loc txt;
              let result =
                match Ast_payload.ident_or_record_as_config payload with
                | Error s -> raise (Local (loc, s))
                | Ok config ->
                    List.fold_left
                      ~f:(fun _st ({ txt; loc }, opt_expr) ->
                        (*FIXME*)
                        if txt = "no_get" then
                          match opt_expr with
                          | None -> `No_get
                          | Some e ->
                              if assert_bool_lit e then `No_get else `Get
                        else Error.err ~loc Unsupported_predicates)
                      ~init:`Get config
              in
              (* properties -- void
                    [@@set{only}] *)
              ({ st with set = Some result }, acc)
          | _ -> (st, attr :: acc))
        ~init:({ get = None; set = None }, [])
        attrs
    in
    Ok ret
  with Local (loc, s) -> Error (loc, s)

type attr_kind =
  | Nothing
  | Meth_callback of attribute
  | Uncurry of { attribute : attribute; zero_arity : bool }
  | Method of attribute

let process_attributes_rev attrs : attr_kind * attribute list =
  List.fold_left
    ~f:(fun (st, acc) ({ attr_name = { txt; loc }; _ } as attribute) ->
      match (txt, st) with
      | "u", (Nothing | Uncurry _) ->
          (Uncurry { attribute; zero_arity = false }, acc)
          (* TODO: warn unused/duplicated attribute *)
      | "u0", (Nothing | Uncurry { zero_arity = true; _ }) ->
          (Uncurry { attribute; zero_arity = true }, acc)
      | "u0", Uncurry { zero_arity = false; _ } ->
          Location.raise_errorf ~loc "Cannot use both `[@u0]' and `[@u]'"
      | ("mel.this" | "this"), (Nothing | Meth_callback _) ->
          warn_if_non_namespaced ~loc txt;
          (Meth_callback attribute, acc)
      | ("mel.meth" | "meth"), (Nothing | Method _) ->
          warn_if_non_namespaced ~loc txt;
          (Method attribute, acc)
      | ("u" | "mel.this" | "this"), _ ->
          Error.err ~loc Conflict_u_mel_this_mel_meth
      | _, _ -> (st, attribute :: acc))
    ~init:(Nothing, []) attrs

let process_pexp_fun_attributes_rev attrs =
  List.fold_left
    ~f:(fun (st, acc) ({ attr_name = { txt; _ }; _ } as attr) ->
      match txt with "mel.open" -> (true, acc) | _ -> (st, attr :: acc))
    ~init:(false, []) attrs

let process_uncurried attrs =
  List.fold_left
    ~f:(fun (st, acc) ({ attr_name = { txt; _ }; _ } as attr) ->
      match (txt, st) with "u", _ -> (true, acc) | _, _ -> (st, attr :: acc))
    ~init:(false, []) attrs

let is_uncurried attr =
  match attr with
  | { attr_name = { Location.txt = "u"; _ }; _ } -> true
  | _ -> false

let mel_get =
  {
    attr_name = { txt = "mel.get"; loc = Location.none };
    attr_payload = PStr [];
    attr_loc = Location.none;
  }

let mel_get_index =
  {
    attr_name = { txt = "mel.get_index"; loc = Location.none };
    attr_payload = PStr [];
    attr_loc = Location.none;
  }

let mel_get_arity =
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

let mel_set =
  {
    attr_name = { txt = "mel.set"; loc = Location.none };
    attr_payload = PStr [];
    attr_loc = Location.none;
  }

let internal_expansive =
  let internal_expansive_label = "internal.expansive" in
  {
    attr_name = { txt = internal_expansive_label; loc = Location.none };
    attr_payload = PStr [];
    attr_loc = Location.none;
  }

let has_internal_expansive attrs =
  List.exists
    ~f:(fun { attr_name = { txt; _ }; _ } -> txt = "internal.expansive")
    attrs

let mel_return_undefined =
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

let iter_process_mel_string_or_int_as (attrs : attributes) =
  let st = ref None in
  List.iter
    ~f:(fun ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr) ->
      match txt with
      | "mel.as" | "as" ->
          warn_if_non_namespaced ~loc txt;
          if !st = None then (
            Mel_ast_invariant.mark_used_mel_attribute attr;
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
                         Melange_ffi.Classify_function.classify
                           ~check:
                             ( pexp_loc,
                               Melange_ffi.Flow_ast_utils.flow_deli_offset dec
                             )
                           s
                       with
                      | Js_literal _ -> ()
                      | _ ->
                          Location.raise_errorf ~loc:pexp_loc
                            "`[@mel.as {json| ... |json}]' only supports \
                             JavaScript literals");
                      st := Some (Js_literal_str s))
                | _ -> Error.err ~loc Expect_int_or_string_or_json_literal)
            | Some v -> st := Some (Int v))
          else Error.err ~loc Duplicated_mel_as
      | _ -> ())
    attrs;
  !st

(* duplicated @uncurry @string not allowed,
   it is worse in @uncurry since it will introduce
   inconsistency in arity *)
let iter_process_mel_string_int_unwrap_uncurry attrs =
  let st = ref `Nothing in
  let assign v ({ attr_name = { loc; _ }; _ } as attr) =
    if !st = `Nothing then (
      Mel_ast_invariant.mark_used_mel_attribute attr;
      st := v)
    else Error.err ~loc Conflict_attributes
  in
  List.iter
    ~f:(fun ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr) ->
      match txt with
      | "mel.string" | "string" ->
          warn_if_non_namespaced ~loc txt;
          assign `String attr
      | "mel.int" | "int" ->
          warn_if_non_namespaced ~loc txt;
          assign `Int attr
      | "mel.ignore" | "ignore" ->
          warn_if_non_namespaced ~loc txt;
          assign `Ignore attr
      | "mel.unwrap" | "unwrap" ->
          warn_if_non_namespaced ~loc txt;
          assign `Unwrap attr
      | "mel.uncurry" | "uncurry" ->
          warn_if_non_namespaced ~loc txt;
          assign (`Uncurry (Ast_payload.is_single_int payload)) attr
      | _ -> ())
    attrs;
  !st

let iter_process_mel_string_as attrs : string option =
  let st = ref None in
  List.iter
    ~f:(fun ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr) ->
      match txt with
      | "mel.as" | "as" ->
          warn_if_non_namespaced ~loc txt;
          if !st = None then (
            match Ast_payload.is_single_string payload with
            | None -> Error.err ~loc Expect_string_literal
            | Some (v, _dec) ->
                Mel_ast_invariant.mark_used_mel_attribute attr;
                st := Some v)
          else Error.err ~loc Duplicated_mel_as
      | _ -> ())
    attrs;
  !st

let first_char_special (x : string) =
  match x with
  | "" -> false
  | _ -> (
      match String.unsafe_get x 0 with
      | '#' | '?' | '%' -> true
      | _ ->
          (* XXX(anmonteiro): Upstream considers "builtin" attributes ones that
             start with `?`. We keep the original terminology of `caml_` (and,
             incidentally, `nativeint_`). *)
          String.starts_with x ~prefix:"caml_"
          || String.starts_with x ~prefix:"nativeint_")

let first_marshal_char (x : string) = x <> "" && String.unsafe_get x 0 = '\132'

let prims_to_be_encoded (attrs : string list) =
  match attrs with
  | [] -> assert false (* normal val declaration *)
  | x :: _ when first_char_special x -> false
  | _ :: x :: _ when first_marshal_char x -> false
  | _ -> true

(**

   [@@inline]
   let a = 3

   [@@inline]
   let a : 3

   They are not considered externals, they are part of the language
*)

let rs_externals attrs pval_prim =
  match (attrs, pval_prim) with
  | _, [] -> false
  (* This is  val *)
  | [], _ ->
      (* No attributes found *)
      prims_to_be_encoded pval_prim
  | _, _ ->
      Melange_ffi.External_ffi_attributes.has_mel_attributes
        (List.map ~f:(fun { attr_name = { txt; _ }; _ } -> txt) attrs)
      || prims_to_be_encoded pval_prim

let iter_process_mel_int_as attrs =
  let st = ref None in
  List.iter
    ~f:(fun ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr) ->
      match txt with
      | "mel.as" | "as" ->
          warn_if_non_namespaced ~loc txt;
          if !st = None then (
            match Ast_payload.is_single_int payload with
            | None -> Error.err ~loc Expect_int_literal
            | Some _ as v ->
                Mel_ast_invariant.mark_used_mel_attribute attr;
                st := v)
          else Error.err ~loc Duplicated_mel_as
      | _ -> ())
    attrs;
  !st

let has_mel_optional attrs : bool =
  List.exists
    ~f:(fun ({ attr_name = { txt; loc }; _ } as attr) ->
      match txt with
      | "mel.optional" | "optional" ->
          warn_if_non_namespaced ~loc txt;
          Mel_ast_invariant.mark_used_mel_attribute attr;
          true
      | _ -> false)
    attrs

let is_inline { attr_name = { txt; _ }; _ } =
  txt = "mel.inline" || txt = "inline"

let has_inline_payload attrs = List.find_opt ~f:is_inline attrs
let is_mel_as { attr_name = { txt; _ }; _ } = txt = "mel.as" || txt = "as"

let has_mel_as_payload attrs =
  List.fold_left
    ~f:(fun (attrs, found) attr ->
      match (is_mel_as attr, found) with
      | true, None -> (attrs, Some attr)
      | false, Some _ | false, None -> (attr :: attrs, found)
      | true, Some _ ->
          Location.raise_errorf ~loc:attr.attr_loc
            "Duplicate `%@mel.as' attribute found")
    ~init:([], None) attrs

let ocaml_warning w =
  {
    attr_name = { txt = "ocaml.warning"; loc = Location.none };
    attr_payload =
      PStr
        Ast_helper.
          [ Str.eval (Exp.constant (Pconst_string (w, Location.none, None))) ];
    attr_loc = Location.none;
  }

(* We disable warning 61 in Melange externals since they're substantially
   different from OCaml externals. This warning doesn't make sense for a JS
   runtime *)
let unboxable_type_in_prim_decl = ocaml_warning "-unboxable-type-in-prim-decl"
let ignored_extra_argument = ocaml_warning "-ignored-extra-argument"
