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
module E = Js_exp_make

let splice_fn_apply fn args =
  E.runtime_call ~module_name:Js_runtime_modules.caml_splice_call
    ~fn_name:"spliceApply"
    [ fn; E.array Immutable args ]

let splice_fn_new_apply fn args =
  E.runtime_call ~module_name:Js_runtime_modules.caml_splice_call
    ~fn_name:"spliceNewApply"
    [ fn; E.array Immutable args ]

let splice_obj_fn_apply obj name args =
  E.runtime_call ~module_name:Js_runtime_modules.caml_splice_call
    ~fn_name:"spliceObjApply"
    [ obj; E.str name; E.array Immutable args ]

(*
   [bind_name] is a hint to the compiler to generate
   better names for external module
*)
(* let handle_external
     ({bundle ; module_bind_name} : External_ffi_types.external_module_name)
   : Ident.t * string
   =
   Lam_compile_env.add_js_module module_bind_name bundle ,
   bundle *)

let external_var
    ({ bundle; module_bind_name } : External_ffi_types.external_module_name)
    ~dynamic_import =
  let id =
    Lam_compile_env.add_js_module module_bind_name bundle ~default:false
      ~dynamic_import
  in
  E.external_var id ~external_name:bundle ~dynamic_import

(* let handle_external_opt
     (module_name : External_ffi_types.external_module_name option)
   : (Ident.t * string) option =
   match module_name with
   | Some module_name -> Some (handle_external module_name)
   | None -> None
*)

type arg_expression = Js_of_lam_variant.arg_expression =
  | Splice0
  | Splice1 of E.t
  | Splice2 of E.t * E.t

let append_list x xs =
  match x with
  | Splice0 -> xs
  | Splice1 a -> a :: xs
  | Splice2 (a, b) -> a :: b :: xs

(* The first return value is value, the second argument is side effect expressions
    Only the [unit] with no label will be ignored
    When  we are passing a boxed value to external(optional), we need
    unbox it in the first place.

    Note when optional value is not passed, the unboxed value would be
    [undefined], with the combination of `[@int]` it would be still be
    [undefined], this by default is still correct..
    {[
      (function () {
           switch (undefined) {
             case 97 :
               return "a";
             case 98 :
               return "b";

           }
         }()) === undefined
    ]}

     This would not work with [NonNullString] *)
