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
module E = Js_exp_make

let splice_fn_apply fn args =
  E.runtime_call Js_runtime_modules.caml_splice_call "spliceApply"
    [ fn; E.array Immutable args ]

let splice_fn_new_apply fn args =
  E.runtime_call Js_runtime_modules.caml_splice_call "spliceNewApply"
    [ fn; E.array Immutable args ]

let splice_obj_fn_apply obj name args =
  E.runtime_call Js_runtime_modules.caml_splice_call "spliceObjApply"
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
    ({ bundle; module_bind_name } :
      Melange_ffi.External_ffi_types.external_module_name) =
  let id = Lam_compile_env.add_js_module module_bind_name bundle false in
  E.external_var id ~external_name:bundle

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

     This would not work with [NonNullString]
*)
let ocaml_to_js_eff ~(arg_label : Melange_ffi.External_arg_spec.label_noname)
    ~(arg_type : Melange_ffi.External_arg_spec.attr) (raw_arg : E.t) :
    arg_expression * E.t list =
  let arg =
    match arg_label with
    | Arg_optional ->
        Js_of_lam_option.get_default_undefined_from_optional raw_arg
    | Arg_label | Arg_empty -> raw_arg
  in
  match arg_type with
  | Arg_cst _ -> assert false
  | Fn_uncurry_arity _ -> assert false
  (* has to be preprocessed by {!Lam} module first *)
  | Extern_unit ->
      ( (if arg_label = Arg_empty then Splice0 else Splice1 E.unit),
        if Js_analyzer.no_side_effect_expression arg then [] else [ arg ] )
      (* leave up later to decide *)
  | Ignore ->
      ( Splice0,
        if Js_analyzer.no_side_effect_expression arg then [] else [ arg ] )
  | Poly_var_string { descr } -> (Splice1 (Js_of_lam_variant.eval arg descr), [])
  | Poly_var { descr } ->
      (Js_of_lam_variant.eval_as_event arg descr, [])
      (* FIXME: encode invariant below in the signature*)
      (* length of 2
         - the poly var tag
         - the value
      *)
  | Int dispatches ->
      (Splice1 (Js_of_lam_variant.eval_as_int arg dispatches), [])
  | Unwrap ->
      let single_arg =
        match arg_label with
        | Arg_optional ->
            (*
           If this is an optional arg (like `?arg`), we have to potentially do
           2 levels of unwrapping:
           - if ocaml arg is `None`, let js arg be `undefined` (no unwrapping)
           - if ocaml arg is `Some x`, unwrap the arg to get the `x`, then
             unwrap the `x` itself
           - Here `Some x` is `x` due to the current encoding
           Lets inline here since it depends on the runtime encoding
        *)
            Js_of_lam_option.option_unwrap raw_arg
        | _ -> Js_of_lam_variant.eval_as_unwrap raw_arg
      in
      (Splice1 single_arg, [])
  | Nothing -> (Splice1 arg, [])

let empty_pair = ([], [])
let add_eff eff e = match eff with None -> e | Some v -> E.seq v e

type specs = Melange_ffi.External_arg_spec.param list
type exprs = E.t list

