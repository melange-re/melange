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

(* TODO: [nolabel] is only used once turn Nothing into Unit, refactor later *)
let spec_of_ptyp ~(nolabel : bool) (ptyp : core_type) : External_arg_spec.t =
  let ptyp_desc = ptyp.ptyp_desc in
  let { Ast_attributes.Param_modifier.kind = spec; loc = _loc } =
    Ast_attributes.iter_process_mel_param_modifier ptyp.ptyp_attributes
  in
  match spec with
  | Ignore -> Ignore
  | String -> (
      match ptyp_desc with
      | Ptyp_variant (row_fields, Closed, None) ->
          Ast_polyvar.map_row_fields_into_strings row_fields ~loc:ptyp.ptyp_loc
      | _ -> Error.err ~loc:ptyp.ptyp_loc Invalid_mel_string_type)
  | Int -> (
      match ptyp_desc with
      | Ptyp_variant (row_fields, Closed, None) ->
          Ast_polyvar.map_row_fields_into_ints row_fields ~loc:ptyp.ptyp_loc
      | _ -> Error.err ~loc:ptyp.ptyp_loc Invalid_mel_int_type)
  | Spread -> (
      match ptyp_desc with
      | Ptyp_variant (row_fields, Closed, None) ->
          Ast_polyvar.map_row_fields_into_spread row_fields ~loc:ptyp.ptyp_loc
      | _ -> Error.err ~loc:ptyp.ptyp_loc Invalid_mel_string_type)
  | Unwrap -> (
      match ptyp_desc with
      | Ptyp_variant (row_fields, Closed, _) when variant_unwrap row_fields ->
          (* Unwrap attribute can only be attached to things like
             `[a of a0 | b of b0]` *)
          Unwrap (Ast_polyvar.infer_mel_as ~loc:ptyp.ptyp_loc row_fields)
      | _ -> Error.err ~loc:ptyp.ptyp_loc Invalid_mel_unwrap_type)
  | Uncurry opt_arity -> (
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
  | Nothing -> (
      match ptyp_desc with
      | Ptyp_constr ({ txt = Lident "unit"; _ }, []) ->
          if nolabel then Extern_unit else Nothing
      | Ptyp_variant (row_fields, Closed, None) ->
          Ast_polyvar.infer_mel_as ~loc:ptyp.ptyp_loc row_fields
      | _ -> Nothing)

(* is_optional = false *)
let refine_arg_type ~(nolabel : bool) ~has_mel_send (ptyp : core_type) :
    External_arg_spec.t =
  match ptyp.ptyp_desc with
  | Ptyp_any -> (
      match Ast_attributes.iter_process_mel_as_cst ptyp.ptyp_attributes with
      | None -> spec_of_ptyp ~nolabel ptyp
      | Some cst ->
          (* (_[@as ])*)
          Mel_ast_invariant.warn_discarded_unused_attributes ~has_mel_send
            ptyp.ptyp_attributes;
          External_arg_spec.Arg_cst cst)
  | _ ->
      (* ([`a|`b] [@string]) *)
      spec_of_ptyp ~nolabel ptyp

let refine_obj_arg_type ~(nolabel : bool) (ptyp : core_type) :
    External_arg_spec.t =
  match ptyp.ptyp_desc with
  | Ptyp_any -> (
      match Ast_attributes.iter_process_mel_as_cst ptyp.ptyp_attributes with
      | None -> Error.err ~loc:ptyp.ptyp_loc Invalid_underscore_type_in_external
      | Some cst ->
          (* (_[@as ])*)
          Mel_ast_invariant.warn_discarded_unused_attributes
            ptyp.ptyp_attributes;
          External_arg_spec.Arg_cst cst)
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
let get_opt_arg_type (ptyp : core_type) : External_arg_spec.t =
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

module External_desc = struct
  type kind = Val | Set_index | Get_index | Set | Get | Send

  let pp_kind fmt t =
    let s =
      match t with
      | Val -> assert false
      | Set_index -> "mel.set_index"
      | Get_index -> "mel.get_index"
      | Set -> "mel.set"
      | Get -> "mel.get"
      | Send -> "mel.get"
    in
    Format.pp_print_string fmt s

  type desc = {
    kind : kind;
    external_module_name : External_ffi_types.External_module_name.t option;
    module_as_val : External_ffi_types.External_module_name.t option;
    variadic : bool; (* mutable *)
    scopes : string list;
    new_name : bool;
    return_wrapper : External_ffi_types.return_wrapper;
  }

  type t = Obj of desc | External of desc

  let init =
    {
      kind = Val;
      external_module_name = None;
      module_as_val = None;
      variadic = false;
      scopes = [];
      new_name = false;
      return_wrapper = Return_unset;
    }
end

let return_wrapper ~loc (txt : string) : External_ffi_types.return_wrapper =
  match txt with
  | "undefined_to_opt" -> Return_undefined_to_opt
  | "null_to_opt" -> Return_null_to_opt
  | "nullable" | "null_undefined_to_opt" -> Return_null_undefined_to_opt
  | "identity" -> Return_identity
  | _ -> Error.err ~loc Not_supported_directive_in_mel_return

(* The processed attributes will be dropped *)
let parse_external_attributes =
  (* : attribute list * external_desc *)
  let exception Not_handled_external_attribute in
  let check_name ~loc attr_name payload =
    match payload with
    | PStr [] -> ()
    | _ -> (
        match Ast_payload.is_single_string payload with
        | Some _ ->
            Location.raise_errorf ~loc
              "`[%@%s]' doesn't expect an attribute payload" attr_name
        | None -> Location.raise_errorf ~loc "Invalid payload")
  in
  let assign_kind ~loc (st : External_desc.desc) kind =
    match st.kind with
    | Val -> { st with kind }
    | st_kind ->
        Error.err ~loc
          (Conflict_ffi_attribute
             (Format.asprintf
                "`[%@%a]' and `[%@%a]' can't be specified at the same time"
                External_desc.pp_kind st_kind External_desc.pp_kind kind))
  in
  fun (prim_name_check : string)
    (prim_name_or_pval_prim : string Lazy.t)
    (prim_attributes : attribute list)
  ->
    (* shared by `[@@val]`, `[@@send]`,
     `[@@set]`, `[@@get]` , `[@@new]`
     `[@@mel.send.pipe]` does not use it
  *)
    let attrs, st, mk_obj =
      List.fold_left
        ~f:(fun
            (attrs, st, mk_obj)
            ({
               attr_name = { txt; loc = _ };
               attr_payload = payload;
               attr_loc = loc;
             } as attr)
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
          try
            let st, mk_obj =
              match txt with
              | "mel.module" -> (
                  match Ast_payload.assert_strings ~loc payload with
                  | [ bundle ] ->
                      ( {
                          st with
                          External_desc.external_module_name =
                            Some { bundle; module_bind_name = Phint_nothing };
                        },
                        mk_obj )
                  | [ bundle; bind_name ] ->
                      ( {
                          st with
                          external_module_name =
                            Some
                              {
                                bundle;
                                module_bind_name = Phint_name bind_name;
                              };
                        },
                        mk_obj )
                  | [] ->
                      ( {
                          st with
                          module_as_val =
                            Some
                              {
                                bundle = Lazy.force prim_name_or_pval_prim;
                                module_bind_name = Phint_nothing;
                              };
                        },
                        mk_obj )
                  | _ ->
                      Location.raise_errorf ~loc
                        "`[%@mel.module ..]' expects, at most, a tuple of two \
                         strings (module name, variable name)")
              | "mel.scope" -> (
                  match Ast_payload.assert_strings ~loc payload with
                  | [] ->
                      Location.raise_errorf ~loc
                        "`[%@mel.scope ..]' expects a tuple of strings in its \
                         payload"
                  (* We need err on empty scope, so we can tell the difference
               between unset/set *)
                  | scopes -> ({ st with scopes }, mk_obj))
              | "mel.variadic" -> ({ st with variadic = true }, mk_obj)
              | "mel.send" ->
                  check_name ~loc txt payload;
                  (assign_kind ~loc st Send, mk_obj)
              | "mel.send.pipe" ->
                  Location.raise_errorf ~loc
                    "`%s' has been removed. Use `@mel.send' with the \
                     `@mel.this` marker instead."
                    txt
              | "mel.set" ->
                  check_name ~loc txt payload;
                  (assign_kind ~loc st Set, mk_obj)
              | "mel.get" ->
                  check_name ~loc txt payload;
                  (assign_kind ~loc st Get, mk_obj)
              | "mel.new" ->
                  check_name ~loc txt payload;
                  ({ st with new_name = true }, mk_obj)
              | "mel.set_index" ->
                  if String.length prim_name_check <> 0 then
                    Location.raise_errorf ~loc
                      "`%@mel.set_index' requires its `external' payload to be \
                       the empty string";
                  (assign_kind ~loc st Set_index, mk_obj)
              | "mel.get_index" ->
                  if String.length prim_name_check <> 0 then
                    Location.raise_errorf ~loc
                      "`%@mel.get_index' requires its `external' payload to be \
                       the empty string";
                  (assign_kind ~loc st Get_index, mk_obj)
              | "mel.obj" -> (st, true)
              | "mel.return" -> (
                  match Ast_payload.ident_or_record_as_config payload with
                  | Ok [ ({ txt; _ }, None) ] ->
                      ( { st with return_wrapper = return_wrapper ~loc txt },
                        mk_obj )
                  | Ok _ -> Error.err ~loc Not_supported_directive_in_mel_return
                  | Error s -> Location.raise_errorf ~loc "%s" s)
              | _ -> raise_notrace Not_handled_external_attribute
            in
            (attrs, st, mk_obj)
          with Not_handled_external_attribute -> (attr :: attrs, st, mk_obj))
        ~init:([], External_desc.init, false)
        prim_attributes
    in
    ( attrs,
      match mk_obj with true -> External_desc.Obj st | false -> External st )

let is_user_option ty =
  match ty.ptyp_desc with
  | Ptyp_constr
      ({ txt = Lident "option" | Ldot (Lident "*predef*", "option"); _ }, [ _ ])
    ->
      true
  | _ -> false

type response = {
  pval_type : core_type;
  pval_prim : string list;
  pval_attributes : attributes;
  dont_inline_cross_module : bool;
}

type param_type = {
  label : Asttypes.arg_label;
  ty : core_type;
  attrs : attributes;
  loc : location;
}

let mk_fn_type (new_arg_types_ty : param_type list) (result : core_type) :
    core_type =
  List.fold_right
    ~f:(fun { label; ty; attrs; loc } acc ->
      {
        ptyp_desc = Ptyp_arrow (label, ty, acc);
        ptyp_loc = loc;
        ptyp_loc_stack = [];
        ptyp_attributes = attrs;
      })
    new_arg_types_ty ~init:result

let process_obj (loc : Location.t) (st : External_desc.desc)
    (prim_name : string) (arg_types_ty : param_type list)
    (result_type : core_type) : core_type * External_ffi_types.t =
  match st with
  | {
   kind = Val;
   external_module_name = None;
   module_as_val = None;
   variadic = false;
   new_name = false;
   return_wrapper = Return_unset;
   scopes = [];
   _ (* wrapper does not work with @obj
    TODO: better error message *);
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
                    | Poly_var { spread = false; _ } ->
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
                    | Poly_var { spread = false; _ } ->
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

let mel_send_this_index arg_type_specs arg_types =
  let find_index ~f:p =
    let rec aux i = function
      | [] -> None
      | a :: l -> if p a then Some i else aux (i + 1) l
    in
    aux 0
  in
  let mel_this_idx =
    find_index
      ~f:(fun { attrs; _ } ->
        List.exists
          ~f:(fun ({ attr_name = { txt; _ }; _ } as attr) ->
            match txt with
            | "mel.this" ->
                Mel_ast_invariant.mark_used_mel_attribute attr;
                true
            | _ -> false)
          attrs)
      arg_types
  in
  match mel_this_idx with
  | Some self_idx -> self_idx
  | None ->
      (* find the first non-constant argument *)
      find_index
        ~f:(function
          | { External_arg_spec.Param.arg_type = Arg_cst _; _ } -> false
          | _ -> true)
        arg_type_specs
      |> Option.get

let external_desc_of_non_obj ~loc (st : External_desc.desc)
    (prim_name_or_pval_prim : string Lazy.t) arg_type_specs_length arg_types_ty
    (arg_type_specs :
      External_arg_spec.Arg_label.t External_arg_spec.Param.t list) :
    External_ffi_types.External_spec.t =
  match st with
  | {
   kind = Set_index;
   external_module_name = None;
   module_as_val = None;
   variadic = false;
   scopes;
   new_name = false;
   return_wrapper = _;
  } -> (
      match arg_type_specs_length with
      | 3 -> Js_set_index { scopes }
      | _ ->
          Location.raise_errorf ~loc
            "`[%@mel.set_index]' requires a function of 3 arguments: `'t -> \
             'key -> 'value -> unit'")
  | { kind = Set_index; _ } ->
      Error.err ~loc
        (Conflict_ffi_attribute
           "Found an attribute that conflicts with `[@mel.set_index]'")
  | {
   kind = Get_index;
   external_module_name = None;
   module_as_val = None;
   variadic = false;
   scopes;
   new_name = false;
   return_wrapper = _;
  } -> (
      match arg_type_specs_length with
      | 2 -> Js_get_index { scopes }
      | _ ->
          Location.raise_errorf ~loc
            "`[%@mel.get_index]' requires a function of 2 arguments: `'t -> \
             'key -> 'value'")
  | { kind = Get_index; _ } ->
      Error.err ~loc
        (Conflict_ffi_attribute
           "Found an attribute that conflicts with `@mel.get_index'")
  | {
   kind = Val;
   module_as_val = Some external_module_name;
   new_name;
   external_module_name = None;
   scopes = [];
   (* module as var does not need scopes *)
   variadic;
   return_wrapper = _;
  } -> (
      match (arg_types_ty, new_name) with
      | [], false -> Js_module_as_var external_module_name
      | _, false -> Js_module_as_fn { variadic; external_module_name }
      | _, true -> Js_module_as_class external_module_name)
  | { module_as_val = Some _; kind = Send as kind; _ } ->
      let reason =
        match kind with
        | Get_index ->
            "`@mel.get_index' doesn't import from a module. `@mel.module' is \
             not necessary here."
        | Send ->
            "`@mel.send' doesn't import from a module. `@mel.module` is not \
             necessary here."
        | _ -> "Found an attribute that conflicts with `@mel.module'."
      in
      Error.err ~loc (Conflict_ffi_attribute reason)
  | {
   kind = Val;
   module_as_val = None;
   new_name = false;
   external_module_name = None;
   variadic;
   scopes;
   return_wrapper = _;
  } -> (
      let name = Lazy.force prim_name_or_pval_prim in
      match arg_type_specs_length with
      | 0 ->
          (* {[ external ff : int -> int [@bs] = "" [@@module "xx"] ]}
             FIXME: variadic is not supported here *)
          Js_var { name; external_module_name = None; scopes }
      | _ -> Js_call { variadic; name; external_module_name = None; scopes })
  | {
   kind = Val;
   module_as_val = None;
   new_name = false;
   external_module_name = Some _ as external_module_name;
   variadic;
   scopes;
   return_wrapper = _;
  } -> (
      let name = Lazy.force prim_name_or_pval_prim in
      match arg_type_specs_length with
      | 0 ->
          (* {[ external ff : int = "" [@@module "xx"] ]} *)
          Js_var { name; external_module_name; scopes }
      | _ -> Js_call { variadic; name; external_module_name; scopes })
  | {
   kind = Send;
   variadic;
   scopes;
   module_as_val = None;
   new_name;
   external_module_name = None;
   return_wrapper = _;
  } -> (
      (* PR #2162 - since when we assemble arguments the first argument in
         [@@send] is ignored *)
      match (arg_type_specs, new_name) with
      | [], _ ->
          Location.raise_errorf ~loc
            "`[%@mel.send]` requires a function with at least one argument"
      | [ { arg_type = Arg_cst _; arg_label = _ } ], _ ->
          Location.raise_errorf ~loc
            "`[%@mel.send]`'s must have at least a non-constant argument"
      | _ :: _, _ ->
          Js_send
            {
              variadic;
              name = Lazy.force prim_name_or_pval_prim;
              scopes;
              self_idx = mel_send_this_index arg_type_specs arg_types_ty;
              new_ = new_name;
            })
  | { kind = Send; _ } ->
      Location.raise_errorf ~loc
        "Found an attribute that can't be used with `[%@mel.send]'"
  | {
   new_name = true;
   external_module_name;
   module_as_val = None;
   kind = Val;
   variadic;
   scopes;
   return_wrapper = _;
  } ->
      Js_new
        {
          name = Lazy.force prim_name_or_pval_prim;
          external_module_name;
          variadic;
          scopes;
        }
  | { new_name = true; _ } ->
      Error.err ~loc
        (Conflict_ffi_attribute
           "Found an attribute that can't be used with `@mel.new'")
  | {
   kind = Set;
   module_as_val = None;
   new_name = false;
   external_module_name = None;
   variadic = false;
   return_wrapper = _;
   scopes;
  } -> (
      match arg_type_specs_length with
      | 2 -> Js_set { name = Lazy.force prim_name_or_pval_prim; scopes }
      | _ ->
          Location.raise_errorf ~loc
            "`[%@mel.set]' requires a function of two arguments")
  | { kind = Set; _ } ->
      Error.err ~loc
        (Conflict_ffi_attribute
           "Found an attribute that can't be used with `[@mel.set]'")
  | {
   kind = Get;
   module_as_val = None;
   new_name = false;
   external_module_name = None;
   variadic = false;
   return_wrapper = _;
   scopes;
  } -> (
      match arg_type_specs_length with
      | 1 -> Js_get { name = Lazy.force prim_name_or_pval_prim; scopes }
      | _ ->
          Location.raise_errorf ~loc
            "`[%@mel.get]' requires a function of only one argument")
  | { kind = Get; _ } ->
      Error.err ~loc
        (Conflict_ffi_attribute
           "Found an attribute that can't be used with `[@mel.get]'")
  | { kind = Val; _ } -> assert false

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
      | { External_ffi_types.External_module_name.bundle = ""; _ }
      | { module_bind_name = Phint_name ""; _ } ->
          Location.raise_errorf ~loc "`@mel.module' name cannot be empty"
      | _ -> ()
    in
    let is_package_relative_path (x : string) =
      String.starts_with x ~prefix:"./" || String.starts_with x ~prefix:"../"
    in
    let valid_global_name ~loc txt =
      if not (valid_ident txt) then
        let v = String.split_by txt ~keep_empty:true ~f:(Char.equal '.') in
        List.iter
          ~f:(fun s ->
            if not (valid_ident s) then
              Location.raise_errorf ~loc
                "%S isn't a valid JavaScript identifier" txt)
          v
    in
    fun ~loc ffi : bool ->
      let xrelative = ref false in
      let upgrade bool = if not !xrelative then xrelative := bool in
      (match ffi with
      | External_ffi_types.External_spec.Js_var
          { name; external_module_name; _ } ->
          upgrade (is_package_relative_path name);
          Option.iter
            ~f:(fun (name : External_ffi_types.External_module_name.t) ->
              upgrade (is_package_relative_path name.bundle))
            external_module_name;
          valid_global_name ~loc name
      | Js_send _ | Js_set _ | Js_get _ ->
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
            ~f:(fun
                (external_module_name :
                  External_ffi_types.External_module_name.t)
              -> upgrade (is_package_relative_path external_module_name.bundle))
            external_module_name;
          Option.iter
            ~f:(fun name -> check_external_module_name ~loc name)
            external_module_name;
          valid_global_name ~loc name);
      !xrelative

  let check_return_wrapper ~loc ~is_uncurried
      (wrapper : External_ffi_types.return_wrapper) result_type =
    match wrapper with
    | Return_identity -> wrapper
    | Return_unset -> (
        match (is_uncurried, result_type.ptyp_desc) with
        | false, Ptyp_constr ({ txt = Lident "unit"; _ }, []) ->
            Return_replaced_with_unit
        | _ -> wrapper)
    | Return_undefined_to_opt | Return_null_to_opt
    | Return_null_undefined_to_opt ->
        if is_user_option result_type then wrapper
        else Error.err ~loc Expect_opt_in_mel_return_to_opt
    | Return_replaced_with_unit ->
        assert false (* Not going to happen from user input*)

  (* Note that the passed [type_annotation] is already processed by visitor pattern before*)
  let parse =
    let list_of_arrow (ty : core_type) : core_type * param_type list =
      let rec aux (ty : core_type) acc =
        match ty.ptyp_desc with
        | Ptyp_arrow (label, t1, t2) ->
            aux t2
              (({
                  label;
                  ty = t1;
                  attrs = ty.ptyp_attributes @ t1.ptyp_attributes;
                  loc = ty.ptyp_loc;
                }
                 : param_type)
              :: acc)
        | Ptyp_poly (_, ty) ->
            (* should not happen? *)
            Error.err ~loc:ty.ptyp_loc Unhandled_poly_type
        | _ -> (ty, List.rev acc)
      in
      aux ty []
    in
    let has_mel_uncurry (attrs : attribute list) =
      List.exists
        ~f:(fun { attr_name = { txt; loc = _ }; _ } ->
          match txt with "mel.uncurry" -> true | _ -> false)
        attrs
    in
    fun ~loc
      ~is_uncurried
      (type_annotation : core_type)
      (prim_attributes : attribute list)
      ~pval_name
      ~prim_name
    ->
      (* sanity check here
      {[ int -> int -> (int -> int -> int [@uncurry])]}
      It does not make sense *)
      if has_mel_uncurry type_annotation.ptyp_attributes then
        Location.raise_errorf ~loc
          "`[%@mel.uncurry]' must not be applied to the entire annotation"
      else
        let prim_name_or_pval_name =
          (* TODO(anmonteiro): need check name *)
          match String.length prim_name with
          | 0 ->
              lazy
                (Mel_ast_invariant.warn ~loc (Fragile_external pval_name);
                 pval_name)
          | _ -> lazy prim_name
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
          match external_desc with
          | Obj external_desc ->
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
          | External external_desc ->
              let arg_type_specs, new_arg_types_ty, (arg_type_specs_length, _) =
                let (init
                      : External_arg_spec.Arg_label.t External_arg_spec.Param.t
                        list
                        * param_type list
                        * (int * bool)) =
                  ([], [], (0, false))
                in
                List.fold_right
                  ~f:(fun
                      param_type
                      (arg_type_specs, arg_types, (i, last_was_mel_this))
                    ->
                    let arg_label = param_type.label in
                    let ty = param_type.ty in
                    let is_variadic =
                      (i = 0 || (i = 1 && last_was_mel_this))
                      && external_desc.variadic
                    in
                    let is_mel_this_and_send =
                      external_desc.kind = Send
                      && List.exists
                           ~f:(fun { attr_name = { txt; _ }; _ } ->
                             txt = "mel.this")
                           param_type.attrs
                    in
                    (if is_variadic && not is_mel_this_and_send then
                       match arg_label with
                       | Optional _ ->
                           Location.raise_errorf ~loc
                             "`[%@mel.variadic]' cannot be applied to an \
                              optionally labelled argument"
                       | Labelled _ | Nolabel -> (
                           match ty.ptyp_desc with
                           | Ptyp_any ->
                               Location.raise_errorf
                                 "`[%@mel.variadic]' expects its last argument \
                                  to be an array"
                           | _ -> (
                               match spec_of_ptyp ~nolabel:true ty with
                               | Nothing -> (
                                   match ty.ptyp_desc with
                                   | Ptyp_constr
                                       ({ txt = Lident "array"; _ }, [ _ ]) ->
                                       ()
                                   | _ ->
                                       Location.raise_errorf ~loc
                                         "`[%@mel.variadic]' expects its last \
                                          argument to be an array")
                               | _ ->
                                   Location.raise_errorf ~loc
                                     "`[%@mel.variadic]' expects its last \
                                      argument to be an array")));
                    let ( (arg_label : External_arg_spec.Arg_label.t),
                          arg_type,
                          new_arg_types ) =
                      match arg_label with
                      | Optional _ -> (
                          match get_opt_arg_type ty with
                          | Poly_var { spread = true; _ } ->
                              (* ?x:([`x of int ] [@string]) does not make sense *)
                              Location.raise_errorf ~loc:param_type.ty.ptyp_loc
                                "`[%@mel.as ..]' must not be used with an \
                                 optionally labelled polymorphic variant"
                          | arg_type ->
                              (Arg_optional, arg_type, param_type :: arg_types))
                      | Labelled _ -> (
                          let arg_type =
                            let has_mel_send = external_desc.kind = Send in
                            refine_arg_type ~nolabel:false ~has_mel_send ty
                          in
                          ( Arg_label,
                            arg_type,
                            match arg_type with
                            | Arg_cst _ -> arg_types
                            | _ -> param_type :: arg_types ))
                      | Nolabel -> (
                          let arg_type =
                            let has_mel_send = external_desc.kind = Send in
                            refine_arg_type ~nolabel:true ~has_mel_send ty
                          in
                          ( Arg_empty,
                            arg_type,
                            match arg_type with
                            | Arg_cst _ -> arg_types
                            | _ -> param_type :: arg_types ))
                    in
                    ( { External_arg_spec.Param.arg_label; arg_type }
                      :: arg_type_specs,
                      new_arg_types,
                      match arg_type with
                      | Ignore -> (i, last_was_mel_this)
                      | _ -> (i + 1, is_mel_this_and_send) ))
                  arg_types_ty ~init
              in
              let ffi =
                external_desc_of_non_obj ~loc external_desc
                  prim_name_or_pval_name arg_type_specs_length arg_types_ty
                  arg_type_specs
              in
              let relative = check_ffi ~loc ffi in
              (* result type can not be labeled *)
              (* currently we don't process attributes of return type, in the
                 future we may *)
              let return_wrapper =
                check_return_wrapper ~loc ~is_uncurried
                  external_desc.return_wrapper result_type
              in
              {
                pval_type = mk_fn_type new_arg_types_ty result_type;
                ffi =
                  External_ffi_types.ffi_mel arg_type_specs return_wrapper ffi;
                pval_attributes = unused_attrs;
                dont_inline_cross_module = relative;
              }
end

let handle_attributes_as_string ~loc (typ : core_type) (attrs : attribute list)
    (pval_name : string) (prim_name : string) =
  let typ, loc, wrapper =
    match typ.ptyp_desc with
    | Ptyp_constr
        ({ txt = Ldot (Ldot (Lident "Js", "Fn"), arity); loc }, [ fn_type ]) ->
        ( fn_type,
          loc,
          Some
            (fun x ->
              Ast_helper.Typ.constr
                { txt = Ldot (Ast_literal.js_fn, arity); loc }
                [ x ]) )
    | _ -> (typ, loc, None)
  in
  let {
    From_attributes.pval_type;
    ffi;
    pval_attributes;
    dont_inline_cross_module;
  } =
    let is_uncurried = Option.is_some wrapper in
    From_attributes.parse ~loc ~is_uncurried typ attrs ~pval_name ~prim_name
  in
  {
    pval_type =
      (match wrapper with
      | Some wrapper_fn -> wrapper_fn pval_type
      | None -> pval_type);
    pval_prim = [ prim_name; prim_name ];
    pval_attributes = Ast_attributes.mel_ffi ffi :: pval_attributes;
    dont_inline_cross_module;
  }
