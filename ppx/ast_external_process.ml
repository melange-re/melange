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
module External_arg_spec = Melange_ffi.External_arg_spec
module External_ffi_types = Melange_ffi.External_ffi_types

(* record pattern match complete checker *)

let variant_unwrap =
  let rec variant_can_unwrap_aux (row_fields : row_field list) : bool =
    match row_fields with
    | [] -> true
    | { prf_desc = Rtag (_, true, []); _ } :: rest ->
        variant_can_unwrap_aux rest
    | { prf_desc = Rtag (_, false, [ _ ]); _ } :: rest ->
        variant_can_unwrap_aux rest
    | _ :: _ -> false
  in
  fun (row_fields : row_field list) : bool ->
    match row_fields with
    | [] -> false (* impossible syntax *)
    | xs -> variant_can_unwrap_aux xs

let infer_mel_as ~loc row_fields ~allow_no_payload =
  let mel_as_type =
    (* No `@mel.string` / `@mel.int` present. Try to infer `@mel.as`, if
       present, in polyvariants.

       https://github.com/melange-re/melange/issues/578 *)
    List.fold_left
      ~f:(fun mel_as_type { prf_attributes; prf_loc; _ } ->
        match List.filter ~f:Ast_attributes.is_mel_as prf_attributes with
        | [] -> mel_as_type
        | [ { attr_payload; attr_loc = loc; _ } ] -> (
            match
              ( mel_as_type,
                Ast_payload.is_single_string attr_payload,
                Ast_payload.is_single_int attr_payload )
            with
            | (`Nothing | `String), Some _, None -> `String
            | (`Nothing | `Int), None, Some _ -> `Int
            | (`Nothing | `String | `Int), None, None -> `Nothing
            | `String, None, Some _ -> Error.err ~loc Expect_string_literal
            | `Int, Some _, None -> Error.err ~loc Expect_int_literal
            | _, Some _, Some _ -> assert false)
        | _ :: _ -> Error.err ~loc:prf_loc Duplicated_mel_as)
      ~init:`Nothing row_fields
  in
  match mel_as_type with
  | `Nothing -> External_arg_spec.Nothing
  | `String ->
      Ast_polyvar.map_row_fields_into_strings row_fields ~loc ~allow_no_payload
  | `Int ->
      Ast_polyvar.map_row_fields_into_ints row_fields ~loc ~allow_no_payload

(* TODO: [nolabel] is only used once turn Nothing into Unit, refactor later *)
let spec_of_ptyp ~(nolabel : bool) (ptyp : core_type) : External_arg_spec.attr =
  let ptyp_desc = ptyp.ptyp_desc in
  match
    Ast_attributes.iter_process_mel_string_int_unwrap_uncurry
      ptyp.ptyp_attributes
  with
  | `String -> (
      match ptyp_desc with
      | Ptyp_variant (row_fields, Closed, None) ->
          Ast_polyvar.map_row_fields_into_strings row_fields ~loc:ptyp.ptyp_loc
            ~allow_no_payload:false
      | _ -> Error.err ~loc:ptyp.ptyp_loc Invalid_mel_string_type)
  | `Ignore -> Ignore
  | `Int -> (
      match ptyp_desc with
      | Ptyp_variant (row_fields, Closed, None) ->
          Ast_polyvar.map_row_fields_into_ints row_fields ~loc:ptyp.ptyp_loc
            ~allow_no_payload:false
      | _ -> Error.err ~loc:ptyp.ptyp_loc Invalid_mel_int_type)
  | `Unwrap -> (
      match ptyp_desc with
      | Ptyp_variant (row_fields, Closed, _) when variant_unwrap row_fields ->
          (* Unwrap attribute can only be attached to things like
             `[a of a0 | b of b0]` *)
          Unwrap
            (infer_mel_as ~loc:ptyp.ptyp_loc row_fields ~allow_no_payload:true)
      | _ -> Error.err ~loc:ptyp.ptyp_loc Invalid_mel_unwrap_type)
  | `Uncurry opt_arity -> (
      let real_arity = Ast_core_type.get_uncurry_arity ptyp in
      match (opt_arity, real_arity) with
      | Some arity, None -> Fn_uncurry_arity arity
      | None, None -> Error.err ~loc:ptyp.ptyp_loc Cannot_infer_arity_by_syntax
      | None, Some arity -> Fn_uncurry_arity arity
      | Some arity, Some n ->
          if n <> arity then
            Error.err ~loc:ptyp.ptyp_loc
              (Inconsistent_arity { uncurry_attribute = arity; real = n })
          else Fn_uncurry_arity arity)
  | `Nothing -> (
      match ptyp_desc with
      | Ptyp_constr ({ txt = Lident "unit"; _ }, []) ->
          if nolabel then Extern_unit else Nothing
      | Ptyp_variant (row_fields, Closed, None) ->
          infer_mel_as ~loc:ptyp.ptyp_loc row_fields ~allow_no_payload:false
      | _ -> Nothing)

let const_payload_cst = function
  | Ast_attributes.Int i ->
      (* This type is used in obj only to construct obj type*)
      External_arg_spec.Arg_cst (External_arg_spec.cst_int i)
  | Str i -> Arg_cst (External_arg_spec.cst_string i)
  | Js_literal_str s -> Arg_cst (External_arg_spec.cst_obj_literal s)

(* is_optional = false *)
let refine_arg_type ~(nolabel : bool) (ptyp : core_type) :
    External_arg_spec.attr =
  match ptyp.ptyp_desc with
  | Ptyp_any -> (
      match
        Ast_attributes.iter_process_mel_string_or_int_as ptyp.ptyp_attributes
      with
      | None -> spec_of_ptyp ~nolabel ptyp
      | Some cst ->
          (* (_[@as ])*)
          Mel_ast_invariant.warn_discarded_unused_attributes
            ptyp.ptyp_attributes;
          const_payload_cst cst)
  | _ ->
      (* ([`a|`b] [@string]) *)
      spec_of_ptyp ~nolabel ptyp

let refine_obj_arg_type ~(nolabel : bool) (ptyp : core_type) :
    External_arg_spec.attr =
  match ptyp.ptyp_desc with
  | Ptyp_any -> (
      match
        Ast_attributes.iter_process_mel_string_or_int_as ptyp.ptyp_attributes
      with
      | None -> Error.err ~loc:ptyp.ptyp_loc Invalid_underscore_type_in_external
      | Some cst ->
          (* (_[@as ])*)
          Mel_ast_invariant.warn_discarded_unused_attributes
            ptyp.ptyp_attributes;
          const_payload_cst cst)
  | _ ->
      (* ([`a|`b] [@string]) *)
      spec_of_ptyp ~nolabel ptyp

(* Given the type of argument, process its [mel.*] attribute and new type,
    The new type is currently used to reconstruct the external type
    and result type in [@@obj]
    They are not the same though, for example
    {[
      external f : hi:([ `hi | `lo ] [@string]) -> unit -> _ = "" [@@obj]
    ]}
    The result type would be [ hi:string ] *)
let get_opt_arg_type (ptyp : core_type) : External_arg_spec.attr =
  match ptyp.ptyp_desc with
  | Ptyp_any ->
      (* (_[@as ])*)
      (* external f : ?x:_ -> y:int -> _ = "" [@@obj] is not allowed *)
      Error.err ~loc:ptyp.ptyp_loc Invalid_underscore_type_in_external
  | _ ->
      (* ([`a|`b] [@@string]) *)
      spec_of_ptyp ~nolabel:false ptyp

(*
   [@@module "react"]
   [@@module "react"]
   ---
   [@@module "@" "react"]
   [@@module "@" "react"]

   They should have the same module name

   TODO: we should emit an warning if we bind
   two external files to the same module name
*)
type bundle_source =
  [ `Nm_payload of string (* from payload [@@val "xx" ]*)
  | `Nm_external of string lazy_t (* from "" in external *) ]

let string_of_bundle_source (x : bundle_source) =
  match x with `Nm_payload x | `Nm_external (lazy x) -> x

type name_source = [ bundle_source | `Nm_na ]

type external_desc = {
  external_module_name : External_ffi_types.external_module_name option;
  module_as_val : External_ffi_types.external_module_name option;
  val_send : name_source;
  val_send_pipe : core_type option;
  variadic : bool; (* mutable *)
  scopes : string list;
  set_index : bool; (* mutable *)
  get_index : bool;
  new_name : name_source;
  call_name : name_source;
  set_name : name_source;
  get_name : name_source;
  mk_obj : bool;
  return_wrapper : External_ffi_types.return_wrapper;
}

let init_st =
  {
    external_module_name = None;
    module_as_val = None;
    val_send = `Nm_na;
    val_send_pipe = None;
    variadic = false;
    scopes = [];
    set_index = false;
    get_index = false;
    new_name = `Nm_na;
    call_name = `Nm_na;
    set_name = `Nm_na;
    get_name = `Nm_na;
    mk_obj = false;
    return_wrapper = Return_unset;
  }

let return_wrapper loc (txt : string) : External_ffi_types.return_wrapper =
  match txt with
  | "undefined_to_opt" -> Return_undefined_to_opt
  | "null_to_opt" -> Return_null_to_opt
  | "nullable" | "null_undefined_to_opt" -> Return_null_undefined_to_opt
  | "identity" -> Return_identity
  | _ -> Error.err ~loc Not_supported_directive_in_mel_return

exception Not_handled_external_attribute

(* The processed attributes will be dropped *)
let parse_external_attributes (prim_name_check : string)
    (prim_name_or_pval_prim : bundle_source) (prim_attributes : attribute list)
    : attribute list * external_desc =
  (* shared by `[@@val]`, `[@@send]`,
     `[@@set]`, `[@@get]` , `[@@new]`
     `[@@mel.send.pipe]` does not use it
  *)
  let name_from_payload_or_prim ~loc (payload : payload) : name_source =
    match payload with
    | PStr [] -> (prim_name_or_pval_prim :> name_source)
    (* It is okay to have [@@val] without payload *)
    | _ -> (
        match Ast_payload.is_single_string payload with
        | Some (val_name, _) -> `Nm_payload val_name
        | None -> Location.raise_errorf ~loc "Invalid payload")
  in

  List.fold_left
    ~f:(fun
        (attrs, st)
        ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr)
      ->
      (* TODO(anmonteiro): re-enable when we enable gentype *)
      (*
      if txt = Literals.gentype_import then
        let bundle =
          let input_name = !Ocaml_common.Location.input_name in
          "./"
          ^ Filename.remove_extension (Filename.basename input_name)
          ^ ".gen"
        in
        ( attr :: attrs,
          {
            st with
            external_module_name =
              Some { bundle; module_bind_name = Phint_nothing };
          } )
      else *)
      let action () =
        match txt with
        | "mel.module" | "bs.module" | "module" -> (
            Ast_attributes.error_if_bs_or_non_namespaced ~loc txt;
            match Ast_payload.assert_strings loc payload with
            | [ bundle ] ->
                {
                  st with
                  external_module_name =
                    Some { bundle; module_bind_name = Phint_nothing };
                }
            | [ bundle; bind_name ] ->
                {
                  st with
                  external_module_name =
                    Some { bundle; module_bind_name = Phint_name bind_name };
                }
            | [] ->
                {
                  st with
                  module_as_val =
                    Some
                      {
                        bundle =
                          string_of_bundle_source
                            (prim_name_or_pval_prim :> bundle_source);
                        module_bind_name = Phint_nothing;
                      };
                }
            | _ ->
                Location.raise_errorf ~loc
                  "`[%@mel.module ..]' expects, at most, a tuple of two \
                   strings (module name, variable name)")
        | "mel.scope" | "bs.scope" | "scope" -> (
            Ast_attributes.error_if_bs_or_non_namespaced ~loc txt;
            match Ast_payload.assert_strings loc payload with
            | [] ->
                Location.raise_errorf ~loc
                  "`[%@mel.scope ..]' expects a tuple of strings in its payload"
            (* We need err on empty scope, so we can tell the difference
               between unset/set *)
            | scopes -> { st with scopes })
        | "mel.splice" | "bs.splice" | "splice" ->
            Location.raise_errorf ~loc
              "`%s' has been removed. Use `@mel.variadic' instead." txt
        | "mel.variadic" | "bs.variadic" | "variadic" ->
            Ast_attributes.error_if_bs_or_non_namespaced ~loc txt;
            { st with variadic = true }
        | "mel.send" | "bs.send" | "send" ->
            Ast_attributes.error_if_bs_or_non_namespaced ~loc txt;
            { st with val_send = name_from_payload_or_prim ~loc payload }
        | "mel.send.pipe" | "bs.send.pipe" | "send.pipe" ->
            Ast_attributes.error_if_bs_or_non_namespaced ~loc txt;
            {
              st with
              val_send_pipe =
                (match payload with
                | PTyp x -> Some x
                | _ ->
                    Location.raise_errorf ~loc
                      "expected a type after `[%@mel.send.pipe]', e.g. \
                       `[%@mel.send.pipe: t]'");
            }
        | "mel.set" | "bs.set" | "set" ->
            Ast_attributes.error_if_bs_or_non_namespaced ~loc txt;
            { st with set_name = name_from_payload_or_prim ~loc payload }
        | "mel.get" | "bs.get" | "get" ->
            Ast_attributes.error_if_bs_or_non_namespaced ~loc txt;
            { st with get_name = name_from_payload_or_prim ~loc payload }
        | "mel.new" | "bs.new" | "new" ->
            Ast_attributes.error_if_bs_or_non_namespaced ~loc txt;
            { st with new_name = name_from_payload_or_prim ~loc payload }
        | "mel.set_index" | "bs.set_index" | "set_index" ->
            Ast_attributes.error_if_bs_or_non_namespaced ~loc txt;
            if String.length prim_name_check <> 0 then
              Location.raise_errorf ~loc
                "`%@mel.set_index' requires its `external' payload to be the \
                 empty string";
            { st with set_index = true }
        | "mel.get_index" | "bs.get_index" | "get_index" ->
            Ast_attributes.error_if_bs_or_non_namespaced ~loc txt;
            if String.length prim_name_check <> 0 then
              Location.raise_errorf ~loc
                "`%@mel.get_index' requires its `external' payload to be the \
                 empty string";
            { st with get_index = true }
        | "mel.obj" | "bs.obj" | "obj" ->
            Ast_attributes.error_if_bs_or_non_namespaced ~loc txt;
            { st with mk_obj = true }
        | "mel.return" | "bs.return" | "return" -> (
            Ast_attributes.error_if_bs_or_non_namespaced ~loc txt;
            match Ast_payload.ident_or_record_as_config payload with
            | Ok [ ({ txt; _ }, None) ] ->
                { st with return_wrapper = return_wrapper loc txt }
            | Ok _ -> Error.err ~loc Not_supported_directive_in_mel_return
            | Error s -> Location.raise_errorf ~loc "%s" s)
        | _ -> raise_notrace Not_handled_external_attribute
      in
      try (attrs, action ())
      with Not_handled_external_attribute -> (attr :: attrs, st))
    ~init:([], init_st) prim_attributes

let has_mel_uncurry (attrs : attribute list) =
  List.exists
    ~f:(fun { attr_name = { txt; loc }; _ } ->
      match txt with
      | "mel.uncurry" -> true
      | "bs.uncurry" | "uncurry" ->
          Ast_attributes.error_if_bs_or_non_namespaced ~loc txt;
          false
      | _ -> false)
    attrs

let is_user_option ty =
  match ty.ptyp_desc with
  | Ptyp_constr
      ({ txt = Lident "option" | Ldot (Lident "*predef*", "option"); _ }, [ _ ])
    ->
      true
  | _ -> false

let check_return_wrapper loc (wrapper : External_ffi_types.return_wrapper)
    result_type =
  match wrapper with
  | Return_identity -> wrapper
  | Return_unset ->
      if Ast_core_type.is_unit result_type then Return_replaced_with_unit
      else wrapper
  | Return_undefined_to_opt | Return_null_to_opt | Return_null_undefined_to_opt
    ->
      if is_user_option result_type then wrapper
      else Error.err ~loc Expect_opt_in_mel_return_to_opt
  | Return_replaced_with_unit ->
      assert false (* Not going to happen from user input*)

type response = {
  pval_type : core_type;
  pval_prim : string list;
  pval_attributes : attributes;
  dont_inline_cross_module : bool;
}

type param_type = {
  label : Asttypes.arg_label;
  ty : core_type;
  attr : attributes;
  loc : location;
}

let mk_fn_type (new_arg_types_ty : param_type list) (result : core_type) :
    core_type =
  List.fold_right
    ~f:(fun { label; ty; attr; loc } acc ->
      {
        ptyp_desc = Ptyp_arrow (label, ty, acc);
        ptyp_loc = loc;
        ptyp_loc_stack = [ loc ];
        ptyp_attributes = attr;
      })
    new_arg_types_ty ~init:result

let process_obj (loc : Location.t) (st : external_desc) (prim_name : string)
    (arg_types_ty : param_type list) (result_type : core_type) :
    core_type * External_ffi_types.t =
  match st with
  | {
   external_module_name = None;
   module_as_val = None;
   val_send = `Nm_na;
   val_send_pipe = None;
   variadic = false;
   new_name = `Nm_na;
   call_name = `Nm_na;
   set_name = `Nm_na;
   get_name = `Nm_na;
   get_index = false;
   return_wrapper = Return_unset;
   set_index = false;
   mk_obj = _;
   scopes = [];
 (* wrapper does not work with @obj
    TODO: better error message *)
  } ->
      if String.length prim_name > 0 then
        Location.raise_errorf ~loc
          "`[%@mel.obj]' requires its `external' payload to be the empty string"
      else
        let arg_kinds, new_arg_types_ty, (result_types : object_field list) =
          List.fold_right
            ~f:(fun
                param_type
                (arg_labels, (arg_types : param_type list), result_types)
              ->
              let new_arg_label, new_arg_types, output_tys =
                let arg_label =
                  match (param_type.label, param_type.ty.ptyp_desc) with
                  | Nolabel, _ | _, Ptyp_any -> param_type.label
                  | _, _ -> (
                      match
                        Ast_attributes.iter_process_mel_string_as
                          param_type.ty.ptyp_attributes
                      with
                      | Some name -> (
                          match param_type.label with
                          | Labelled _ -> Labelled name
                          | Optional _ -> Optional name
                          | Nolabel -> param_type.label)
                      | None -> param_type.label)
                in
                let loc = param_type.loc in
                let ty = param_type.ty in
                match arg_label with
                | Nolabel -> (
                    match ty.ptyp_desc with
                    | Ptyp_constr ({ txt = Lident "unit"; _ }, []) ->
                        ( External_arg_spec.empty_kind Extern_unit,
                          param_type :: arg_types,
                          result_types )
                    | _ ->
                        Location.raise_errorf ~loc:ty.ptyp_loc
                          "`[%@mel.obj]' external declaration arguments must \
                           be one of:\n\
                           - a labelled argument\n\
                           - an optionally labelled argument\n\
                           - `unit' as the final argument")
                | Labelled name -> (
                    let obj_arg_type = refine_obj_arg_type ~nolabel:false ty in
                    match obj_arg_type with
                    | Ignore ->
                        ( External_arg_spec.empty_kind obj_arg_type,
                          param_type :: arg_types,
                          result_types )
                    | Arg_cst _ ->
                        let s = Melange_ffi.Lam_methname.translate name in
                        ( {
                            arg_label = External_arg_spec.Obj_label.obj s;
                            arg_type = obj_arg_type;
                          },
                          arg_types,
                          (* ignored in [arg_types], reserved in [result_types] *)
                          result_types )
                    | Nothing | Unwrap _ ->
                        let s = Melange_ffi.Lam_methname.translate name in
                        ( {
                            arg_label = External_arg_spec.Obj_label.obj s;
                            arg_type = obj_arg_type;
                          },
                          param_type :: arg_types,
                          Ast_helper.Of.tag { Asttypes.txt = name; loc } ty
                          :: result_types )
                    | Int _ ->
                        let s = Melange_ffi.Lam_methname.translate name in
                        ( {
                            arg_label = External_arg_spec.Obj_label.obj s;
                            arg_type = obj_arg_type;
                          },
                          param_type :: arg_types,
                          Ast_helper.Of.tag
                            { Asttypes.txt = name; loc }
                            [%type: int]
                          :: result_types )
                    | Poly_var_string _ ->
                        let s = Melange_ffi.Lam_methname.translate name in
                        ( {
                            arg_label = External_arg_spec.Obj_label.obj s;
                            arg_type = obj_arg_type;
                          },
                          param_type :: arg_types,
                          Ast_helper.Of.tag
                            { Asttypes.txt = name; loc }
                            [%type: string]
                          :: result_types )
                    | Fn_uncurry_arity _ ->
                        Location.raise_errorf ~loc:ty.ptyp_loc
                          "`[%@mel.uncurry]' can't be used within `[@mel.obj]'"
                    | Extern_unit -> assert false
                    | Poly_var _ ->
                        raise
                          (Location.raise_errorf ~loc
                             "`[%@mel.obj]' must not be used with labelled \
                              polymorphic variants carrying payloads"
                             name))
                | Optional name -> (
                    let obj_arg_type = get_opt_arg_type ty in
                    match obj_arg_type with
                    | Ignore ->
                        ( External_arg_spec.empty_kind obj_arg_type,
                          param_type :: arg_types,
                          result_types )
                    | Nothing | Unwrap _ ->
                        let s = Melange_ffi.Lam_methname.translate name in
                        (* XXX(anmonteiro): it's unsafe to just read the type
                             of the labelled argument declaration, since it
                             could be `'a` in the implementation, and e.g.
                             `bool` in the interface. See
                             https://github.com/melange-re/melange/pull/58 for
                             a test case. *)
                        ( {
                            arg_label =
                              External_arg_spec.Obj_label.optional
                                ~for_sure_no_nested_option:false s;
                            arg_type = obj_arg_type;
                          },
                          param_type :: arg_types,
                          Ast_helper.Of.tag
                            { Asttypes.txt = name; loc }
                            (Ast_helper.Typ.constr ~loc
                               { txt = Ast_literal.js_undefined; loc }
                               [ ty ])
                          :: result_types )
                    | Int _ ->
                        let s = Melange_ffi.Lam_methname.translate name in
                        ( {
                            arg_label =
                              External_arg_spec.Obj_label.optional
                                ~for_sure_no_nested_option:true s;
                            arg_type = obj_arg_type;
                          },
                          param_type :: arg_types,
                          Ast_helper.Of.tag
                            { Asttypes.txt = name; loc }
                            (Ast_helper.Typ.constr ~loc
                               { txt = Ast_literal.js_undefined; loc }
                               [ [%type: int] ])
                          :: result_types )
                    | Poly_var_string _ ->
                        let s = Melange_ffi.Lam_methname.translate name in
                        ( {
                            arg_label =
                              External_arg_spec.Obj_label.optional
                                ~for_sure_no_nested_option:true s;
                            arg_type = obj_arg_type;
                          },
                          param_type :: arg_types,
                          Ast_helper.Of.tag
                            { Asttypes.txt = name; loc }
                            (Ast_helper.Typ.constr ~loc
                               { txt = Ast_literal.js_undefined; loc }
                               [ [%type: string] ])
                          :: result_types )
                    | Arg_cst _ ->
                        Location.raise_errorf ~loc
                          "`[%@mel.as ..]' is not supported within optionally \
                           labelled arguments yet"
                    | Fn_uncurry_arity _ ->
                        Location.raise_errorf ~loc
                          "`[%@mel.uncurry]' can't be used within `[@mel.obj]'"
                    | Extern_unit -> assert false
                    | Poly_var _ ->
                        Location.raise_errorf ~loc
                          "`[%@mel.obj]' must not be used with optionally \
                           labelled polymorphic variants carrying payloads"
                          name)
              in
              (new_arg_label :: arg_labels, new_arg_types, output_tys))
            arg_types_ty ~init:([], [], [])
        in
        let result =
          let open Ast_helper in
          match result_type.ptyp_desc with
          (* TODO: do we need do some error checking here *)
          (* result type cannot be labeled *)
          | Ptyp_any ->
              Ast_core_type.to_js_type ~loc
                (Typ.object_ ~loc result_types Closed)
          | _ -> result_type
        in
        ( mk_fn_type new_arg_types_ty result,
          External_ffi_types.ffi_obj_create arg_kinds )
  | _ ->
      Location.raise_errorf ~loc
        "Found an attribute that conflicts with `[%@mel.obj]'"

let external_desc_of_non_obj (loc : Location.t) (st : external_desc)
    (prim_name_or_pval_prim : bundle_source) (arg_type_specs_length : int)
    arg_types_ty
    (arg_type_specs :
      External_arg_spec.Arg_label.t External_arg_spec.param list) :
    External_ffi_types.external_spec =
  match st with
  | {
   set_index = true;
   external_module_name = None;
   module_as_val = None;
   val_send = `Nm_na;
   val_send_pipe = None;
   variadic = false;
   scopes;
   get_index = false;
   new_name = `Nm_na;
   call_name = `Nm_na;
   set_name = `Nm_na;
   get_name = `Nm_na;
   return_wrapper = _;
   mk_obj = _;
  } ->
      if arg_type_specs_length = 3 then Js_set_index { scopes }
      else
        Location.raise_errorf ~loc
          "`[%@mel.set_index]' requires a function of 3 arguments: `'t -> 'key \
           -> 'value -> unit'"
  | { set_index = true; _ } ->
      Error.err ~loc
        (Conflict_ffi_attribute
           "Found an attribute that conflicts with `[@mel.set_index]'")
  | {
   get_index = true;
   external_module_name = None;
   module_as_val = None;
   val_send = `Nm_na;
   val_send_pipe = None;
   variadic = false;
   scopes;
   new_name = `Nm_na;
   call_name = `Nm_na;
   set_name = `Nm_na;
   get_name = `Nm_na;
   set_index = false;
   mk_obj = _;
   return_wrapper = _;
  } ->
      if arg_type_specs_length = 2 then Js_get_index { scopes }
      else
        Location.raise_errorf ~loc
          "`[%@mel.get_index]' requires a function of 2 arguments: `'t -> 'key \
           -> 'value'"
  | { get_index = true; _ } ->
      Error.err ~loc
        (Conflict_ffi_attribute
           "Found an attribute that conflicts with `@mel.get_index'")
  | {
   module_as_val = Some external_module_name;
   get_index = false;
   new_name;
   external_module_name = None;
   val_send = `Nm_na;
   val_send_pipe = None;
   scopes = [];
   (* module as var does not need scopes *)
   variadic;
   call_name = `Nm_na;
   set_name = `Nm_na;
   get_name = `Nm_na;
   set_index = false;
   return_wrapper = _;
   mk_obj = _;
  } -> (
      match (arg_types_ty, new_name) with
      | [], `Nm_na -> Js_module_as_var external_module_name
      | _, `Nm_na -> Js_module_as_fn { variadic; external_module_name }
      | _, `Nm_external _ -> Js_module_as_class external_module_name
      | _, `Nm_payload _ ->
          Location.raise_errorf ~loc
            "`[%@mel.new]' doesn't expect an attribute payload")
  | { module_as_val = Some _; get_index; val_send; _ } ->
      let reason =
        match (get_index, val_send) with
        | true, _ ->
            "`@mel.get_index' doesn't import from a module. `@mel.module' is \
             not necessary here."
        | _, #bundle_source ->
            "`@mel.send' doesn't import from a module. `@mel.module` is not \
             necessary here."
        | _ -> "Found an attribute that conflicts with `@mel.module'."
      in
      Error.err ~loc (Conflict_ffi_attribute reason)
  | {
   get_name = `Nm_na;
   call_name = `Nm_na;
   module_as_val = None;
   set_index = false;
   get_index = false;
   val_send = `Nm_na;
   val_send_pipe = None;
   new_name = `Nm_na;
   set_name = `Nm_na;
   external_module_name = None;
   variadic;
   scopes;
   mk_obj = _;
   (* mk_obj is always false *)
   return_wrapper = _;
  } ->
      let name = string_of_bundle_source prim_name_or_pval_prim in
      if arg_type_specs_length = 0 then
        (*
         {[
           external ff : int -> int [@bs] = "" [@@module "xx"]
         ]}
         FIXME: variadic is not supported here
      *)
        Js_var { name; external_module_name = None; scopes }
      else Js_call { variadic; name; external_module_name = None; scopes }
  | {
   call_name = `Nm_external (lazy name) | `Nm_payload name;
   variadic;
   scopes;
   external_module_name;
   module_as_val = None;
   val_send = `Nm_na;
   val_send_pipe = None;
   set_index = false;
   get_index = false;
   new_name = `Nm_na;
   set_name = `Nm_na;
   get_name = `Nm_na;
   mk_obj = _;
   return_wrapper = _;
  } ->
      if arg_type_specs_length = 0 then
        (*
           {[
             external ff : int -> int = "" [@@module "xx"]
           ]}
        *)
        Js_var { name; external_module_name; scopes }
        (*FIXME: variadic is not supported here *)
      else Js_call { variadic; name; external_module_name; scopes }
  | {
   variadic;
   scopes;
   external_module_name = Some _ as external_module_name;
   call_name = `Nm_na;
   module_as_val = None;
   val_send = `Nm_na;
   val_send_pipe = None;
   set_index = false;
   get_index = false;
   new_name = `Nm_na;
   set_name = `Nm_na;
   get_name = `Nm_na;
   mk_obj = _;
   return_wrapper = _;
  } ->
      let name = string_of_bundle_source prim_name_or_pval_prim in
      if arg_type_specs_length = 0 then
        (*
         {[
           external ff : int = "" [@@module "xx"]
         ]}
      *)
        Js_var { name; external_module_name; scopes }
      else Js_call { variadic; name; external_module_name; scopes }
  | {
   val_send = `Nm_external (lazy name) | `Nm_payload name;
   variadic;
   scopes;
   val_send_pipe = None;
   call_name = `Nm_na;
   module_as_val = None;
   set_index = false;
   get_index = false;
   new_name;
   set_name = `Nm_na;
   get_name = `Nm_na;
   external_module_name = None;
   mk_obj = _;
   return_wrapper = _;
  } -> (
      (* PR #2162 - since when we assemble arguments the first argument in
         [@@send] is ignored *)
      match (arg_type_specs, new_name) with
      | [], _ ->
          Location.raise_errorf ~loc
            "`[%@mel.send]` requires a function with at least one argument"
      | { arg_type = Arg_cst _; arg_label = _ } :: _, _ ->
          Location.raise_errorf ~loc
            "`[%@mel.send]`'s first argument must not be a constant"
      | _, `Nm_payload _ ->
          Location.raise_errorf ~loc
            "`[%@mel.send]' doesn't expect an attribute payload"
      | _ :: _, `Nm_na ->
          Js_send { variadic; name; scopes; pipe = false; new_ = false }
      | _ :: _, `Nm_external _ ->
          Js_send { variadic; name; scopes; pipe = false; new_ = true })
  | { val_send = #bundle_source; _ } ->
      Location.raise_errorf ~loc
        "Found an attribute that can't be used with `[%@mel.send]'"
  | {
   val_send_pipe = Some _;
   (* variadic = (false as variadic); *)
   val_send = `Nm_na;
   call_name = `Nm_na;
   module_as_val = None;
   set_index = false;
   get_index = false;
   new_name;
   set_name = `Nm_na;
   get_name = `Nm_na;
   external_module_name = None;
   mk_obj = _;
   return_wrapper = _;
   scopes;
   variadic;
  } -> (
      match new_name with
      | `Nm_payload _ ->
          Location.raise_errorf ~loc
            "`[%@mel.new]' doesn't expect an attribute payload"
      | `Nm_na ->
          (* can be one argument *)
          Js_send
            {
              variadic;
              name = string_of_bundle_source prim_name_or_pval_prim;
              scopes;
              pipe = true;
              new_ = false;
            }
      | `Nm_external _ ->
          Js_send
            {
              variadic;
              name = string_of_bundle_source prim_name_or_pval_prim;
              scopes;
              pipe = true;
              new_ = true;
            })
  | { val_send_pipe = Some _; _ } ->
      Location.raise_errorf ~loc
        "Found an attribute that can't be used with `[%@mel.send.pipe]'"
  | {
   new_name = `Nm_external (lazy name);
   external_module_name;
   call_name = `Nm_na;
   module_as_val = None;
   set_index = false;
   get_index = false;
   val_send = `Nm_na;
   val_send_pipe = None;
   set_name = `Nm_na;
   get_name = `Nm_na;
   variadic;
   scopes;
   mk_obj = _;
   return_wrapper = _;
  } ->
      Js_new { name; external_module_name; variadic; scopes }
  | { new_name = #bundle_source; _ } ->
      Error.err ~loc
        (Conflict_ffi_attribute
           "Found an attribute that can't be used with `@mel.new'")
  | {
   set_name = `Nm_external (lazy name) | `Nm_payload name;
   call_name = `Nm_na;
   module_as_val = None;
   set_index = false;
   get_index = false;
   val_send = `Nm_na;
   val_send_pipe = None;
   new_name = `Nm_na;
   get_name = `Nm_na;
   external_module_name = None;
   variadic = false;
   mk_obj = _;
   return_wrapper = _;
   scopes;
  } ->
      if arg_type_specs_length = 2 then Js_set { name; scopes }
      else
        Location.raise_errorf ~loc
          "`[%@mel.set]' requires a function of two arguments"
  | { set_name = #bundle_source; _ } ->
      Location.raise_errorf ~loc
        "Found an attribute that can't be used with `[%@mel.set]'"
  | {
   get_name = `Nm_external (lazy name) | `Nm_payload name;
   call_name = `Nm_na;
   module_as_val = None;
   set_index = false;
   get_index = false;
   val_send = `Nm_na;
   val_send_pipe = None;
   new_name = `Nm_na;
   set_name = `Nm_na;
   external_module_name = None;
   variadic = false;
   mk_obj = _;
   return_wrapper = _;
   scopes;
  } ->
      if arg_type_specs_length = 1 then Js_get { name; scopes }
      else
        Location.raise_errorf ~loc
          "`[%@mel.get]' requires a function of only one argument"
  | { get_name = #bundle_source; _ } ->
      Location.raise_errorf ~loc
        "Found an attribute that conflicts with `[%@mel.get]'"

let list_of_arrow (ty : core_type) : core_type * param_type list =
  let rec aux (ty : core_type) acc =
    match ty.ptyp_desc with
    | Ptyp_arrow (label, t1, t2) ->
        aux t2
          (({ label; ty = t1; attr = ty.ptyp_attributes; loc = ty.ptyp_loc }
             : param_type)
          :: acc)
    | Ptyp_poly (_, ty) ->
        (* should not happen? *)
        Error.err ~loc:ty.ptyp_loc Unhandled_poly_type
    | _ -> (ty, List.rev acc)
  in
  aux ty []

module From_attributes = struct
  type t = {
    pval_type : core_type;
    pval_attributes : attributes;
    ffi : External_ffi_types.t;
    dont_inline_cross_module : bool;
  }

  let check_ffi =
    let valid_js_char =
      let a =
        Array.init 256 ~f:(fun i ->
            let c = Char.chr i in
            (c >= 'a' && c <= 'z')
            || (c >= 'A' && c <= 'Z')
            || (c >= '0' && c <= '9')
            || c = '_' || c = '$')
      in
      fun c -> Array.unsafe_get a (Char.code c)
    in
    let valid_first_js_char =
      let a =
        Array.init 256 ~f:(fun i ->
            let c = Char.chr i in
            (c >= 'a' && c <= 'z')
            || (c >= 'A' && c <= 'Z')
            || c = '_' || c = '$')
      in
      fun c -> Array.unsafe_get a (Char.code c)
    in
    (* Approximation could be improved *)
    let valid_ident (s : string) =
      let len = String.length s in
      len > 0
      && valid_js_char s.[0]
      && valid_first_js_char s.[0]
      &&
      let module E = struct
        exception E
      end in
      try
        for i = 1 to len - 1 do
          if not (valid_js_char (String.unsafe_get s i)) then raise E.E
        done;
        true
      with E.E -> false
    in
    let check_external_module_name ~loc x =
      match x with
      | { External_ffi_types.bundle = ""; _ }
      | { module_bind_name = Phint_name ""; _ } ->
          Location.raise_errorf ~loc "`@mel.module' name cannot be empty"
      | _ -> ()
    in
    let is_package_relative_path (x : string) =
      String.starts_with x ~prefix:"./" || String.starts_with x ~prefix:"../"
    in
    let valid_global_name ~loc txt =
      if not (valid_ident txt) then
        let v = String.split_by ~keep_empty:true (fun x -> x = '.') txt in
        List.iter
          ~f:(fun s ->
            if not (valid_ident s) then
              Location.raise_errorf ~loc
                "%S isn't a valid JavaScript identifier" txt)
          v
    in
    fun ~loc ffi
        (arg_type_specs :
          External_arg_spec.Arg_label.t External_arg_spec.param list) : bool ->
      let xrelative = ref false in
      let upgrade bool = if not !xrelative then xrelative := bool in
      (match ffi with
      | External_ffi_types.Js_var { name; external_module_name; _ } ->
          upgrade (is_package_relative_path name);
          Option.iter
            (fun (name : External_ffi_types.external_module_name) ->
              upgrade (is_package_relative_path name.bundle))
            external_module_name;
          valid_global_name ~loc name
      | Js_send { pipe; _ } -> (
          if not pipe then
            match arg_type_specs with
            | [] -> assert false
            | { arg_label = Arg_label | Arg_optional; _ } :: _ ->
                (* we started treating the `@mel.send` "self" arg as the first
           non-labeled argument so that we can be more expressive in the FFI.
           But we still need to warn in case the first argument is
           optional/labelled. *)
                Mel_ast_invariant.warn ~loc Mel_send_self_param
            | { arg_label = Arg_empty; _ } :: _ -> ())
      | Js_set _ | Js_get _ ->
          (* see https://github.com/rescript-lang/rescript-compiler/issues/2583 *)
          ()
      | Js_get_index _ (* TODO: check scopes *) | Js_set_index _ -> ()
      | Js_module_as_var external_module_name
      | Js_module_as_fn { external_module_name; variadic = _ }
      | Js_module_as_class external_module_name ->
          upgrade (is_package_relative_path external_module_name.bundle);
          check_external_module_name ~loc external_module_name
      | Js_new { external_module_name; name; _ }
      | Js_call { external_module_name; name; variadic = _; scopes = _ } ->
          Option.iter
            (fun (external_module_name :
                   External_ffi_types.external_module_name) ->
              upgrade (is_package_relative_path external_module_name.bundle))
            external_module_name;
          Option.iter
            (fun name -> check_external_module_name ~loc name)
            external_module_name;

          valid_global_name ~loc name);
      !xrelative

  (* Note that the passed [type_annotation] is already processed by visitor pattern before*)
  let parse ~(loc : Location.t) (type_annotation : core_type)
      (prim_attributes : attribute list) ~(pval_name : string)
      ~(prim_name : string) =
    (* sanity check here
      {[ int -> int -> (int -> int -> int [@uncurry])]}
      It does not make sense *)
    if has_mel_uncurry type_annotation.ptyp_attributes then
      Location.raise_errorf ~loc
        "`[%@mel.uncurry]' must not be applied to the entire annotation"
    else
      let prim_name_or_pval_name =
        if String.length prim_name = 0 then
          `Nm_external
            (lazy
              (Mel_ast_invariant.warn ~loc (Fragile_external pval_name);
               pval_name))
        else `Nm_external (lazy prim_name)
        (* need check name *)
      in
      let result_type, arg_types_ty =
        (* Note this assumes external type is syntactic (no abstraction)*)
        list_of_arrow type_annotation
      in
      if has_mel_uncurry result_type.ptyp_attributes then
        Location.raise_errorf ~loc
          "`[%@mel.uncurry]' cannot be applied to the return type"
      else
        let unused_attrs, external_desc =
          parse_external_attributes prim_name prim_name_or_pval_name
            prim_attributes
        in
        if external_desc.mk_obj then
          (* warn unused attributes here ? *)
          let new_type, spec =
            process_obj loc external_desc prim_name arg_types_ty result_type
          in
          {
            pval_type = new_type;
            ffi = spec;
            pval_attributes = unused_attrs;
            dont_inline_cross_module = false;
          }
        else
          let arg_type_specs, new_arg_types_ty, arg_type_specs_length =
            let variadic = external_desc.variadic in
            let (init
                  : External_arg_spec.Arg_label.t External_arg_spec.param list
                    * param_type list
                    * int) =
              match external_desc.val_send_pipe with
              | Some obj -> (
                  match refine_arg_type ~nolabel:true obj with
                  | Arg_cst _ ->
                      Location.raise_errorf ~loc
                        "`[%@mel.as ..]' must not be used in the payload for \
                         `[%@mel.send.pipe]'"
                  | arg_type ->
                      (* more error checking *)
                      ( [ { External_arg_spec.arg_label = Arg_empty; arg_type } ],
                        [
                          {
                            label = Nolabel;
                            ty = obj;
                            attr = [];
                            loc = obj.ptyp_loc;
                          };
                        ],
                        0 ))
              | None -> ([], [], 0)
            in
            List.fold_right
              ~f:(fun param_type (arg_type_specs, arg_types, i) ->
                let arg_label = param_type.label in
                let ty = param_type.ty in
                (if i = 0 && variadic then
                   match arg_label with
                   | Optional _ ->
                       Location.raise_errorf ~loc
                         "`[%@mel.variadic]' cannot be applied to an \
                          optionally labelled argument"
                   | Labelled _ | Nolabel -> (
                       if ty.ptyp_desc = Ptyp_any then
                         Location.raise_errorf
                           "`[%@mel.variadic]' expects its last argument to be \
                            an array"
                       else
                         match spec_of_ptyp ~nolabel:true ty with
                         | Nothing -> (
                             match ty.ptyp_desc with
                             | Ptyp_constr ({ txt = Lident "array"; _ }, [ _ ])
                               ->
                                 ()
                             | _ ->
                                 Location.raise_errorf ~loc
                                   "`[%@mel.variadic]' expects its last \
                                    argument to be an array")
                         | _ ->
                             Location.raise_errorf ~loc
                               "`[%@mel.variadic]' expects its last argument \
                                to be an array"));
                let ( (arg_label : External_arg_spec.Arg_label.t),
                      arg_type,
                      new_arg_types ) =
                  match arg_label with
                  | Optional _ -> (
                      match get_opt_arg_type ty with
                      | Poly_var _ ->
                          (* ?x:([`x of int ] [@string]) does not make sense *)
                          Location.raise_errorf ~loc:param_type.ty.ptyp_loc
                            "`[%@mel.as ..]' must not be used with an \
                             optionally labelled polymorphic variant"
                      | arg_type ->
                          (Arg_optional, arg_type, param_type :: arg_types))
                  | Labelled _ -> (
                      let arg_type = refine_arg_type ~nolabel:false ty in
                      ( Arg_label,
                        arg_type,
                        match arg_type with
                        | Arg_cst _ -> arg_types
                        | _ -> param_type :: arg_types ))
                  | Nolabel -> (
                      let arg_type = refine_arg_type ~nolabel:true ty in
                      ( Arg_empty,
                        arg_type,
                        match arg_type with
                        | Arg_cst _ -> arg_types
                        | _ -> param_type :: arg_types ))
                in
                ( { External_arg_spec.arg_label; arg_type } :: arg_type_specs,
                  new_arg_types,
                  if arg_type = Ignore then i else i + 1 ))
              arg_types_ty ~init
          in
          let ffi =
            external_desc_of_non_obj loc external_desc prim_name_or_pval_name
              arg_type_specs_length arg_types_ty arg_type_specs
          in
          let relative = check_ffi ~loc ffi arg_type_specs in
          (* result type can not be labeled *)
          (* currently we don't process attributes of
           return type, in the future we may *)
          let return_wrapper =
            (* TODO(anmonteiro): don't add the return wrapper for unit if this is
             uncurried? saves the brittle pattern matching in Lam_compile *)
            check_return_wrapper loc external_desc.return_wrapper result_type
          in
          {
            pval_type = mk_fn_type new_arg_types_ty result_type;
            ffi = External_ffi_types.ffi_mel arg_type_specs return_wrapper ffi;
            pval_attributes = unused_attrs;
            dont_inline_cross_module = relative;
          }
end

let handle_attributes_as_string (pval_loc : Location.t) (typ : core_type)
    (attrs : attribute list) (pval_name : string) (prim_name : string) =
  match typ.ptyp_desc with
  | Ptyp_constr
      ({ txt = Ldot (Ldot (Lident "Js", "Fn"), arity); loc }, [ fn_type ]) ->
      let {
        From_attributes.pval_type;
        ffi;
        pval_attributes;
        dont_inline_cross_module;
      } =
        From_attributes.parse ~loc:pval_loc fn_type attrs ~pval_name ~prim_name
      in

      {
        pval_type =
          Ast_helper.Typ.constr
            { txt = Ldot (Ast_literal.js_fn, arity); loc }
            [ pval_type ];
        pval_prim = [ prim_name; prim_name ];
        pval_attributes = Ast_attributes.mel_ffi ffi :: pval_attributes;
        dont_inline_cross_module;
      }
  | _ ->
      let {
        From_attributes.pval_type;
        ffi;
        pval_attributes;
        dont_inline_cross_module;
      } =
        From_attributes.parse ~loc:pval_loc typ attrs ~pval_name ~prim_name
      in
      {
        pval_type;
        pval_prim = [ prim_name; prim_name ];
        pval_attributes = Ast_attributes.mel_ffi ffi :: pval_attributes;
        dont_inline_cross_module;
      }
