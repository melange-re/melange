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

(* record pattern match complete checker*)

let rec variant_can_unwrap_aux (row_fields : Parsetree.row_field list) : bool =
  match row_fields with
  | [] -> true
  | { prf_desc = Rtag (_, false, [ _ ]); _ } :: rest ->
      variant_can_unwrap_aux rest
  | _ :: _ -> false

let variant_unwrap (row_fields : Parsetree.row_field list) : bool =
  match row_fields with
  | [] -> false (* impossible syntax *)
  | xs -> variant_can_unwrap_aux xs

(*
  TODO: [nolabel] is only used once turn Nothing into Unit, refactor later
*)
let spec_of_ptyp (nolabel : bool) (ptyp : Parsetree.core_type) :
    External_arg_spec.attr =
  let ptyp_desc = ptyp.ptyp_desc in
  match
    Ast_attributes.iter_process_bs_string_int_unwrap_uncurry
      ptyp.ptyp_attributes
  with
  | `String -> (
      match ptyp_desc with
      | Ptyp_variant (row_fields, Closed, None) ->
          Ast_polyvar.map_row_fields_into_strings ptyp.ptyp_loc row_fields
      | _ -> Error.err ~loc:ptyp.ptyp_loc Invalid_bs_string_type)
  | `Ignore -> Ignore
  | `Int -> (
      match ptyp_desc with
      | Ptyp_variant (row_fields, Closed, None) ->
          let int_lists =
            Ast_polyvar.map_row_fields_into_ints ptyp.ptyp_loc row_fields
          in
          Int int_lists
      | _ -> Error.err ~loc:ptyp.ptyp_loc Invalid_bs_int_type)
  | `Unwrap -> (
      match ptyp_desc with
      | Ptyp_variant (row_fields, Closed, _) when variant_unwrap row_fields ->
          Unwrap
          (* Unwrap attribute can only be attached to things like `[a of a0 | b of b0]` *)
      | _ -> Error.err ~loc:ptyp.ptyp_loc Invalid_bs_unwrap_type)
  | `Uncurry opt_arity -> (
      let real_arity = Ast_core_type.get_uncurry_arity ptyp in
      match (opt_arity, real_arity) with
      | Some arity, None -> Fn_uncurry_arity arity
      | None, None -> Error.err ~loc:ptyp.ptyp_loc Canot_infer_arity_by_syntax
      | None, Some arity -> Fn_uncurry_arity arity
      | Some arity, Some n ->
          if n <> arity then
            Error.err ~loc:ptyp.ptyp_loc (Inconsistent_arity (arity, n))
          else Fn_uncurry_arity arity)
  | `Nothing -> (
      match ptyp_desc with
      | Ptyp_constr ({ txt = Lident "unit"; _ }, []) ->
          if nolabel then Extern_unit else Nothing
      | _ -> Nothing)

(* is_optional = false
*)
let refine_arg_type ~(nolabel : bool) (ptyp : Parsetree.core_type) :
    External_arg_spec.attr =
  match ptyp.ptyp_desc with
  | Ptyp_any -> (
      let ptyp_attrs = ptyp.ptyp_attributes in
      let result = Ast_attributes.iter_process_bs_string_or_int_as ptyp_attrs in
      match result with
      | None -> spec_of_ptyp nolabel ptyp
      | Some cst -> (
          (* (_[@as ])*)
          (* when ppx start dropping attributes
             we should warn, there is a trade off whether
             we should warn dropped non bs attribute or not
          *)
          Bs_ast_invariant.warn_discarded_unused_attributes ptyp_attrs;
          match cst with
          | Int i ->
              (* This type is used in obj only to construct obj type*)
              Arg_cst (External_arg_spec.cst_int i)
          | Str i -> Arg_cst (External_arg_spec.cst_string i)
          | Js_literal_str s -> Arg_cst (External_arg_spec.cst_obj_literal s)))
  | _ ->
      (* ([`a|`b] [@string]) *)
      spec_of_ptyp nolabel ptyp