let rec ocaml_to_js_eff =
  let dispatch_has_field
      (dispatches : (string * Melange_ffi.External_arg_spec.Arg_cst.t) list)
      (fields : J.expression list) =
    match fields with
    | { expression_desc = Str s; _ } :: _ ->
        List.exists dispatches ~f:(fun (dispatch, _) -> dispatch = s)
    | _ -> false
  in
  let splice1_single_arg ~arg_label raw_arg =
    let single_arg =
      match arg_label with
      | External_arg_spec.Arg_label.Arg_optional ->
          (* If this is an optional arg (like `?arg`), we have to potentially
             do 2 levels of unwrapping:
               - if ocaml arg is `None`, let js arg be `undefined` (no
                 unwrapping)
               - if ocaml arg is `Some x`, unwrap the arg to get the `x`, then
                 unwrap the `x` itself 
                 - Here `Some x` is `x` due to the current encoding Lets inline
                   here since it depends on the runtime encoding *)
          Js_of_lam_option.option_unwrap raw_arg
      | _ -> Js_of_lam_variant.eval_as_unwrap raw_arg
    in
    (Splice1 single_arg, [])
  in
  fun ~arg_label ~arg_type raw_arg ->
    let arg =
      match arg_label with
      | External_arg_spec.Arg_label.Arg_optional ->
          Js_of_lam_option.get_default_undefined_from_optional raw_arg
      | Arg_label | Arg_empty -> raw_arg
    in
    match arg_type with
    | External_arg_spec.Arg_cst _ | Fn_uncurry_arity _ -> assert false
    (* has to be preprocessed by {!Lam} module first *)
    | Extern_unit ->
        let splice =
          match arg_label with
          | Arg_empty -> Splice0
          | Arg_optional | Arg_label -> Splice1 E.unit
        in
        ( splice,
          if Js_analyzer.no_side_effect_expression arg then [] else [ arg ] )
        (* leave up later to decide *)
    | Ignore ->
        ( Splice0,
          if Js_analyzer.no_side_effect_expression arg then [] else [ arg ] )
    | Poly_var { descr; spread } | Int { descr; spread } ->
        ( (if spread then Js_of_lam_variant.eval_descr arg descr
           else Splice1 (Js_of_lam_variant.eval arg descr)),
          [] )
    | Unwrap polyvar -> (
        match (polyvar, raw_arg.expression_desc) with
        | Poly_var { descr; spread = false }, Caml_block { fields; _ } ->
            if dispatch_has_field descr fields then
              Location.raise_errorf ?loc:raw_arg.loc
                "`[@mel.as ..]' can only be used with `[@mel.unwrap]' variants \
                 without a payload."
            else splice1_single_arg ~arg_label raw_arg
        | Int _, _ ->
            (* We don't support `@mel.int` with `@mel.unwrap` *)
            assert false
        | Poly_var { spread = false; _ }, _ ->
            ocaml_to_js_eff ~arg_label ~arg_type:polyvar raw_arg
        | Nothing, _ -> splice1_single_arg ~arg_label raw_arg
        | _, _ -> assert false)
    | Nothing -> (Splice1 arg, [])

let empty_pair = ([], [])
let add_eff eff e = match eff with None -> e | Some v -> E.seq v e

type specs = External_arg_spec.Arg_label.t External_arg_spec.param list
type exprs = E.t list

(* TODO: fix splice,
   we need a static guarantee that it is static array construct
   otherwise, we should provide a good error message here,
   no compiler failure here
   Invariant : Array encoding
   @return arguments and effect
*)
let assemble_args_no_splice =
  let rec aux (labels : specs) (args : exprs) : exprs * exprs =
    match (labels, args) with
    | [], _ ->
        assert (args = []);
        empty_pair
    | { arg_type = Arg_cst cst; _ } :: labels, args ->
        (* can not be Optional *)
        let accs, eff = aux labels args in
        (Lam_compile_const.translate_arg_cst cst :: accs, eff)
    | { arg_label; arg_type } :: labels, arg :: args ->
        let accs, eff = aux labels args in
        let acc, new_eff = ocaml_to_js_eff ~arg_label ~arg_type arg in
        (append_list acc accs, List.append new_eff eff)
    | _ :: _, [] -> assert false
  in

  fun (args : exprs) (arg_types : specs) : (exprs * E.t option) ->
    let args, eff = aux arg_types args in
    ( args,
      match eff with
      | [] -> None
      | x :: xs ->
          (* FIXME: the order of effects? *)
          Some (E.fuse_to_seq x xs) )

let assemble_args_has_splice (arg_types : specs) (args : exprs) :
    exprs * E.t option * bool =
  let dynamic = ref false in
  let rec aux (labels : specs) (args : exprs) =
    match (labels, args) with
    | [], _ ->
        assert (args = []);
        empty_pair
    | { arg_type = Arg_cst cst; _ } :: labels, args ->
        let accs, eff = aux labels args in
        (Lam_compile_const.translate_arg_cst cst :: accs, eff)
    | { arg_label; arg_type } :: labels, arg :: args -> (
        let accs, eff = aux labels args in
        match (args, (arg : E.t)) with
        | [], { expression_desc = Array { items = ls; _ }; _ } ->
            (List.append ls accs, eff)
        | _ ->
            if args = [] then dynamic := true;
            let acc, new_eff = ocaml_to_js_eff ~arg_type ~arg_label arg in
            (append_list acc accs, List.append new_eff eff))
    | _ :: _, [] -> assert false
  in
  let args, eff = aux arg_types args in
  ( args,
    (match eff with
    | [] -> None
    | x :: xs ->
        (* FIXME: the order of effects? *)
        Some (E.fuse_to_seq x xs)),
    !dynamic )

let translate_scoped_module_val
    (module_name : External_ffi_types.external_module_name option) (fn : string)
    (scopes : string list) ~dynamic_import =
  match module_name with
  | Some { bundle; module_bind_name } -> (
      match scopes with
      | [] ->
          let default = fn = "default" in
          let id =
            Lam_compile_env.add_js_module module_bind_name bundle ~default
              ~dynamic_import
          in
          E.external_var_field ~dynamic_import ~external_name:bundle ~field:fn
            ~default id
      | x :: rest ->
          let default =
            (* TODO: what happens when scope contains "default"? *)
            false
          in
          let id =
            Lam_compile_env.add_js_module module_bind_name bundle ~default
              ~dynamic_import
          in
          let start =
            E.external_var_field ~dynamic_import ~external_name:bundle ~field:x
              ~default id
          in
          List.fold_left ~f:E.dot ~init:start (List.append rest [ fn ]))
  | None -> (
      (*  no [@@module], assume it's global *)
      match scopes with
      | [] -> E.js_global fn
      | x :: rest ->
          let start = E.js_global x in
          List.fold_left ~f:E.dot ~init:start (rest @ [ fn ]))

let translate_ffi =
  let js_send_self_and_args =
    let rec aux ~self_idx args specs (acc_args, acc_specs, cur_idx) =
      match (args, specs) with
      | [], [] -> assert false
      | ( args,
          (* constant args get elided from the `external type` but not the arg
             specs. *)
          ({ External_arg_spec.arg_type = Arg_cst cst; _ } as spec) :: specs )
        ->
          if self_idx = cur_idx then
            ( Lam_compile_const.translate_arg_cst cst,
              List.rev_append acc_args args,
              List.rev_append acc_specs specs )
          else
            aux ~self_idx args specs (acc_args, spec :: acc_specs, cur_idx + 1)
      | self :: args, spec :: specs ->
          if self_idx = cur_idx then
            (* PR2162 [self_type] more checks in syntax:
                 - should not be [@as] *)
            ( self,
              List.rev_append acc_args args,
              List.rev_append acc_specs specs )
          else
            aux ~self_idx args specs
              (self :: acc_args, spec :: acc_specs, cur_idx + 1)
      | [], _ :: _ | _ :: _, [] -> assert false
    in
    fun args arg_types ~self_idx -> aux args arg_types ~self_idx ([], [], 0)
  in
  let translate_scoped_access scopes obj =
    match scopes with
    | [] -> obj
    | x :: xs -> List.fold_left ~f:E.dot ~init:(E.dot obj x) xs
  in
  let process_send ~new_ self name args =
    match new_ with
    | true -> E.new_ (E.dot self name) args
    | false ->
        E.call
          ~info:{ arity = Full; call_info = Call_na }
          (E.dot self name) args
  in
  fun (cxt : Lam_compile_context.t)
    arg_types
    (ffi : External_ffi_types.external_spec)
    (args : J.expression list)
    ~dynamic_import
  ->
    match ffi with
    | Js_call
        { external_module_name = module_name; name = fn; variadic; scopes } -> (
        let fn =
          translate_scoped_module_val module_name fn scopes ~dynamic_import
        in
        match (arg_types, args) with
        | _ :: _, [] ->
            (* We end up here in the following case:

                external x : ('a -> 'a array[@u]) = "x"
                let x = x

               An uncurried external being used as an OCaml value:
                 - arg types were extracted to process attributes, but there
                   are no args since the function is being used as a value.
            *)
            fn
        | _ ->
            if variadic then
              let args, eff, dynamic =
                assemble_args_has_splice arg_types args
              in
              add_eff eff
                (if dynamic then splice_fn_apply fn args
                 else E.call ~info:{ arity = Full; call_info = Call_na } fn args)
            else
              let args, eff = assemble_args_no_splice args arg_types in
              add_eff eff
              @@ E.call ~info:{ arity = Full; call_info = Call_na } fn args)
    | Js_module_as_fn { external_module_name; variadic } ->
        let fn = external_var ~dynamic_import external_module_name in
        if variadic then
          let args, eff, dynamic = assemble_args_has_splice arg_types args in
          (* TODO: fix in rest calling convention *)
          add_eff eff
            (if dynamic then splice_fn_apply fn args
             else E.call ~info:{ arity = Full; call_info = Call_na } fn args)
        else
          let args, eff = assemble_args_no_splice args arg_types in
          (* TODO: fix in rest calling convention *)
          add_eff eff
            (E.call ~info:{ arity = Full; call_info = Call_na } fn args)
    | Js_new { external_module_name = module_name; name = fn; variadic; scopes }
      ->
        (* handle [@@new]*)
        (* This has some side effect, it will
           mark its identifier (If it has) as an object,
           ATTENTION:
           order also matters here, since we mark its jsobject property,
           it  will affect the code gen later
           TODO: we should propagate this property
           as much as we can(in alias table)
        *)
        let fn =
          translate_scoped_module_val module_name fn scopes ~dynamic_import
        in
        if variadic then
          let args, eff, dynamic = assemble_args_has_splice arg_types args in
          add_eff eff
            (if dynamic then splice_fn_new_apply fn args else E.new_ fn args)
        else
          let args, eff = assemble_args_no_splice args arg_types in
          add_eff eff
            (* (match cxt.continuation with *)
            (* | Declare (let_kind, id) -> *)
            (* cxt.continuation <- Declare (let_kind, Ext_ident.make_js_object id) *)
            (* | Assign id  -> *)
            (* cxt.continuation <- Assign (Ext_ident.make_js_object id) *)
            (* | EffectCall _ | NeedValue _ -> ()); *)
            (E.new_ fn args)
    | Js_send { variadic; name; self_idx; scopes; new_ } -> (
        match variadic with
        (* variadic should not happen *)
        (* assert (js_splice = false) ;  *)
        | true ->
            let self, args, arg_types =
              js_send_self_and_args args arg_types ~self_idx
            in
            let args, eff, dynamic = assemble_args_has_splice arg_types args in
            let self = translate_scoped_access scopes self in
            add_eff eff
              (if dynamic then
                 match new_ with
                 | true -> splice_fn_new_apply (E.dot self name) args
                 | false -> splice_obj_fn_apply self name args
               else process_send ~new_ self name args)
        | false ->
            let self, args, arg_types =
              js_send_self_and_args args arg_types ~self_idx
            in
            let args, eff = assemble_args_no_splice args arg_types in
            let self = translate_scoped_access scopes self in
            add_eff eff (process_send ~new_ self name args))
    | Js_module_as_var module_name -> external_var ~dynamic_import module_name
    | Js_var { name; external_module_name; scopes } ->
        (* TODO #11
           1. check args -- error checking
           2. support [@@scope "window"]
           we need know whether we should call [add_js_module] or not
        *)
        translate_scoped_module_val external_module_name name scopes
          ~dynamic_import
    | Js_module_as_class module_name ->
        let fn = external_var ~dynamic_import module_name in
        let args, eff = assemble_args_no_splice args arg_types in
        (* TODO: fix in rest calling convention *)
        add_eff eff
          ((match cxt.continuation with
           | Declare (let_kind, id) ->
               cxt.continuation <- Declare (let_kind, Ident.make_js_object id)
           | Assign id -> cxt.continuation <- Assign (Ident.make_js_object id)
           | EffectCall _ | NeedValue _ -> ());
           E.new_ fn args)
    | Js_get { name; scopes } -> (
        let args, cur_eff = assemble_args_no_splice args arg_types in
        add_eff cur_eff
        @@
        match args with
        | [ obj ] ->
            let obj = translate_scoped_access scopes obj in
            E.dot obj name
        | _ -> assert false (* Note these assertion happens in call site *))
    | Js_set { name; scopes } -> (
        (* assert (js_splice = false) ;  *)
        let args, cur_eff = assemble_args_no_splice args arg_types in
        add_eff cur_eff
        @@
        match (args, arg_types) with
        | [ obj; v ], _ ->
            let obj = translate_scoped_access scopes obj in
            E.assign (E.dot obj name) v
        | _ -> assert false)
    | Js_get_index { scopes } -> (
        let args, cur_eff = assemble_args_no_splice args arg_types in
        add_eff cur_eff
        @@
        match args with
        | [ obj; v ] -> E.array_index (translate_scoped_access scopes obj) v
        | _ -> assert false)
    | Js_set_index { scopes } -> (
        let args, cur_eff = assemble_args_no_splice args arg_types in
        add_eff cur_eff
        @@
        match args with
        | [ obj; v; value ] ->
            E.assign
              (E.array_index (translate_scoped_access scopes obj) v)
              value
        | _ -> assert false)