(* TODO: fix splice,
   we need a static guarantee that it is static array construct
   otherwise, we should provide a good error message here,
   no compiler failure here
   Invariant : Array encoding
   @return arguments and effect
*)
let assemble_args_no_splice (arg_types : specs) (args : exprs) :
    exprs * E.t option =
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
        | [], { expression_desc = Array (ls, _mutable_flag); _ } ->
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
    (module_name : Melange_ffi.External_ffi_types.external_module_name option)
    (fn : string) (scopes : string list) =
  match module_name with
  | Some { bundle; module_bind_name } -> (
      match scopes with
      | [] ->
          let default = fn = "default" in
          let id =
            Lam_compile_env.add_js_module module_bind_name bundle default
          in
          E.external_var_field ~external_name:bundle ~field:fn ~default id
      | x :: rest ->
          (* TODO: what happens when scope contains "default" ?*)
          let default = false in
          let id =
            Lam_compile_env.add_js_module module_bind_name bundle default
          in
          let start =
            E.external_var_field ~external_name:bundle ~field:x ~default id
          in
          List.fold_left ~f:E.dot ~init:start (List.append rest [ fn ]))
  | None -> (
      (*  no [@@module], assume it's global *)
      match scopes with
      | [] -> E.js_global fn
      | x :: rest ->
          let start = E.js_global x in
          List.fold_left ~f:E.dot ~init:start (rest @ [ fn ]))

let translate_scoped_access scopes obj =
  match scopes with
  | [] -> obj
  | x :: xs -> List.fold_left ~f:E.dot ~init:(E.dot obj x) xs

let translate_ffi =
  let process_send ~new_ self name args =
    match new_ with
    | true -> E.new_ (E.dot self name) args
    | false ->
        E.call
          ~info:{ arity = Full; call_info = Call_na }
          (E.dot self name) args
  in
  fun (cxt : Lam_compile_context.t) arg_types
      (ffi : Melange_ffi.External_ffi_types.external_spec)
      (args : J.expression list) ->
    match ffi with
    | Js_call
        { external_module_name = module_name; name = fn; variadic; scopes } -> (
        let fn = translate_scoped_module_val module_name fn scopes in
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
              let args, eff = assemble_args_no_splice arg_types args in
              add_eff eff
              @@ E.call ~info:{ arity = Full; call_info = Call_na } fn args)
    | Js_module_as_fn { external_module_name; variadic } ->
        let fn = external_var external_module_name in
        if variadic then
          let args, eff, dynamic = assemble_args_has_splice arg_types args in
          (* TODO: fix in rest calling convention *)
          add_eff eff
            (if dynamic then splice_fn_apply fn args
             else E.call ~info:{ arity = Full; call_info = Call_na } fn args)
        else
          let args, eff = assemble_args_no_splice arg_types args in
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
        let fn = translate_scoped_module_val module_name fn scopes in
        if variadic then
          let args, eff, dynamic = assemble_args_has_splice arg_types args in
          add_eff eff
            (if dynamic then splice_fn_new_apply fn args else E.new_ fn args)
        else
          let args, eff = assemble_args_no_splice arg_types args in
          add_eff eff
            (* (match cxt.continuation with *)
            (* | Declare (let_kind, id) -> *)
            (* cxt.continuation <- Declare (let_kind, Ext_ident.make_js_object id) *)
            (* | Assign id  -> *)
            (* cxt.continuation <- Assign (Ext_ident.make_js_object id) *)
            (* | EffectCall _ | NeedValue _ -> ()); *)
            (E.new_ fn args)
    | Js_send { variadic; name; pipe; js_send_scopes; new_ } -> (
        if pipe then
          (* variadic should not happen *)
          (* assert (js_splice = false) ;  *)
          if variadic then
            let args, self = List.split_at_last args in
            let arg_types, _ = List.split_at_last arg_types in
            let args, eff, dynamic = assemble_args_has_splice arg_types args in
            add_eff eff
              (let self = translate_scoped_access js_send_scopes self in
               if dynamic then splice_obj_fn_apply self name args
               else process_send ~new_ self name args)
          else
            let args, self = List.split_at_last args in
            let arg_types, _ = List.split_at_last arg_types in
            let args, eff = assemble_args_no_splice arg_types args in
            add_eff eff
              (let self = translate_scoped_access js_send_scopes self in
               process_send ~new_ self name args)
        else
          match args with
          | self :: args ->
              (* PR2162 [self_type] more checks in syntax:
                 - should not be [@as] *)
              let[@ocaml.warning "-partial-match"] (_self_type :: arg_types) =
                arg_types
              in
              if variadic then
                let args, eff, dynamic =
                  assemble_args_has_splice arg_types args
                in
                add_eff eff
                  (let self = translate_scoped_access js_send_scopes self in
                   if dynamic then
                     match new_ with
                     | true -> splice_fn_new_apply (E.dot self name) args
                     | false -> splice_obj_fn_apply self name args
                   else process_send ~new_ self name args)
              else
                let args, eff = assemble_args_no_splice arg_types args in
                add_eff eff
                  (let self = translate_scoped_access js_send_scopes self in
                   process_send ~new_ self name args)
          | _ -> assert false)
    | Js_module_as_var module_name -> external_var module_name
    | Js_var { name; external_module_name; scopes } ->
        (* TODO #11
           1. check args -- error checking
           2. support [@@scope "window"]
           we need know whether we should call [add_js_module] or not
        *)
        translate_scoped_module_val external_module_name name scopes
    | Js_module_as_class module_name ->
        let fn = external_var module_name in
        let args, eff = assemble_args_no_splice arg_types args in
        (* TODO: fix in rest calling convention *)
        add_eff eff
          ((match cxt.continuation with
           | Declare (let_kind, id) ->
               cxt.continuation <- Declare (let_kind, Ident.make_js_object id)
           | Assign id -> cxt.continuation <- Assign (Ident.make_js_object id)
           | EffectCall _ | NeedValue _ -> ());
           E.new_ fn args)
    | Js_get { js_get_name = name; js_get_scopes = scopes } -> (
        let args, cur_eff = assemble_args_no_splice arg_types args in
        add_eff cur_eff
        @@
        match args with
        | [ obj ] ->
            let obj = translate_scoped_access scopes obj in
            E.dot obj name
        | _ -> assert false (* Note these assertion happens in call site *))
    | Js_set { js_set_name = name; js_set_scopes = scopes } -> (
        (* assert (js_splice = false) ;  *)
        let args, cur_eff = assemble_args_no_splice arg_types args in
        add_eff cur_eff
        @@
        match (args, arg_types) with
        | [ obj; v ], _ ->
            let obj = translate_scoped_access scopes obj in
            E.assign (E.dot obj name) v
        | _ -> assert false)
    | Js_get_index { js_get_index_scopes = scopes } -> (
        let args, cur_eff = assemble_args_no_splice arg_types args in
        add_eff cur_eff
        @@
        match args with
        | [ obj; v ] -> E.array_index (translate_scoped_access scopes obj) v
        | _ -> assert false)
    | Js_set_index { js_set_index_scopes = scopes } -> (
        let args, cur_eff = assemble_args_no_splice arg_types args in
        add_eff cur_eff
        @@
        match args with
        | [ obj; v; value ] ->
            E.assign
              (E.array_index (translate_scoped_access scopes obj) v)
              value
        | _ -> assert false)