let refine_obj_arg_type ~(nolabel : bool) (ptyp : Parsetree.core_type) :
    External_arg_spec.attr =
  if ptyp.ptyp_desc = Ptyp_any then (
    let ptyp_attrs = ptyp.ptyp_attributes in
    let result = Ast_attributes.iter_process_bs_string_or_int_as ptyp_attrs in
    (* when ppx start dropping attributes
       we should warn, there is a trade off whether
       we should warn dropped non bs attribute or not
    *)
    Bs_ast_invariant.warn_discarded_unused_attributes ptyp_attrs;
    match result with
    | None -> Error.err ~loc:ptyp.ptyp_loc Invalid_underscore_type_in_external
    | Some (Int i) ->
        (* (_[@as ])*)
        (* This type is used in obj only to construct obj type*)
        Arg_cst (External_arg_spec.cst_int i)
    | Some (Str i) -> Arg_cst (External_arg_spec.cst_string i)
    | Some (Js_literal_str s) -> Arg_cst (External_arg_spec.cst_obj_literal s))
  else (* ([`a|`b] [@string]) *)
    spec_of_ptyp nolabel ptyp

(* Given the type of argument, process its [bs.] attribute and new type,
    The new type is currently used to reconstruct the external type
    and result type in [@@obj]
    They are not the same though, for example
    {[
      external f : hi:([ `hi | `lo ] [@string]) -> unit -> _ = "" [@@obj]
    ]}
    The result type would be [ hi:string ]
*)
let get_opt_arg_type ~(nolabel : bool) (ptyp : Parsetree.core_type) :
    External_arg_spec.attr =
  if ptyp.ptyp_desc = Ptyp_any then
    (* (_[@as ])*)
    (* extenral f : ?x:_ -> y:int -> _ = "" [@@obj] is not allowed *)
    Error.err ~loc:ptyp.ptyp_loc Invalid_underscore_type_in_external;
  (* ([`a|`b] [@@string]) *)
  spec_of_ptyp nolabel ptyp

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
  | `Nm_external of string (* from "" in external *)
  | `Nm_val of string lazy_t (* from function name *) ]

let string_of_bundle_source (x : bundle_source) =
  match x with `Nm_payload x | `Nm_external x | `Nm_val (lazy x) -> x

type name_source = [ bundle_source | `Nm_na ]

