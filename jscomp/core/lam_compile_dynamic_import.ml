(* Copyright (C) 2025- Authors of Melange
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
module E = Js_exp_make
module S = Js_stmt_make
module Arg = Melange_ffi.External_arg_spec

(* Resolve an external before compiling its adapter. The outermost JavaScript
   call may be an option or variadic runtime helper, not the imported function. *)
let prepare_external value =
  let rec find_call = function
    | Lam.Lprim
        ({
           primitive =
             Pjs_call
               {
                 ffi =
                   ( Js_call { external_module_name = Some _; _ }
                   | Js_new { external_module_name = Some _; _ }
                   | Js_module_as_fn _ | Js_module_as_class _
                   | Js_var { external_module_name = Some _; _ } );
                 _;
               };
           _;
         } as call) ->
        Some call
    | Lfunction { attr = { stub = true; _ }; body; _ }
    | Lsequence (body, Lconst (Const_js_undefined _))
    | Lprim
        {
          primitive =
            Popaque | Pnull_to_opt | Pundefined_to_opt | Pnull_undefined_to_opt;
          args = [ body ];
          _;
        } ->
        find_call body
    | _ -> None
  in
  match find_call value with
  | None -> None
  | Some
      ({ primitive = Pjs_call { prim_name; arg_types; ffi; _ }; loc; _ } as call)
    ->
      let module_, name, scopes, variadic, new_, is_value =
        match ffi with
        | Js_call
            { external_module_name = Some module_; name; scopes; variadic } ->
            (module_, name, scopes, variadic, false, false)
        | Js_new { external_module_name = Some module_; name; scopes; variadic }
          ->
            (module_, name, scopes, variadic, true, false)
        | Js_var { external_module_name = Some module_; name; scopes } ->
            (module_, name, scopes, false, false, true)
        | Js_module_as_fn { external_module_name = module_; variadic } ->
            (module_, "default", [], variadic, false, false)
        | Js_module_as_class module_ ->
            (module_, "default", [], false, true, false)
        | _ -> assert false
      in
      let module_id =
        match
          (Lam_compile_external_call.external_var module_ ~dynamic_import:true)
            .expression_desc
        with
        | J.Var (J.Qualified (module_id, _)) -> module_id
        | _ -> assert false
      in
      let receiver = Ident.create "m" in
      let get =
        Lam.prim ~loc
          ~primitive:
            (Pjs_call
               {
                 prim_name;
                 arg_types = [ Arg.dummy ];
                 ffi = Js_get { name; scopes };
                 dynamic_import = false;
               })
          ~args:[ Lam.var receiver ]
      in
      let needs_arguments =
        variadic || new_
        || List.exists arg_types ~f:(fun { Arg.Param.arg_type; arg_label } ->
            match (arg_type, arg_label) with
            | Nothing, (Arg.Arg_label.Arg_empty | Arg_label) -> false
            | _ -> true)
      in
      let identity =
        (not needs_arguments)
        && match value with Lprim p when p == call -> p.args = [] | _ -> false
      in
      let rec rebind args = function
        | Lam.Lprim p when p == call ->
            if is_value then get
            else
              Lam_ffi.handle_mel_non_obj_ffi (Arg.dummy :: arg_types)
                Return_identity
                (Js_send { name; scopes; variadic; new_; self_idx = 0 })
                (Lam.var receiver :: args) ~loc prim_name ~dynamic_import:false
        | value -> Lam.inner_map value (rebind args)
      in
      let adapted =
        if identity then get
        else
          match value with
          (* Curried externals also need their declared arity: the JavaScript
             function's length may differ because of default/rest parameters. *)
          | Lfunction _ -> rebind call.args value
          | _ when is_value -> rebind [] value
          | _ ->
              (* Uncurried externals are represented as an unapplied primitive,
               rather than an eta-expanded Lambda function. *)
              let params =
                List.filter_map arg_types ~f:(fun { Arg.Param.arg_type; _ } ->
                    match arg_type with
                    | Arg_cst _ -> None
                    | _ -> Some (Ident.create "arg"))
              in
              Lam.function_ ~attr:Lambda.default_function_attribute
                ~arity:(List.length params) ~params
                ~body:(rebind (List.map params ~f:Lam.var) value)
      in
      Some (module_id, receiver, adapted)
  | Some _ -> assert false

let wrap_module_value =
  let import_of_module module_ =
    E.call
      ~info:{ arity = Full; call_info = Call_na }
      (E.js_global "import")
      [ E.module_ module_ ]
  in
  let wrap_then import value =
    let arg = Ident.create "m" in
    E.call
      ~info:{ arity = Full; call_info = Call_na }
      (E.dot import "then")
      [
        E.ocaml_fun ~return_unit:false [ arg ]
          [
            {
              statement_desc = J.Return (E.dot (E.var arg) value);
              comment = None;
            };
          ];
      ]
  in
  fun module_id module_value ->
    let module_ = { module_id with J.dynamic_import = true } in
    let import = import_of_module module_ in
    match module_value with
    | Some value -> wrap_then import value
    | None -> import

let wrap_callback module_id arg body =
  E.call
    ~info:{ arity = Full; call_info = Call_na }
    (E.dot (wrap_module_value module_id None) "then")
    [ E.ocaml_fun ~return_unit:false [ arg ] body ]