type external_desc = {
  val_name : name_source;
  external_module_name : External_ffi_types.external_module_name option;
  module_as_val : External_ffi_types.external_module_name option;
  val_send : name_source;
  val_send_pipe : Parsetree.core_type option;
  splice : bool; (* mutable *)
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
    val_name = `Nm_na;
    external_module_name = None;
    module_as_val = None;
    val_send = `Nm_na;
    val_send_pipe = None;
    splice = false;
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
  | _ -> Error.err ~loc Not_supported_directive_in_bs_return

exception Not_handled_external_attribute

(* The processed attributes will be dropped *)
let parse_external_attributes (no_arguments : bool) (prim_name_check : string)
    (prim_name_or_pval_prim : bundle_source)
    (prim_attributes : Ast_attributes.t) : Ast_attributes.t * external_desc =
  (* shared by `[@@val]`, `[@@send]`,
     `[@@set]`, `[@@get]` , `[@@new]`
     `[@@bs.send.pipe]` does not use it
  *)
  let name_from_payload_or_prim ~loc (payload : Parsetree.payload) : name_source
      =
    match payload with
    | PStr [] -> (prim_name_or_pval_prim :> name_source)
    (* It is okay to have [@@val] without payload *)
    | _ -> (
        match Ast_payload.is_single_string payload with
        | Some (val_name, _) -> `Nm_payload val_name
        | None -> Location.raise_errorf ~loc "Invalid payload")
  in

  List.fold_left
    (fun (attrs, st)
         ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr) ->
      if txt = Literals.gentype_import then
        let bundle =
          let input_name = !Ocaml_common.Location.input_name in
          "./"
          ^ Ext_filename.new_extension (Filename.basename input_name) ".gen"
        in
        ( attr :: attrs,
          {
            st with
            external_module_name =
              Some { bundle; module_bind_name = Phint_nothing };
          } )
      else
        let action () =
          match txt with
          | "bs.val" | "val" ->
              if no_arguments then
                { st with val_name = name_from_payload_or_prim ~loc payload }
              else
                { st with call_name = name_from_payload_or_prim ~loc payload }
          | "bs.module" | "module" -> (
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
              | _ -> Error.err ~loc Illegal_attribute)
          | "bs.scope" | "scope" -> (
              match Ast_payload.assert_strings loc payload with
              | [] -> Error.err ~loc Illegal_attribute
              (* We need err on empty scope, so we can tell the difference
                 between unset/set
              *)
              | scopes -> { st with scopes })
          | "bs.splice" | "bs.variadic" | "variadic" ->
              { st with splice = true }
          | "bs.send" | "send" ->
              { st with val_send = name_from_payload_or_prim ~loc payload }
          | "bs.send.pipe" ->
              {
                st with
                val_send_pipe =
                  (match payload with
                  | PTyp x -> Some x
                  | _ ->
                      Location.raise_errorf ~loc
                        "expected a type after [@bs.send.pipe], e.g. \
                         [@bs.send.pipe: t]");
              }
          | "bs.set" | "set" ->
              { st with set_name = name_from_payload_or_prim ~loc payload }
          | "bs.get" | "get" ->
              { st with get_name = name_from_payload_or_prim ~loc payload }
          | "bs.new" | "new" ->
              { st with new_name = name_from_payload_or_prim ~loc payload }
          | "bs.set_index" | "set_index" ->
              if String.length prim_name_check <> 0 then
                Location.raise_errorf ~loc
                  "%@set_index this particular external's name needs to be a \
                   placeholder empty string";
              { st with set_index = true }
          | "bs.get_index" | "get_index" ->
              if String.length prim_name_check <> 0 then
                Location.raise_errorf ~loc
                  "%@get_index this particular external's name needs to be a \
                   placeholder empty string";
              { st with get_index = true }
          | "bs.obj" | "obj" -> { st with mk_obj = true }
          | "bs.return" | "return" -> (
              match Ast_payload.ident_or_record_as_config payload with
              | Ok [ ({ txt; _ }, None) ] ->
                  { st with return_wrapper = return_wrapper loc txt }
              | Ok _ -> Error.err ~loc Not_supported_directive_in_bs_return
              | Error s -> Location.raise_errorf ~loc "%s" s)
          | _ -> raise_notrace Not_handled_external_attribute
        in
        try (attrs, action ())
        with Not_handled_external_attribute -> (attr :: attrs, st))
    ([], init_st) prim_attributes

let has_bs_uncurry (attrs : Ast_attributes.t) =
  List.exists
    (fun { attr_name = { txt; loc = _ }; _ } ->
      txt = "bs.uncurry" || txt = "uncurry")
    attrs

let is_unit ty =
  match ty.ptyp_desc with
  | Ptyp_constr ({ txt = Lident "unit"; _ }, []) -> true
  | _ -> false

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
      if is_unit result_type then Return_replaced_with_unit else wrapper
  | Return_undefined_to_opt | Return_null_to_opt | Return_null_undefined_to_opt
    ->
      if is_user_option result_type then wrapper
      else Error.err ~loc Expect_opt_in_bs_return_to_opt
  | Return_replaced_with_unit ->
      assert false (* Not going to happen from user input*)

type response = {
  pval_type : Parsetree.core_type;
  pval_prim : string list;
  pval_attributes : Parsetree.attributes;
  no_inline_cross_module : bool;
}

type param_type = {
  label : Asttypes.arg_label;
  ty : Parsetree.core_type;
  attr : Parsetree.attributes;
  loc : location;
}

let mk_fn_type (new_arg_types_ty : param_type list)
    (result : Parsetree.core_type) : Parsetree.core_type =
  List.fold_right
    (fun { label; ty; attr; loc } acc ->
      {
        ptyp_desc = Ptyp_arrow (label, ty, acc);
        ptyp_loc = loc;
        ptyp_loc_stack = [ loc ];
        ptyp_attributes = attr;
      })
    new_arg_types_ty result

let process_obj (loc : Location.t) (st : external_desc) (prim_name : string)
    (arg_types_ty : param_type list) (result_type : Parsetree.core_type) :
    Parsetree.core_type * External_ffi_types.t =
  (* (Parsetree.core_type * External_ffi_types.t, string) result = *)
  match st with
  | {
   val_name = `Nm_na;
   external_module_name = None;
   module_as_val = None;
   val_send = `Nm_na;
   val_send_pipe = None;
   splice = false;
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
  } -> (
      match String.length prim_name with
      | 0 ->
          let ( arg_kinds,
                new_arg_types_ty,
                (result_types : Parsetree.object_field list) ) =
            List.fold_right
              (fun param_type
                   (arg_labels, (arg_types : param_type list), result_types) ->
                let arg_label = param_type.label in
                let loc = param_type.loc in
                let ty = param_type.ty in
                let new_arg_label, new_arg_types, output_tys =
                  match arg_label with
                  | Nolabel -> (
                      match ty.ptyp_desc with
                      | Ptyp_constr ({ txt = Lident "unit"; _ }, []) ->
                          ( External_arg_spec.empty_kind Extern_unit,
                            param_type :: arg_types,
                            result_types )
                      | _ ->
                          Location.raise_errorf ~loc
                            "expect label, optional, or unit here")
                  | Labelled name -> (
                      match refine_obj_arg_type ~nolabel:false ty with
                      | obj_arg_type -> (
                          match obj_arg_type with
                          | Ignore ->
                              ( External_arg_spec.empty_kind obj_arg_type,
                                param_type :: arg_types,
                                result_types )
                          | Arg_cst _ ->
                              let s = Lam_methname.translate name in
                              ( {
                                  obj_arg_label = External_arg_spec.obj_label s;
                                  obj_arg_type;
                                },
                                arg_types,
                                (* ignored in [arg_types], reserved in [result_types] *)
                                result_types )
                          | Nothing ->
                              let s = Lam_methname.translate name in
                              ( {
                                  obj_arg_label = External_arg_spec.obj_label s;
                                  obj_arg_type;
                                },
                                param_type :: arg_types,
                                Ast_helper.Of.tag
                                  { Asttypes.txt = name; loc }
                                  ty
                                :: result_types )
                          | Int _ ->
                              let s = Lam_methname.translate name in
                              ( {
                                  obj_arg_label = External_arg_spec.obj_label s;
                                  obj_arg_type;
                                },
                                param_type :: arg_types,
                                Ast_helper.Of.tag
                                  { Asttypes.txt = name; loc }
                                  [%type: int]
                                :: result_types )
                          | Poly_var_string _ ->
                              let s = Lam_methname.translate name in
                              ( {
                                  obj_arg_label = External_arg_spec.obj_label s;
                                  obj_arg_type;
                                },
                                param_type :: arg_types,
                                Ast_helper.Of.tag
                                  { Asttypes.txt = name; loc }
                                  [%type: string]
                                :: result_types )
                          | Fn_uncurry_arity _ ->
                              Location.raise_errorf ~loc
                                "The combination of @obj, @uncurry is not \
                                 supported yet"
                          | Extern_unit -> assert false
                          | Poly_var _ ->
                              raise
                                (Location.raise_errorf ~loc
                                   "%@obj label %s does not support such arg \
                                    type"
                                   name)
                          | Unwrap ->
                              raise
                                (Location.raise_errorf ~loc
                                   "%@obj label %s does not support %@unwrap \
                                    arguments"
                                   name)))
                  | Optional name -> (
                      match get_opt_arg_type ~nolabel:false ty with
                      | obj_arg_type -> (
                          match obj_arg_type with
                          | Ignore ->
                              ( External_arg_spec.empty_kind obj_arg_type,
                                param_type :: arg_types,
                                result_types )
                          | Nothing ->
                              let s = Lam_methname.translate name in
                              (* XXX(anmonteiro): it's unsafe to just read the type of the
                                 labelled argument declaration, since it could be `'a` in
                                 the implementation, and e.g. `bool` in the interface. See
                                 https://github.com/melange-re/melange/pull/58 for
                                 a test case. *)
                              ( {
                                  obj_arg_label =
                                    External_arg_spec.optional false s;
                                  obj_arg_type;
                                },
                                param_type :: arg_types,
                                Ast_helper.Of.tag
                                  { Asttypes.txt = name; loc }
                                  (Ast_helper.Typ.constr ~loc
                                     { txt = Ast_literal.js_undefined; loc }
                                     [ ty ])
                                :: result_types )
                          | Int _ ->
                              let s = Lam_methname.translate name in
                              ( {
                                  obj_arg_label =
                                    External_arg_spec.optional true s;
                                  obj_arg_type;
                                },
                                param_type :: arg_types,
                                Ast_helper.Of.tag
                                  { Asttypes.txt = name; loc }
                                  (Ast_helper.Typ.constr ~loc
                                     { txt = Ast_literal.js_undefined; loc }
                                     [ [%type: int] ])
                                :: result_types )
                          | Poly_var_string _ ->
                              let s = Lam_methname.translate name in
                              ( {
                                  obj_arg_label =
                                    External_arg_spec.optional true s;
                                  obj_arg_type;
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
                                "@as is not supported with optional yet"
                          | Fn_uncurry_arity _ ->
                              Location.raise_errorf ~loc
                                "The combination of @obj, @uncurry is not \
                                 supported yet"
                          | Extern_unit -> assert false
                          | Poly_var _ ->
                              Location.raise_errorf ~loc
                                "%@obj label %s does not support such arg type"
                                name
                          | Unwrap ->
                              Location.raise_errorf ~loc
                                "%@obj label %s does not support %@unwrap \
                                 arguments"
                                name))
                in
                (new_arg_label :: arg_labels, new_arg_types, output_tys))
              arg_types_ty ([], [], [])
          in

          let result =
            let open Ast_helper in
            if result_type.ptyp_desc = Ptyp_any then
              Ast_comb.to_js_type ~loc (Typ.object_ ~loc result_types Closed)
            else result_type
            (* TODO: do we need do some error checking here *)
            (* result type can not be labeled *)
          in
          ( mk_fn_type new_arg_types_ty result,
            External_ffi_types.ffi_obj_create arg_kinds )
      | _n ->
          Location.raise_errorf ~loc
            "@obj expect external names to be empty string")
  | _ -> Location.raise_errorf ~loc "Attribute found that conflicts with @obj"

let external_desc_of_non_obj (loc : Location.t) (st : external_desc)
    (prim_name_or_pval_prim : bundle_source) (arg_type_specs_length : int)
    arg_types_ty (arg_type_specs : External_arg_spec.params) :
    External_ffi_types.external_spec =
  match st with
  | {
   set_index = true;
   val_name = `Nm_na;
   external_module_name = None;
   module_as_val = None;
   val_send = `Nm_na;
   val_send_pipe = None;
   splice = false;
   scopes;
   get_index = false;
   new_name = `Nm_na;
   call_name = `Nm_na;
   set_name = `Nm_na;
   get_name = `Nm_na;
   return_wrapper = _;
   mk_obj = _;
  } ->
      if arg_type_specs_length = 3 then
        Js_set_index { js_set_index_scopes = scopes }
      else
        Location.raise_errorf ~loc
          "Ill defined attribute %@set_index (arity of 3)"
  | { set_index = true; _ } ->
      Error.err ~loc
        (Conflict_ffi_attribute
           "Attribute found that conflicts with %@set_index")
  | {
   get_index = true;
   val_name = `Nm_na;
   external_module_name = None;
   module_as_val = None;
   val_send = `Nm_na;
   val_send_pipe = None;
   splice = false;
   scopes;
   new_name = `Nm_na;
   call_name = `Nm_na;
   set_name = `Nm_na;
   get_name = `Nm_na;
   set_index = false;
   mk_obj = _;
   return_wrapper = _;
  } ->
      if arg_type_specs_length = 2 then
        Js_get_index { js_get_index_scopes = scopes }
      else
        Location.raise_errorf ~loc
          "Ill defined attribute %@get_index (arity expected 2 : while %d)"
          arg_type_specs_length
  | { get_index = true; _ } ->
      Error.err ~loc
        (Conflict_ffi_attribute
           "Attribute found that conflicts with %@get_index")
  | {
   module_as_val = Some external_module_name;
   get_index = false;
   val_name;
   new_name;
   external_module_name = None;
   val_send = `Nm_na;
   val_send_pipe = None;
   scopes = [];
   (* module as var does not need scopes *)
   splice;
   call_name = `Nm_na;
   set_name = `Nm_na;
   get_name = `Nm_na;
   set_index = false;
   return_wrapper = _;
   mk_obj = _;
  } -> (
      match (arg_types_ty, new_name, val_name) with
      | [], `Nm_na, _ -> Js_module_as_var external_module_name
      | _, `Nm_na, _ -> Js_module_as_fn { splice; external_module_name }
      | _, #bundle_source, #bundle_source ->
          Error.err ~loc
            (Conflict_ffi_attribute
               "Attribute found that conflicts with @module.")
      | _, (`Nm_val _ | `Nm_external _), `Nm_na ->
          Js_module_as_class external_module_name
      | _, `Nm_payload _, `Nm_na ->
          Location.raise_errorf ~loc
            "Incorrect FFI attribute found: (%@new should not carry a payload \
             here)")
  | { module_as_val = Some _; get_index; val_send; _ } ->
      let reason =
        match (get_index, val_send) with
        | true, _ ->
            "@module is for imports from a module, @get_index does not need \
             import a module "
        | _, #bundle_source ->
            "@module is for imports from a module, @send does not need import \
             a module "
        | _ -> "Attribute found that conflicts with @module."
      in
      Error.err ~loc (Conflict_ffi_attribute reason)
  | {
   get_name = `Nm_na;
   val_name = `Nm_na;
   call_name = `Nm_na;
   module_as_val = None;
   set_index = false;
   get_index = false;
   val_send = `Nm_na;
   val_send_pipe = None;
   new_name = `Nm_na;
   set_name = `Nm_na;
   external_module_name = None;
   splice;
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
         FIXME: splice is not supported here
      *)
        Js_var { name; external_module_name = None; scopes }
      else Js_call { splice; name; external_module_name = None; scopes }
  | {
   call_name = `Nm_val (lazy name) | `Nm_external name | `Nm_payload name;
   splice;
   scopes;
   external_module_name;
   val_name = `Nm_na;
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
        (*FIXME: splice is not supported here *)
      else Js_call { splice; name; external_module_name; scopes }
  | { call_name = #bundle_source; _ } ->
      Error.err ~loc
        (Conflict_ffi_attribute "Attribute found that conflicts with %@val")
  | {
   val_name = `Nm_val (lazy name) | `Nm_external name | `Nm_payload name;
   external_module_name;
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
   splice = false;
   scopes;
  } ->
      (*
    if no_arguments -->
          {[
            external ff : int = "" [@@val]
          ]}
       *)
      Js_var { name; external_module_name; scopes }
  | { val_name = #bundle_source; _ } ->
      Error.err ~loc
        (Conflict_ffi_attribute "Attribute found that conflicts with %@val")
  | {
   splice;
   scopes;
   external_module_name = Some _ as external_module_name;
   val_name = `Nm_na;
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
      else Js_call { splice; name; external_module_name; scopes }
  | {
   val_send = `Nm_val (lazy name) | `Nm_external name | `Nm_payload name;
   splice;
   scopes;
   val_send_pipe = None;
   val_name = `Nm_na;
   call_name = `Nm_na;
   module_as_val = None;
   set_index = false;
   get_index = false;
   new_name = `Nm_na;
   set_name = `Nm_na;
   get_name = `Nm_na;
   external_module_name = None;
   mk_obj = _;
   return_wrapper = _;
  } -> (
      (* PR #2162 - since when we assemble arguments the first argument in
         [@@send] is ignored
      *)
      match arg_type_specs with
      | [] ->
          Location.raise_errorf ~loc
            "Ill defined attribute %@send(the external needs to be a regular \
             function call with at least one argument)"
      | { arg_type = Arg_cst _; arg_label = _ } :: _ ->
          Location.raise_errorf ~loc
            "Ill defined attribute %@send(first argument can't be const)"
      | _ :: _ ->
          Js_send { splice; name; js_send_scopes = scopes; pipe = false })
  | { val_send = #bundle_source; _ } ->
      Location.raise_errorf ~loc
        "You used a FFI attribute that can't be used with %@send"
  | {
   val_send_pipe = Some _;
   (* splice = (false as splice); *)
   val_send = `Nm_na;
   val_name = `Nm_na;
   call_name = `Nm_na;
   module_as_val = None;
   set_index = false;
   get_index = false;
   new_name = `Nm_na;
   set_name = `Nm_na;
   get_name = `Nm_na;
   external_module_name = None;
   mk_obj = _;
   return_wrapper = _;
   scopes;
   splice;
  } ->
      (* can be one argument *)
      Js_send
        {
          splice;
          name = string_of_bundle_source prim_name_or_pval_prim;
          js_send_scopes = scopes;
          pipe = true;
        }
  | { val_send_pipe = Some _; _ } ->
      Location.raise_errorf ~loc
        "conflict attributes found with [%@%@bs.send.pipe]"
  | {
   new_name = `Nm_val (lazy name) | `Nm_external name | `Nm_payload name;
   external_module_name;
   val_name = `Nm_na;
   call_name = `Nm_na;
   module_as_val = None;
   set_index = false;
   get_index = false;
   val_send = `Nm_na;
   val_send_pipe = None;
   set_name = `Nm_na;
   get_name = `Nm_na;
   splice;
   scopes;
   mk_obj = _;
   return_wrapper = _;
  } ->
      Js_new { name; external_module_name; splice; scopes }
  | { new_name = #bundle_source; _ } ->
      Error.err ~loc
        (Conflict_ffi_attribute "Attribute found that conflicts with %@new")
  | {
   set_name = `Nm_val (lazy name) | `Nm_external name | `Nm_payload name;
   val_name = `Nm_na;
   call_name = `Nm_na;
   module_as_val = None;
   set_index = false;
   get_index = false;
   val_send = `Nm_na;
   val_send_pipe = None;
   new_name = `Nm_na;
   get_name = `Nm_na;
   external_module_name = None;
   splice = false;
   mk_obj = _;
   return_wrapper = _;
   scopes;
  } ->
      if arg_type_specs_length = 2 then
        Js_set { js_set_scopes = scopes; js_set_name = name }
      else
        Location.raise_errorf ~loc
          "Ill defined attribute %@set (two args required)"
  | { set_name = #bundle_source; _ } ->
      Location.raise_errorf ~loc "conflict attributes found with %@set"
  | {
   get_name = `Nm_val (lazy name) | `Nm_external name | `Nm_payload name;
   val_name = `Nm_na;
   call_name = `Nm_na;
   module_as_val = None;
   set_index = false;
   get_index = false;
   val_send = `Nm_na;
   val_send_pipe = None;
   new_name = `Nm_na;
   set_name = `Nm_na;
   external_module_name = None;
   splice = false;
   mk_obj = _;
   return_wrapper = _;
   scopes;
  } ->
      if arg_type_specs_length = 1 then
        Js_get { js_get_name = name; js_get_scopes = scopes }
      else
        Location.raise_errorf ~loc
          "Ill defined attribute %@bs.get (only one argument)"
  | { get_name = #bundle_source; _ } ->
      Location.raise_errorf ~loc "Attribute found that conflicts with %@bs.get"

let list_of_arrow (ty : Parsetree.core_type) :
    Parsetree.core_type * param_type list =
  let rec aux (ty : Parsetree.core_type) acc =
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

(* Note that the passed [type_annotation] is already processed by visitor pattern before*)
let handle_attributes (loc : Location.t) (type_annotation : Parsetree.core_type)
    (prim_attributes : Ast_attributes.t) (pval_name : string)
    (prim_name : string) :
    Parsetree.core_type * External_ffi_types.t * Parsetree.attributes * bool =
  (* sanity check here
      {[ int -> int -> (int -> int -> int [@uncurry])]}
      It does not make sense
  *)
  if has_bs_uncurry type_annotation.ptyp_attributes then
    Location.raise_errorf ~loc
      "@uncurry can not be applied to the whole definition"
  else
    let prim_name_or_pval_name =
      if String.length prim_name = 0 then
        `Nm_val
          (lazy
            (Bs_ast_invariant.warn ~loc (Fragile_external pval_name);
             pval_name))
      else `Nm_external prim_name (* need check name *)
    in
    let result_type, arg_types_ty =
      (* Note this assumes external type is syntatic (no abstraction)*)
      list_of_arrow type_annotation
    in
    if has_bs_uncurry result_type.ptyp_attributes then
      Location.raise_errorf ~loc
        "@uncurry can not be applied to tailed position"
    else
      let no_arguments = arg_types_ty = [] in
      let unused_attrs, external_desc =
        parse_external_attributes no_arguments prim_name prim_name_or_pval_name
          prim_attributes
      in
      if external_desc.mk_obj then
        (* warn unused attributes here ? *)
        let new_type, spec =
          process_obj loc external_desc prim_name arg_types_ty result_type
        in
        (new_type, spec, unused_attrs, false)
      else
        let splice = external_desc.splice in
        let arg_type_specs, new_arg_types_ty, arg_type_specs_length =
          let (init : External_arg_spec.params * param_type list * int) =
            match external_desc.val_send_pipe with
            | Some obj -> (
                match refine_arg_type ~nolabel:true obj with
                | Arg_cst _ ->
                    Location.raise_errorf ~loc
                      "@as is not supported in @send type "
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
            (fun param_type (arg_type_specs, arg_types, i) ->
              let arg_label = param_type.label in
              let ty = param_type.ty in
              (if i = 0 && splice then
                 match arg_label with
                 | Optional _ ->
                     Location.raise_errorf ~loc
                       "@bs.variadic expects the last type to be a non optional"
                 | Labelled _ | Nolabel -> (
                     if ty.ptyp_desc = Ptyp_any then
                       Location.raise_errorf
                         "@bs.variadic expect the last type to be an array"
                     else
                       match spec_of_ptyp true ty with
                       | Nothing -> (
                           match ty.ptyp_desc with
                           | Ptyp_constr ({ txt = Lident "array"; _ }, [ _ ]) ->
                               ()
                           | _ ->
                               Location.raise_errorf ~loc
                                 "@bs.variadic expect the last type to be an \
                                  array")
                       | _ ->
                           Location.raise_errorf ~loc
                             "%@variadic expect the last type to be an array"));
              let ( (arg_label : External_arg_spec.label_noname),
                    arg_type,
                    new_arg_types ) =
                match arg_label with
                | Optional s -> (
                    match get_opt_arg_type ~nolabel:false ty with
                    | Poly_var _ ->
                        (* ?x:([`x of int ] [@string]) does not make sense *)
                        Location.raise_errorf ~loc
                          "%@bs.string does not work with optional when it has \
                           arities in label %s"
                          s
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
            arg_types_ty init
        in

        let ffi : External_ffi_types.external_spec =
          external_desc_of_non_obj loc external_desc prim_name_or_pval_name
            arg_type_specs_length arg_types_ty arg_type_specs
        in
        let relative = External_ffi_types.check_ffi ~loc ffi in
        (* result type can not be labeled *)
        (* currently we don't process attributes of
           return type, in the future we may *)
        let return_wrapper =
          check_return_wrapper loc external_desc.return_wrapper result_type
        in
        ( mk_fn_type new_arg_types_ty result_type,
          External_ffi_types.ffi_bs arg_type_specs return_wrapper ffi,
          unused_attrs,
          relative )

let handle_attributes_as_string (pval_loc : Location.t)
    (typ : Parsetree.core_type) (attrs : Ast_attributes.t) (pval_name : string)
    (prim_name : string) : response =
  let pval_type, ffi, pval_attributes, no_inline_cross_module =
    handle_attributes pval_loc typ attrs pval_name prim_name
  in
  {
    pval_type;
    pval_prim = [ prim_name; External_ffi_types.to_string ffi ];
    pval_attributes;
    no_inline_cross_module;
  }

let pval_prim_of_labels (labels : string Asttypes.loc list) =
  let arg_kinds =
    List.fold_right
      (fun p arg_kinds ->
        let obj_arg_label =
          External_arg_spec.obj_label (Lam_methname.translate p.txt)
        in
        { External_arg_spec.obj_arg_type = Nothing; obj_arg_label } :: arg_kinds)
      labels []
  in
  External_ffi_types.ffi_obj_as_prims arg_kinds
