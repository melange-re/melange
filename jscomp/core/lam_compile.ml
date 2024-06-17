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
module S = Js_stmt_make

let args_either_function_or_const (args : Lam.t list) =
  List.for_all
    ~f:(fun (x : Lam.t) ->
      match x with Lfunction _ | Lconst _ -> true | _ -> false)
    args

let call_info_of_ap_status (ap_status : Lam.apply_status) : Js_call_info.t =
  match ap_status with
  | App_infer_full -> { arity = Full; call_info = Call_ml }
  | App_uncurry -> { arity = Full; call_info = Call_na }
  | App_na -> { arity = NA; call_info = Call_ml }

let rec apply_with_arity_aux (fn : J.expression) (arity : int list)
    (args : E.t list) (len : int) : E.t =
  if len = 0 then fn (* All arguments consumed so far *)
  else
    match arity with
    | x :: rest ->
        let x = if x = 0 then 1 else x in
        (* Relax when x = 0 *)
        if len >= x then
          let first_part, continue = List.split_at args x in
          apply_with_arity_aux
            (E.call ~info:{ arity = Full; call_info = Call_ml } fn first_part)
            rest continue (len - x)
        else if
          (* GPR #1423 *)
          List.for_all ~f:Js_analyzer.is_okay_to_duplicate args
        then
          let params =
            List.init ~len:(x - len) ~f:(fun _ -> Ident.create "param")
          in
          E.ocaml_fun params (* unknown info *)
            ~return_unit:false
            [
              S.return_stmt
                (E.call
                   ~info:{ arity = Full; call_info = Call_ml }
                   fn
                   (List.append args @@ List.map ~f:E.var params));
            ]
        else E.call ~info:Js_call_info.dummy fn args
    (* alpha conversion now? --
       Since we did an alpha conversion before so it is not here
    *)
    | [] ->
        (* can not happen, unless it's an exception ? *)
        E.call ~info:Js_call_info.dummy fn args

let apply_with_arity ~arity fn args =
  apply_with_arity_aux fn arity args (List.length args)

let method_cache_id = ref 1 (*TODO: move to js runtime for re-entrant *)

let change_tail_type_in_try (x : Lam_compile_context.tail_type) :
    Lam_compile_context.tail_type =
  match x with
  | Maybe_tail_is_return (Tail_with_name _) -> Maybe_tail_is_return Tail_in_try
  | Not_tail | Maybe_tail_is_return Tail_in_try -> x

let in_staticcatch (x : Lam_compile_context.tail_type) :
    Lam_compile_context.tail_type =
  match x with
  | Maybe_tail_is_return (Tail_with_name ({ in_staticcatch = false; _ } as x))
    ->
      Maybe_tail_is_return (Tail_with_name { x with in_staticcatch = true })
  | _ -> x

(* let change_tail_type_in_static
   (x : Lam_compile_context.tail_type)
   : Lam_compile_context.tail_type =
   match x with
   | Maybe_tail_is_return (Tail_with_name ({in_staticcatch=false} as z) ) ->
     Maybe_tail_is_return (Tail_with_name {z with in_staticcatch=true})
   | Maybe_tail_is_return (Tail_with_name {in_staticcatch=true} )
   | Not_tail | Maybe_tail_is_return Tail_in_try
     -> x *)

(* assume outer is [Lstaticcatch] *)
let rec flat_catches (acc : Lam_compile_context.handler list) (x : Lam.t) :
    Lam_compile_context.handler list * Lam.t =
  match x with
  | Lstaticcatch (l, (label, bindings), handler)
    when acc = []
         || not
              (Lam_exit_code.has_exit_code handler (fun exit ->
                   List.exists
                     ~f:(fun (x : Lam_compile_context.handler) ->
                       x.label = exit)
                     acc)) ->
      (* #1698 should not crush exit code here without checking *)
      flat_catches ({ label; handler; bindings } :: acc) l
  | _ -> (acc, x)

let flatten_nested_caches (x : Lam.t) : Lam_compile_context.handler list * Lam.t
    =
  flat_catches [] x

let morph_declare_to_assign (cxt : Lam_compile_context.t) k =
  match cxt.continuation with
  | Declare (kind, did) ->
      k { cxt with continuation = Assign did } (Some (kind, did))
  | _ -> k cxt None

let group_apply cases callback =
  List.concat_map
    ~f:(fun group -> List.map_last group callback)
    (List.stable_group cases (fun (_, lam) (_, lam1) -> Lam.eq_approx lam lam1))
(* TODO:
    for expression generation,
    name, should_return  is not needed,
    only jmp_table and env needed
*)

type default_case = Default of Lam.t | Complete | NonComplete

let default_action ~saturated failaction =
  match failaction with
  | None -> Complete
  | Some x -> if saturated then Complete else Default x

let get_const_name i (sw_names : Lambda.switch_names option) =
  match sw_names with None -> None | Some { consts; _ } -> Some consts.(i)

let get_block_name i (sw_names : Lambda.switch_names option) =
  match sw_names with None -> None | Some { blocks; _ } -> Some blocks.(i)

let no_effects_const = lazy true
(* let has_effects_const = lazy false *)

(* We drop the ability of cross-compiling
        the compiler has to be the same running
*)

type initialization = J.block

(* since it's only for alias, there is no arguments,
   we should not inline function definition here, even though
   it is very small
   TODO: add comment here, we should try to add comment for
   cross module inlining

   if we do too agressive inlining here:

   if we inline {!List.length} which will call {!A_list.length},
   then we if we try inline {!A_list.length}, this means if {!A_list}
   is rebuilt, this module should also be rebuilt,

   But if the build system is content-based, suppose {!A_list}
   is changed, cmj files in {!List} is unchnaged, however,
   {!List.length} call {!A_list.length} which is changed, since
   [ocamldep] only detect that we depend on {!List}, it will not
   get re-built, then we are screwed.

   This is okay for stamp based build system.

   Another solution is that we add dependencies in the compiler

   -: we should not do functor application inlining in a
      non-toplevel, it will explode code very quickly
*)
let rec compile_external_field (* Like [List.empty] *)
    (lamba_cxt : Lam_compile_context.t) (id : Ident.t) name : Js_output.t =
  match Lam_compile_env.query_external_id_info id name with
  | Some { persistent_closed_lambda = Some lam; _ }
    when Lam_util.not_function lam ->
      compile_lambda lamba_cxt lam
  | Some _ | None ->
      Js_output.output_of_expression lamba_cxt.continuation
        ~no_effects:no_effects_const (E.ml_var_dot id name)

(* TODO: how nested module call would behave,
   In the future, we should keep in track  of if
   it is fully applied from [Lapply]
   Seems that the module dependency is tricky..
   should we depend on [Pervasives] or not?

   we can not do this correctly for the return value,
   however we can inline the definition in Pervasives
   TODO:
   [Pervasives.print_endline]
   [Pervasives.prerr_endline]
   @param id external module id
   @param number the index of the external function
   @param env typing environment
   @param args arguments
*)
(* This can not happen since this id should be already consulted by type checker
          Worst case
    {[
      E.array_index_by_int m pos
    ]}
*)
(* when module is passed as an argument - unpack to an array
    for the function, generative module or functor can be a function,
    however it can not be global -- global can only module
*)

and compile_external_field_apply (appinfo : Lam.apply) (module_id : Ident.t)
    (field_name : string) (lambda_cxt : Lam_compile_context.t) : Js_output.t =
  let ident_info =
    Lam_compile_env.query_external_id_info module_id field_name
  in
  let ap_args = appinfo.ap_args in
  match ident_info with
  | Some { persistent_closed_lambda = Some (Lfunction { params; body; _ }); _ }
    when List.same_length params ap_args ->
      (* TODO: serialize it when exporting to save compile time *)
      let _, param_map =
        Lam_closure.is_closed_with_map Ident.Set.empty params body
      in
      compile_lambda lambda_cxt
        (Lam_beta_reduce.propogate_beta_reduce_with_map lambda_cxt.meta
           param_map params body ap_args)
  | Some _ | None ->
      let arity =
        ident_info
        |> Option.map (fun (t : Js_cmj_format.keyed_cmj_value) -> t.arity)
        |> Option.value ~default:Js_cmj_format.single_na
      in
      let args_code, args =
        let dummy = ([], []) in
        if ap_args = [] then dummy
        else
          let arg_cxt = { lambda_cxt with continuation = NeedValue Not_tail } in
          List.fold_right
            ~f:(fun arg_lambda (args_code, args) ->
              match compile_lambda arg_cxt arg_lambda with
              | { block; value = Some b; _ } ->
                  (List.append block args_code, b :: args)
              | _ -> assert false)
            ap_args ~init:dummy
      in

      let fn = E.ml_var_dot module_id field_name in
      let expression =
        match appinfo.ap_info.ap_status with
        | (App_infer_full | App_uncurry) as ap_status ->
            E.call ~info:(call_info_of_ap_status ap_status) fn args
        | App_na -> (
            match arity with
            | Submodule _ | Single Arity_na ->
                E.call ~info:Js_call_info.dummy fn args
            | Single x ->
                apply_with_arity fn ~arity:(Lam_arity.extract_arity x) args)
      in
      Js_output.output_of_block_and_expression lambda_cxt.continuation args_code
        expression

(*
    The second return values are values which need to be wrapped using
   [update_dummy]

   Invariant:  jmp_table can not across function boundary,
       here we share env

*)
and compile_recursive_let ~all_bindings (cxt : Lam_compile_context.t)
    (id : Ident.t) (arg : Lam.t) : Js_output.t * initialization =
  match arg with
  | Lfunction { params; body; attr = { return_unit; _ }; _ } ->
      let continue_label = Lam_util.generate_label ~name:(Ident.name id) () in
      (* TODO: Think about recursive value
         {[
           let rec v = ref (fun _ ...
                           )
         ]}
          [Alias] may not be exact
      *)
      let ret : Lam_compile_context.return_label =
        {
          id;
          label = continue_label;
          params;
          immutable_mask = Array.make (List.length params) true;
          new_params = Ident.Map.empty;
          triggered = false;
        }
      in
      let output =
        compile_lambda
          {
            cxt with
            continuation =
              EffectCall
                (Maybe_tail_is_return
                   (Tail_with_name { label = Some ret; in_staticcatch = false }));
            jmp_table = Lam_compile_context.empty_handler_map;
          }
          body
      in
      let result =
        if ret.triggered then
          let body_block = Js_output.output_as_block output in
          E.ocaml_fun
          (* TODO:  save computation of length several times
             Here we always create [ocaml_fun],
             it will be renamed into [method]
             when it is detected by a primitive
          *)
            ~return_unit ~immutable_mask:ret.immutable_mask
            (List.map
               ~f:(fun x -> Ident.Map.find_default ret.new_params x x)
               params)
            [
              S.while_ (* ~label:continue_label *)
                E.true_
                (Ident.Map.fold ret.new_params body_block
                   (fun old new_param acc ->
                     S.define_variable ~kind:Alias old (E.var new_param) :: acc));
            ]
        else
          (* TODO:  save computation of length several times *)
          E.ocaml_fun params ~return_unit (Js_output.output_as_block output)
      in
      ( Js_output.output_of_expression
          (Declare (Alias, id))
          result
          ~no_effects:(lazy (Lam_analysis.no_side_effects arg)),
        [] )
  | Lprim { primitive = Pmakeblock (_, _, _); args; _ }
    when args_either_function_or_const args ->
      (compile_lambda { cxt with continuation = Declare (Alias, id) } arg, [])
      (* case of lazy blocks, treat it as usual *)
  | Lprim
      {
        primitive =
          Pmakeblock
            ( _,
              (( Blk_record _
               | Blk_constructor { num_nonconst = 1; _ }
               | Blk_record_inlined { num_nonconst = 1; _ } ) as tag_info),
              _ );
        args = ls;
        _;
      }
    when List.for_all
           ~f:(fun (x : Lam.t) ->
             match x with
             | Lvar pid ->
                 Ident.same pid id
                 || not
                    @@ List.exists
                         ~f:(fun (other, _) -> Ident.same other pid)
                         all_bindings
             | Lconst _ -> true
             | _ -> false)
           ls ->
      (* capture cases like for {!Queue}
         {[let rec cell = { content = x; next = cell} ]}
         #1716: be careful not to optimize such cases:
         {[ let rec a = { b} and b = { a} ]} they are indeed captured
         and need to be declared first
         TODO: this should be inlined based on tag info
      *)
      ( Js_output.make
          (S.define_variable ~kind:Variable id (E.dummy_obj tag_info)
          :: List.mapi
               ~f:(fun i (x : Lam.t) ->
                 S.exp
                   (Js_of_lam_block.set_field
                      (match tag_info with
                      | Blk_record xs -> Fld_record_set xs.(i)
                      | Blk_record_inlined xs ->
                          Fld_record_inline_set xs.fields.(i)
                      | Blk_constructor p ->
                          Fld_record_inline_set
                            (Js_exp_make.variant_pos ~constr:p.name
                               (Int32.of_int i))
                      | _ -> assert false)
                      (E.var id) (Int32.of_int i)
                      (match x with
                      | Lvar lid -> E.var lid
                      | Lconst x -> Lam_compile_const.translate x
                      | _ -> assert false)))
               ls),
        [] )
  | Lprim { primitive = Pmakeblock (_, tag_info, _); _ } -> (
      (* Lconst should not appear here if we do [scc]
         optimization, since it's faked recursive value,
         however it would affect scope issues, we have to declare it first
      *)
      match
        compile_lambda { cxt with continuation = NeedValue Not_tail } arg
      with
      | { block = b; value = Some v; _ } ->
          (* TODO: check recursive value ..
              could be improved for simple cases
          *)
          ( Js_output.make
              (List.append b
                 [
                   S.exp
                     (E.runtime_call Js_runtime_modules.obj_runtime
                        "update_dummy"
                        [ E.var id; v ]);
                 ]),
            [ S.define_variable ~kind:Variable id (E.dummy_obj tag_info) ] )
      | _ -> assert false)
  | _ ->
      (* pathological case:
          fail to capture taill call?
         {[ let rec a =
              if  g > 30 then .. fun () -> a ()
         ]}

          Neither  below is not allowed in ocaml:
         {[
           let rec v =
             if sum 0 10 > 20 then
               1::v
             else 2:: v
         ]}
         {[
           let rec v =
             if sum 0 10 > 20 then
               fun _ -> print_endline "hi"; v ()
             else
               fun _-> print_endline "hey"; v ()
         ]}
      *)
      (compile_lambda { cxt with continuation = Declare (Alias, id) } arg, [])

and compile_recursive_lets_aux cxt (id_args : Lam_scc.bindings) : Js_output.t =
  (* #1716 *)
  let output_code, ids =
    List.fold_right
      ~f:(fun (ident, arg) (acc, ids) ->
        let code, declare_ids =
          compile_recursive_let ~all_bindings:id_args cxt ident arg
        in
        (Js_output.append_output code acc, List.append declare_ids ids))
      id_args ~init:(Js_output.dummy, [])
  in
  match ids with
  | [] -> output_code
  | _ -> Js_output.append_output (Js_output.make ids) output_code

and compile_recursive_lets cxt id_args : Js_output.t =
  match id_args with
  | [] -> Js_output.dummy
  | _ -> (
      let id_args_group = Lam_scc.scc_bindings id_args in
      match id_args_group with
      | [] -> assert false
      | first :: rest ->
          let acc = compile_recursive_lets_aux cxt first in
          List.fold_left
            ~f:(fun acc x ->
              Js_output.append_output acc (compile_recursive_lets_aux cxt x))
            ~init:acc rest)

and compile_general_cases :
      'a.
      ('a -> string option) ->
      ('a -> J.expression) ->
      (J.expression -> J.expression -> J.expression) ->
      Lam_compile_context.t ->
      (?default:J.block ->
      ?declaration:Lam_group.let_kind * Ident.t ->
      _ ->
      ('a * J.case_clause) list ->
      J.statement) ->
      _ ->
      ('a * Lam.t) list ->
      default_case ->
      J.block =
 fun (make_comment : _ -> string option) (make_exp : _ -> J.expression)
     (eq_exp : J.expression -> J.expression -> J.expression)
     (cxt : Lam_compile_context.t)
     (switch :
       ?default:J.block ->
       ?declaration:Lam_group.let_kind * Ident.t ->
       _ ->
       (_ * J.case_clause) list ->
       J.statement) (switch_exp : J.expression) (cases : (_ * Lam.t) list)
     (default : default_case) ->
  match (cases, default) with
  | [], Default lam -> Js_output.output_as_block (compile_lambda cxt lam)
  | [], (Complete | NonComplete) -> []
  | [ (_, lam) ], Complete ->
      (* To take advantage of such optimizations,
          when we generate code using switch,
          we should always have a default,
          otherwise the compiler engine would think that
          it's also complete
      *)
      Js_output.output_as_block (compile_lambda cxt lam)
  | [ (id, lam) ], NonComplete ->
      morph_declare_to_assign cxt (fun cxt define ->
          [
            S.if_ ?declaration:define
              (eq_exp switch_exp (make_exp id))
              (Js_output.output_as_block (compile_lambda cxt lam));
          ])
  | [ (id, lam) ], Default x | [ (id, lam); (_, x) ], Complete ->
      morph_declare_to_assign cxt (fun cxt define ->
          let else_block = Js_output.output_as_block (compile_lambda cxt x) in
          let then_block = Js_output.output_as_block (compile_lambda cxt lam) in
          [
            S.if_ ?declaration:define
              (eq_exp switch_exp (make_exp id))
              then_block ~else_:else_block;
          ])
  | _, _ ->
      (* TODO: this is not relevant to switch case
           however, in a subset of switch-case if we can analysis
           its branch are the same, we can propogate which
           might encourage better inlining strategey
           ---
           TODO: grouping can be delayed untile JS IR

           see #2413
           In general, we know it is last call,
           there is no need to print [break];
           But we need make sure the last call lambda does not
           have `(exit ..)` due to we pass should_return from Lstaticcath downwards
           Since this is a rough approximation, some `(exit ..)` does not destroy
           last call property, we use exiting should_break to improve preciseness
           (and it indeed help catch
           - tailcall or not does not matter, if it is the tailcall
             break still should not be printed (it will be continuned)
         TOOD: disabled temporarily since it's not perfect yet *)
      morph_declare_to_assign cxt (fun cxt declaration ->
          let default =
            match default with
            | Complete -> None
            | NonComplete -> None
            | Default lam ->
                Some (Js_output.output_as_block (compile_lambda cxt lam))
          in
          let body =
            group_apply cases (fun last (switch_case, lam) ->
                if last then
                  (* merge and shared *)
                  let switch_body, should_break =
                    Js_output.to_break_block (compile_lambda cxt lam)
                  in
                  let should_break =
                    if
                      not
                      @@ Lam_compile_context.continuation_is_return
                           cxt.continuation
                    then should_break
                    else should_break && Lam_exit_code.has_exit lam
                  in
                  ( switch_case,
                    J.
                      {
                        switch_body;
                        should_break;
                        comment = make_comment switch_case;
                      } )
                else
                  ( switch_case,
                    {
                      switch_body = [];
                      should_break = false;
                      comment = make_comment switch_case;
                    } ))
            (* TODO: we should also group default *)
            (* The last clause does not need [break]
                common break through, *)
          in

          [ switch ?default ?declaration switch_exp body ])

and compile_cases cxt (switch_exp : E.t) table default get_name =
  compile_general_cases get_name
    (fun i -> { (E.small_int i) with comment = get_name i })
    E.int_equal cxt
    (fun ?default ?declaration e clauses ->
      S.int_switch ?default ?declaration e clauses)
    switch_exp table default

and compile_switch (switch_arg : Lam.t) (sw : Lam.lambda_switch)
    (lambda_cxt : Lam_compile_context.t) =
  (* TODO: if default is None, we can do some optimizations
      Use switch vs if/then/else

      TODO: switch based optimiztion - hash, group, or using array,
            also if last statement is throw -- should we drop remaining
            statement?
  *)
  let ({
         sw_consts_full;
         sw_consts;
         sw_blocks_full;
         sw_blocks;
         sw_failaction;
         sw_names;
       }
        : Lam.lambda_switch) =
    sw
  in
  let sw_num_default = default_action ~saturated:sw_consts_full sw_failaction in
  let sw_blocks_default =
    default_action ~saturated:sw_blocks_full sw_failaction
  in
  let get_const_name i = get_const_name i sw_names in
  let get_block_name i = get_block_name i sw_names in
  let compile_whole (cxt : Lam_compile_context.t) =
    match
      compile_lambda { cxt with continuation = NeedValue Not_tail } switch_arg
    with
    | { value = None; _ } -> assert false
    | { block; value = Some e; _ } -> (
        block
        @
        if sw_consts_full && sw_consts = [] then
          compile_cases cxt (E.tag e) sw_blocks sw_blocks_default get_block_name
        else if sw_blocks_full && sw_blocks = [] then
          compile_cases cxt e sw_consts sw_num_default get_const_name
        else
          (* [e] will be used twice  *)
          let dispatch e =
            S.if_ (E.is_type_number e)
              (compile_cases cxt e sw_consts sw_num_default get_const_name)
              (* default still needed, could simplified*)
              ~else_:
                (compile_cases cxt (E.tag e) sw_blocks sw_blocks_default
                   get_block_name)
          in
          match e.expression_desc with
          | J.Var _ -> [ dispatch e ]
          | _ ->
              let v = Ident.create_tmp () in
              (* Necessary avoid duplicated computation*)
              [ S.define_variable ~kind:Variable v e; dispatch (E.var v) ])
  in
  match lambda_cxt.continuation with
  (* Needs declare first *)
  | NeedValue _ ->
      (* Necessary since switch is a statement, we need they return
         the same value for different branches -- can be optmized
         when branches are minimial (less than 2)
      *)
      let v = Ident.create_tmp () in
      Js_output.make
        (S.declare_variable ~kind:Variable v
        :: compile_whole { lambda_cxt with continuation = Assign v })
        ~value:(E.var v)
  | Declare (kind, id) ->
      Js_output.make
        (S.declare_variable ~kind id
        :: compile_whole { lambda_cxt with continuation = Assign id })
  | EffectCall _ | Assign _ -> Js_output.make (compile_whole lambda_cxt)

and compile_string_cases cxt switch_exp table default =
  compile_general_cases
    (fun _ -> None)
    E.str E.string_equal cxt
    (fun ?default ?declaration e clauses ->
      S.string_switch ?default ?declaration e clauses)
    switch_exp table default
(* TODO: optional arguments are not good
    for high order currying *)

and compile_stringswitch l cases default (lambda_cxt : Lam_compile_context.t) =
  (* TODO might better optimization according to the number of cases
      Be careful: we should avoid multiple evaluation of l,
      The [gen] can be elimiated when number of [cases] is less than 3
  *)
  match
    compile_lambda { lambda_cxt with continuation = NeedValue Not_tail } l
  with
  | { value = None; _ } -> assert false
  | { block; value = Some e; _ } -> (
      (* when should_return is true -- it's passed down
         otherwise it's ok *)
      let default =
        match default with Some x -> Default x | None -> Complete
      in
      match lambda_cxt.continuation with
      (* TODO: can be avoided when cases are less than 3 *)
      | NeedValue _ ->
          let v = Ident.create_tmp () in
          Js_output.make
            (List.append block
               (compile_string_cases
                  { lambda_cxt with continuation = Declare (Variable, v) }
                  e cases default))
            ~value:(E.var v)
      | _ ->
          Js_output.make
            (List.append block
               (compile_string_cases lambda_cxt e cases default)))
(*
         This should be optimized in lambda layer
         (let (match/1038 = (apply g/1027 x/1028))
         (catch
         (stringswitch match/1038
         case "aabb": 0
         case "bbc": 1
         default: (exit 1))
         with (1) 2))
      *)

and compile_staticraise i (largs : Lam.t list)
    (lambda_cxt : Lam_compile_context.t) =
  (* [i] is the jump table, [largs] is the arguments passed to [Lstaticcatch]*)
  match Lam_compile_context.find_exn lambda_cxt i with
  | { exit_id; bindings; order_id } ->
      List.fold_right2
        ~f:(fun (larg : Lam.t) bind acc ->
          let new_output =
            match larg with
            | Lvar id -> Js_output.make [ S.assign bind (E.var id) ]
            | _ ->
                (* TODO: should be Assign -- Assign is an optimization *)
                compile_lambda
                  { lambda_cxt with continuation = Assign bind }
                  larg
          in
          Js_output.append_output new_output acc)
        largs bindings
        ~init:
          (Js_output.make
             (if order_id >= 0 then [ S.assign exit_id (E.small_int order_id) ]
              else []))
(* Invariant: exit_code can not be reused
    (catch l with (32)
    (handler))
    32 should not be used in another catch
    Invariant:
    This is true in current ocaml compiler
    currently exit only appears in should_return position relative to staticcatch
    if not we should use ``javascript break`` or ``continue``
   if exit_code_id == code
     handler -- ids are not useful, since
     when compiling `largs` we will do the binding there
     - when exit_code is undefined internally,
       it should PRESERVE  ``tail`` property
     - if it uses `staticraise` only once
       or handler is minimal, we can inline
     - always inline also seems to be ok, but it might bloat the code
     - another common scenario is that we have nested catch
       (catch (catch (catch ..))
    checkout example {!Digest.file}, you can not inline handler there,
    we can spot such patten and use finally there?
     {[
       let file filename =
         let ic = open_in_bin filename in
         match channel ic (-1) with
         | d -> close_in ic; d
         | exception e -> close_in ic; raise e

     ]}
*)

and compile_staticcatch (lam : Lam.t) (lambda_cxt : Lam_compile_context.t) =
  let code_table, body = flatten_nested_caches lam in
  let exit_id = Ident.create_tmp ~name:"exit" () in
  match (lambda_cxt.continuation, code_table) with
  | ( EffectCall
        (Maybe_tail_is_return (Tail_with_name { in_staticcatch = false; _ }) as
         tail_type),
      [ code_table ] )
  (* tail position and only one exit code *)
    when Lam_compile_context.no_static_raise_in_handler code_table ->
      let jmp_table, handler =
        Lam_compile_context.add_pseudo_jmp lambda_cxt.jmp_table exit_id
          code_table
      in
      let new_cxt =
        {
          lambda_cxt with
          jmp_table;
          continuation = EffectCall (in_staticcatch tail_type);
        }
      in

      let lbody = compile_lambda new_cxt body in
      let declares =
        List.map
          ~f:(fun x -> S.declare_variable ~kind:Variable x)
          code_table.bindings
      in
      Js_output.append_output (Js_output.make declares)
        (Js_output.append_output lbody (compile_lambda lambda_cxt handler))
  | _ -> (
      let exit_expr = E.var exit_id in
      let jmp_table, handlers =
        Lam_compile_context.add_jmps lambda_cxt.jmp_table exit_id code_table
      in

      (* Declaration First, body and handler have the same value *)
      let declares =
        S.define_variable ~kind:Variable exit_id E.zero_int_literal
        :: (* we should always make it zero here, since [zero] is reserved in our mapping*)
           List.concat_map
             ~f:(fun { Lam_compile_context.bindings; _ } ->
               List.map ~f:(S.declare_variable ~kind:Variable) bindings)
             code_table
      in
      match lambda_cxt.continuation with
      (* could be optimized when cases are less than 3 *)
      | NeedValue _ ->
          let v = Ident.create_tmp () in
          let new_cxt =
            { lambda_cxt with jmp_table; continuation = Assign v }
          in
          let lbody = compile_lambda new_cxt body in
          Js_output.append_output
            (Js_output.make (S.declare_variable ~kind:Variable v :: declares))
            (Js_output.append_output lbody
               (Js_output.make
                  (compile_cases new_cxt exit_expr handlers NonComplete
                     (fun _ -> None))
                  ~value:(E.var v)))
      | Declare (kind, id) (* declare first this we will do branching*) ->
          let declares = S.declare_variable ~kind id :: declares in
          let new_cxt =
            { lambda_cxt with jmp_table; continuation = Assign id }
          in
          let lbody = compile_lambda new_cxt body in
          Js_output.append_output (Js_output.make declares)
            (Js_output.append_output lbody
               (Js_output.make
                  (compile_cases new_cxt exit_expr handlers NonComplete
                     (fun _ -> None))))
          (* place holder -- tell the compiler that
             we don't know if it's complete
          *)
      | EffectCall tail_type as cont ->
          let continuation =
            let new_tail_type = in_staticcatch tail_type in
            if new_tail_type == tail_type then cont
            else EffectCall new_tail_type
          in
          let new_cxt = { lambda_cxt with jmp_table; continuation } in
          let lbody = compile_lambda new_cxt body in
          Js_output.append_output (Js_output.make declares)
            (Js_output.append_output lbody
               (Js_output.make
                  (compile_cases new_cxt exit_expr handlers NonComplete
                     (fun _ -> None))))
      | Assign _ ->
          let new_cxt = { lambda_cxt with jmp_table } in
          let lbody = compile_lambda new_cxt body in
          Js_output.append_output (Js_output.make declares)
            (Js_output.append_output lbody
               (Js_output.make
                  (compile_cases new_cxt exit_expr handlers NonComplete
                     (fun _ -> None)))))

and compile_sequand (l : Lam.t) (r : Lam.t) (lambda_cxt : Lam_compile_context.t)
    =
  if Lam_compile_context.continuation_is_return lambda_cxt.continuation then
    compile_lambda lambda_cxt (Lam.sequand l r)
  else
    let new_cxt = { lambda_cxt with continuation = NeedValue Not_tail } in
    match compile_lambda new_cxt l with
    | { value = None; _ } -> assert false
    | { block = l_block; value = Some l_expr; _ } -> (
        match compile_lambda new_cxt r with
        | { value = None; _ } -> assert false
        | { block = []; value = Some r_expr; _ } ->
            Js_output.output_of_block_and_expression lambda_cxt.continuation
              l_block (E.and_ l_expr r_expr)
        | { block = r_block; value = Some r_expr; _ } -> (
            match lambda_cxt.continuation with
            | Assign v ->
                (* Refernece Js_output.output_of_block_and_expression *)
                Js_output.make
                  (l_block
                  @ [
                      S.if_ l_expr
                        (r_block @ [ S.assign v r_expr ])
                        ~else_:[ S.assign v E.false_ ];
                    ])
            | Declare (_kind, v) ->
                (* Refernece Js_output.output_of_block_and_expression *)
                Js_output.make
                  (l_block
                  @ [
                      S.define_variable ~kind:Variable v E.false_;
                      S.if_ l_expr (r_block @ [ S.assign v r_expr ]);
                    ])
            | EffectCall _ | NeedValue _ ->
                let v = Ident.create_tmp () in
                Js_output.make
                  ((S.define_variable ~kind:Variable v E.false_ :: l_block)
                  @ [ S.if_ l_expr (r_block @ [ S.assign v r_expr ]) ])
                  ~value:(E.var v)))

and compile_sequor (l : Lam.t) (r : Lam.t) (lambda_cxt : Lam_compile_context.t)
    =
  if Lam_compile_context.continuation_is_return lambda_cxt.continuation then
    compile_lambda lambda_cxt (Lam.sequor l r)
  else
    let new_cxt = { lambda_cxt with continuation = NeedValue Not_tail } in
    match compile_lambda new_cxt l with
    | { value = None; _ } -> assert false
    | { block = l_block; value = Some l_expr; _ } -> (
        match compile_lambda new_cxt r with
        | { value = None; _ } -> assert false
        | { block = []; value = Some r_expr; _ } ->
            let exp = E.or_ l_expr r_expr in
            Js_output.output_of_block_and_expression lambda_cxt.continuation
              l_block exp
        | { block = r_block; value = Some r_expr; _ } -> (
            match lambda_cxt.continuation with
            | Assign v ->
                (* Reference Js_output.output_of_block_and_expression *)
                Js_output.make
                  (l_block
                  @ [
                      S.if_ (E.not l_expr)
                        (r_block @ [ S.assign v r_expr ])
                        ~else_:[ S.assign v E.true_ ];
                    ])
            | Declare (_kind, v) ->
                Js_output.make
                  (l_block
                  @ [
                      S.define_variable ~kind:Variable v E.true_;
                      S.if_ (E.not l_expr) (r_block @ [ S.assign v r_expr ]);
                    ])
            | EffectCall _ | NeedValue _ ->
                let v = Ident.create_tmp () in
                Js_output.make
                  (l_block
                  @ [
                      S.define_variable ~kind:Variable v E.true_;
                      S.if_ (E.not l_expr) (r_block @ [ S.assign v r_expr ]);
                    ])
                  ~value:(E.var v)))

(* Note that ``J.While(expression * statement )``
            idealy if ocaml expression does not need fresh variables, we can generate
            while expression, here we generate for statement, leave optimization later.
            (Sine OCaml expression can be really complex..)
*)
and compile_while (predicate : Lam.t) (body : Lam.t)
    (lambda_cxt : Lam_compile_context.t) =
  match
    compile_lambda
      { lambda_cxt with continuation = NeedValue Not_tail }
      predicate
  with
  | { value = None; _ } -> assert false
  | { block; value = Some e; _ } ->
      (* st = NeedValue -- this should be optimized and never happen *)
      let e = match block with [] -> e | _ -> E.of_block block ~e in
      let block =
        [
          S.while_ e
            (Js_output.output_as_block
            @@ compile_lambda
                 { lambda_cxt with continuation = EffectCall Not_tail }
                 body);
        ]
      in
      Js_output.output_of_block_and_expression lambda_cxt.continuation block
        E.unit

(* all non-tail
   TODO: check semantics should start, finish be executed each time in both
     ocaml and js?, also check evaluation order..
     in ocaml id is not in the scope of finish, so it should be safe here

     for i  = 0 to (print_int 3; 10) do print_int i done;;
     3012345678910- : unit = ()

   for(var i =  0 ; i < (console.log(i),10); ++i){console.log('hi')}
   print i each time, so they are different semantics...
*)

and compile_for (id : J.for_ident) (start : Lam.t) (finish : Lam.t)
    (direction : Js_op.direction_flag) (body : Lam.t)
    (lambda_cxt : Lam_compile_context.t) =
  let new_cxt = { lambda_cxt with continuation = NeedValue Not_tail } in
  let block =
    match (compile_lambda new_cxt start, compile_lambda new_cxt finish) with
    | { value = None; _ }, _ | _, { value = None; _ } -> assert false
    | { block = b1; value = Some e1; _ }, { block = b2; value = Some e2; _ }
      -> (
        (* order b1 -- (e1 -- b2 -- e2)
            in most cases we can shift it into such scenarios
            b1, b2, [e1, e2]
            - b2 is Empty
            - e1 is pure
            we can guarantee e1 is pure, if it literally contains a side effect call,
            put it in the beginning
        *)
        let block_body =
          Js_output.output_as_block
            (compile_lambda
               { lambda_cxt with continuation = EffectCall Not_tail }
               body)
        in
        match (b1, b2) with
        | _, [] -> b1 @ [ S.for_ (Some e1) e2 id direction block_body ]
        | _, _
          when Js_analyzer.no_side_effect_expression e1
               (*
                     e1 > b2 > e2
                     re-order
                     b2 > e1 > e2
                   *)
          ->
            List.append b1 (b2 @ [ S.for_ (Some e1) e2 id direction block_body ])
        | _, _ ->
            List.append b1
              (S.define_variable ~kind:Variable id e1
              :: (b2 @ [ S.for_ None e2 id direction block_body ])))
  in
  Js_output.output_of_block_and_expression lambda_cxt.continuation block E.unit

and compile_assign id (lambda : Lam.t) (lambda_cxt : Lam_compile_context.t) =
  let block =
    match lambda with
    | Lprim { primitive = Poffsetint v; args = [ Lvar bid ]; _ }
      when Ident.same id bid ->
        [ S.exp (E.assign (E.var id) (E.int32_add (E.var id) (E.small_int v))) ]
    | _ -> (
        match
          compile_lambda
            { lambda_cxt with continuation = NeedValue Not_tail }
            lambda
        with
        | { value = None; _ } -> assert false
        | { block; value = Some v; _ } -> block @ [ S.assign id v ])
  in
  Js_output.output_of_block_and_expression lambda_cxt.continuation block E.unit

(*
         tail --> should be renamed to `shouldReturn`
          in most cases ``shouldReturn`` == ``tail``, however, here is not,
          should return, but it is not a tail call in js
          (* could be optimized using javascript style exceptions *)
   {[
     {try
        {var $js=g(x);}
          catch(exn){if(exn=Not_found){var $js=0;}else{throw exn;}}
     return h($js);
   }
   ]}
*)
and compile_trywith lam id catch (lambda_cxt : Lam_compile_context.t) =
  let aux (with_context : Lam_compile_context.t)
      (body_context : Lam_compile_context.t) =
    (* should_return is passed down
       #1701, try should prevent tailcall *)
    [
      S.try_
        (Js_output.output_as_block (compile_lambda body_context lam))
        ~with_:
          (id, Js_output.output_as_block (compile_lambda with_context catch));
    ]
  in
  match lambda_cxt.continuation with
  | Declare (kind, id) ->
      let context = { lambda_cxt with continuation = Assign id } in
      Js_output.make (S.declare_variable ~kind id :: aux context context)
  | Assign _ -> Js_output.make (aux lambda_cxt lambda_cxt)
  | NeedValue _ ->
      let v = Ident.create_tmp () in
      let context = { lambda_cxt with continuation = Assign v } in
      Js_output.make
        (S.declare_variable ~kind:Variable v :: aux context context)
        ~value:(E.var v)
  | EffectCall return_type ->
      let new_return_type = change_tail_type_in_try return_type in
      if new_return_type == return_type then
        Js_output.make (aux lambda_cxt lambda_cxt)
      else
        Js_output.make
          (aux lambda_cxt
             { lambda_cxt with continuation = EffectCall new_return_type })

(* Note that in [Texp_apply] for [%sendcache] the cache might not be used
   see {!CamlinternalOO.send_meth} and {!Translcore.transl_exp0} the branch
   [Texp_apply] when [public_send ], args are simply dropped

   reference
   [js_of_ocaml]
   1. GETPUBMET
   2. GETDYNMET
   3. GETMETHOD
   [ocaml]
   Lsend (bytegen.ml)
   For the object layout refer to [camlinternalOO/create_object]
   {[
     let create_object table =
       (* XXX Appel de [obj_block] *)
       let obj = mark_ocaml_object @@ Obj.new_block Obj.object_tag table.size in
       (* XXX Appel de [caml_modify] *)
       Obj.set_field obj 0 (Obj.repr table.methods);
       Obj.obj (set_id obj)

     let create_object_opt obj_0 table =
       if (Obj.magic obj_0 : bool) then obj_0 else begin
         (* XXX Appel de [obj_block] *)
         let obj = mark_ocaml_object @@ Obj.new_block Obj.object_tag table.size in
         (* XXX Appel de [caml_modify] *)
         Obj.set_field obj 0 (Obj.repr table.methods);
         Obj.obj (set_id obj)
       end
   ]}
   it's a block with tag [248], the first field is [table.methods] which is an array
   {[
     type table =
       { mutable size: int;
         mutable methods: closure array;
         mutable methods_by_name: meths;
         mutable methods_by_label: labs;
         mutable previous_states:
           (meths * labs * (label * item) list * vars *
            label list * string list) list;
         mutable hidden_meths: (label * item) list;
         mutable vars: vars;
         mutable initializers: (obj -> unit) list }
   ]}
*)
and compile_send (meth_kind : Lam_compat.meth_kind) (met : Lam.t) (obj : Lam.t)
    (args : Lam.t list) (lambda_cxt : Lam_compile_context.t) =
  let new_cxt = { lambda_cxt with continuation = NeedValue Not_tail } in
  match
    List.split_map (met :: obj :: args) (fun x ->
        match x with
        | Lprim { primitive = Pccall { prim_name; _ }; args = []; _ }
        (* nullary external call*) ->
            ([], E.var (Ident.create_js prim_name))
        | _ -> (
            match compile_lambda new_cxt x with
            | { value = None; _ } -> assert false
            | { block; value = Some b; _ } -> (block, b)))
  with
  | _, ([] | [ _ ]) -> assert false
  | args_code, label :: nobj :: args -> (
      let cont3 nobj k =
        match Js_ast_util.named_expression nobj with
        | None ->
            let cont =
              Js_output.output_of_block_and_expression lambda_cxt.continuation
                (List.concat args_code)
            in
            cont (k nobj)
        | Some (obj_code, v) ->
            let cont2 obj_code v =
              Js_output.output_of_block_and_expression lambda_cxt.continuation
                (List.concat args_code @ [ obj_code ])
                v
            in
            let cobj = E.var v in
            cont2 obj_code (k cobj)
      in
      match meth_kind with
      | Self ->
          (* TODO: horrible hack -- fixed later -- CHECK*)
          cont3 nobj (fun aobj ->
              E.call ~info:Js_call_info.dummy
                (Js_of_lam_array.ref_array (E.array_index_by_int aobj 0l) label)
                (aobj :: args))
          (* [E.small_int 1] is because we use array,
              when we change the runtime represenation, it needs to be adapted
          *)
      | Cached
      | Public None
      (* TODO: check -- 1. js object propagate 2. js object create  *) ->
          let get =
            E.runtime_ref Js_runtime_modules.oo "caml_get_public_method"
          in
          let cache = !method_cache_id in
          let () = incr method_cache_id in
          cont3 nobj (fun obj' ->
              E.call ~info:Js_call_info.dummy
                (E.call ~info:Js_call_info.dummy get
                   [ obj'; label; E.small_int cache ])
                (obj' :: args))
          (* avoid duplicated compuattion *)
      | Public (Some name) ->
          let cache = !method_cache_id in
          incr method_cache_id;
          cont3 nobj (fun aobj ->
              E.public_method_call name aobj label (Int32.of_int cache) args))

and compile_ifthenelse (predicate : Lam.t) (t_branch : Lam.t) (f_branch : Lam.t)
    (lambda_cxt : Lam_compile_context.t) =
  match
    compile_lambda
      { lambda_cxt with continuation = NeedValue Not_tail }
      predicate
  with
  | { value = None; _ } -> assert false
  | { block = b; value = Some e; _ } -> (
      match lambda_cxt.continuation with
      | NeedValue _ -> (
          match
            ( compile_lambda lambda_cxt t_branch,
              compile_lambda lambda_cxt f_branch )
          with
          | ( { block = []; value = Some out1; _ },
              { block = []; value = Some out2; _ } ) ->
              (* speical optimization *)
              Js_output.make b ~value:(E.econd e out1 out2)
          | _, _ -> (
              (* we can not reuse -- here we need they have the same name,
                     TODO: could be optimized by inspecting assigment statement *)
              let id = Ident.create_tmp () in
              let assign_cxt = { lambda_cxt with continuation = Assign id } in
              match
                ( compile_lambda assign_cxt t_branch,
                  compile_lambda assign_cxt f_branch )
              with
              | out1, out2 ->
                  Js_output.make
                    (List.append
                       (S.declare_variable ~kind:Variable id :: b)
                       [
                         S.if_ e
                           (Js_output.output_as_block out1)
                           ~else_:(Js_output.output_as_block out2);
                       ])
                    ~value:(E.var id)))
      | Declare (kind, id) -> (
          let declare_cxt =
            { lambda_cxt with continuation = NeedValue Not_tail }
          in
          match
            ( compile_lambda declare_cxt t_branch,
              compile_lambda declare_cxt f_branch )
          with
          | ( { block = []; value = Some out1; _ },
              { block = []; value = Some out2; _ } ) ->
              (* Invariant: should_return is false*)
              Js_output.make
                (b @ [ S.define_variable ~kind id (E.econd e out1 out2) ])
          | _, _ ->
              Js_output.make
                (b
                @ [
                    S.if_ ~declaration:(kind, id) e
                      (Js_output.output_as_block
                      @@ compile_lambda
                           { lambda_cxt with continuation = Assign id }
                           t_branch)
                      ~else_:
                        (Js_output.output_as_block
                        @@ compile_lambda
                             { lambda_cxt with continuation = Assign id }
                             f_branch);
                  ]))
      | Assign _ ->
          let then_output =
            Js_output.output_as_block (compile_lambda lambda_cxt t_branch)
          in
          let else_output =
            Js_output.output_as_block (compile_lambda lambda_cxt f_branch)
          in
          Js_output.make (b @ [ S.if_ e then_output ~else_:else_output ])
      | EffectCall should_return -> (
          let context1 =
            { lambda_cxt with continuation = NeedValue should_return }
          in
          match
            ( should_return,
              compile_lambda context1 t_branch,
              compile_lambda context1 f_branch )
          with
          (* see PR#83 *)
          | ( Not_tail,
              { block = []; value = Some out1; _ },
              { block = []; value = Some out2; _ } ) -> (
              match
                ( Js_exp_make.remove_pure_sub_exp out1,
                  Js_exp_make.remove_pure_sub_exp out2 )
              with
              | None, None -> Js_output.make (b @ [ S.exp e ])
              (* FIX #1762 *)
              | Some out1, Some out2 ->
                  Js_output.make b ~value:(E.econd e out1 out2)
              | Some out1, None ->
                  Js_output.make (b @ [ S.if_ e [ S.exp out1 ] ])
              | None, Some out2 ->
                  Js_output.make (b @ [ S.if_ (E.not e) [ S.exp out2 ] ]))
          | Not_tail, { block = []; value = Some out1; _ }, _ ->
              (* assert branch
                  TODO: here we re-compile two branches since
                  its context is different -- could be improved
              *)
              if Js_analyzer.no_side_effect_expression out1 then
                Js_output.make
                  (List.append b
                     [
                       S.if_ (E.not e)
                         (Js_output.output_as_block
                         @@ compile_lambda lambda_cxt f_branch);
                     ])
              else
                Js_output.make
                  (List.append b
                     [
                       S.if_ e
                         (Js_output.output_as_block
                         @@ compile_lambda lambda_cxt t_branch)
                         ~else_:
                           (Js_output.output_as_block
                           @@ compile_lambda lambda_cxt f_branch);
                     ])
          | Not_tail, _, { block = []; value = Some out2; _ } ->
              let else_ =
                if Js_analyzer.no_side_effect_expression out2 then None
                else
                  Some
                    (Js_output.output_as_block
                       (compile_lambda lambda_cxt f_branch))
              in
              Js_output.make
                (b
                @ [
                    S.if_ e
                      (Js_output.output_as_block
                         (compile_lambda lambda_cxt t_branch))
                      ?else_;
                  ])
          | ( Maybe_tail_is_return _,
              { block = []; value = Some out1; _ },
              { block = []; value = Some out2; _ } ) ->
              Js_output.make
                (b @ [ S.return_stmt (E.econd e out1 out2) ])
                ~output_finished:True
          | _, _, _ ->
              let then_output =
                Js_output.output_as_block (compile_lambda lambda_cxt t_branch)
              in
              let else_output =
                Js_output.output_as_block (compile_lambda lambda_cxt f_branch)
              in
              Js_output.make (b @ [ S.if_ e then_output ~else_:else_output ])))

and compile_apply (appinfo : Lam.apply) (lambda_cxt : Lam_compile_context.t) =
  match appinfo with
  | {
   ap_func =
     Lapply
       { ap_func; ap_args; ap_info = { ap_status = App_na; ap_inlined; _ } };
   ap_info = { ap_status = App_na; _ } as outer_ap_info;
   _;
  } ->
      (* After inlining, we can generate such code, see {!Ari_regress_test}*)
      let ap_info =
        if outer_ap_info.ap_inlined = ap_inlined then outer_ap_info
        else { outer_ap_info with ap_inlined }
      in
      compile_lambda lambda_cxt
        (Lam.apply ap_func (List.append ap_args appinfo.ap_args) ap_info)
  (* External function call: it can not be tailcall in this case*)
  | {
   ap_func =
     Lprim { primitive = Pfield (_, fld_info); args = [ Lglobal_module id ]; _ };
   _;
  } -> (
      match fld_info with
      | Fld_module { name } ->
          compile_external_field_apply appinfo id name lambda_cxt
      | _ -> assert false)
  | _ -> (
      (* TODO: ---
         1. check arity, can be simplified for pure expression
         2. no need create names
      *)
      let ap_func = appinfo.ap_func in
      let new_cxt = { lambda_cxt with continuation = NeedValue Not_tail } in
      let[@ocaml.warning "-partial-match"] args_code, fn_code :: args =
        List.fold_right
          ~f:(fun x (args_code, fn_code) ->
            match compile_lambda new_cxt x with
            | { block; value = Some b; _ } ->
                (List.append block args_code, b :: fn_code)
            | { value = None; _ } -> assert false)
          (ap_func :: appinfo.ap_args)
          ~init:([], [])
      in
      match (ap_func, lambda_cxt.continuation) with
      | ( Lvar fn_id,
          ( EffectCall
              (Maybe_tail_is_return (Tail_with_name { label = Some ret; _ }))
          | NeedValue
              (Maybe_tail_is_return (Tail_with_name { label = Some ret; _ })) )
        )
        when Ident.same ret.id fn_id ->
          ret.triggered <- true;
          (* Here we mark [finished] true, since the continuation
              does not make sense any more (due to that we have [continue])
              TODO: [finished] is not a meaningful name, we should use [truncate]
              to mean the following statement should be truncated
          *)
          (*
                actually, there is no easy way to determin
                if the argument depends on an expresion, since
                it can be a function, then it may depend on anything
                http://caml.inria.fr/pub/ml-archives/caml-list/2005/02/5727b4ecaaef6a7a350c9d98f5f68432.en.html
                http://caml.inria.fr/pub/ml-archives/caml-list/2005/02/fe9bc4e23e6dc8c932c8ab34240ff195.en.html

            *)
          (* TODO: use [fold]*)
          let _, assigned_params, new_params =
            List.fold_left2
              ~f:(fun (i, assigns, new_params) param arg ->
                match arg with
                | { J.expression_desc = Var (Id x); _ } when Ident.same x param
                  ->
                    (i + 1, assigns, new_params)
                | _ ->
                    let new_param, m =
                      match Ident.Map.find_opt ret.new_params param with
                      | None ->
                          ret.immutable_mask.(i) <- false;
                          let v = Ident.create ("_" ^ Ident.name param) in
                          (v, Ident.Map.add new_params param v)
                      | Some v -> (v, new_params)
                    in
                    (i + 1, (new_param, arg) :: assigns, m))
              ~init:(0, [], Ident.Map.empty) ret.params args
          in
          ret.new_params <-
            Ident.Map.disjoint_merge_exn new_params ret.new_params (fun _ _ _ ->
                assert false);
          let block =
            List.map ~f:(fun (param, arg) -> S.assign param arg) assigned_params
            @ [ S.continue_ ]
          in
          (* Note true and continue needed to be handled together*)
          Js_output.make ~output_finished:True (List.append args_code block)
      | _ ->
          Js_output.output_of_block_and_expression lambda_cxt.continuation
            args_code
            (E.call
               ~info:(call_info_of_ap_status appinfo.ap_info.ap_status)
               fn_code args))

and compile_prim (prim_info : Lam.prim_info)
    (lambda_cxt : Lam_compile_context.t) =
  match prim_info with
  | { primitive = Pfield (_, fld_info); args = [ Lglobal_module id ]; _ } -> (
      (* should be before Lglobal_global *)
      match fld_info with
      | Fld_module { name = field } ->
          compile_external_field lambda_cxt id field
      | _ -> assert false)
  | { primitive = Praise; args = [ e ]; _ } -> (
      match
        compile_lambda { lambda_cxt with continuation = NeedValue Not_tail } e
      with
      | { block; value = Some v; _ } ->
          Js_output.make
            (block @ [ S.throw_stmt v ])
            ~value:E.undefined ~output_finished:True
      (* FIXME -- breaks invariant when NeedValue, reason is that js [throw] is statement
         while ocaml it's an expression, we should remove such things in lambda optimizations
      *)
      | { value = None; _ } -> assert false)
  | { primitive = Psequand; args = [ l; r ]; _ } ->
      compile_sequand l r lambda_cxt
  | { primitive = Psequor; args = [ l; r ]; _ } -> compile_sequor l r lambda_cxt
  | { primitive = Pdebugger; _ } ->
      (* [%mel.debugger] guarantees that the expression does not matter
         TODO: make it even safer *)
      Js_output.output_of_block_and_expression lambda_cxt.continuation
        S.debugger_block E.unit
      (* TODO:
         check the arity of fn before wrapping it
         we need mark something that such eta-conversion can not be simplified in some cases
      *)
  | {
   primitive = Pjs_unsafe_downgrade { name = property; setter; _ };
   args = [ obj ];
   _;
  } -> (
      (*
         either a getter {[ x #. height ]} or {[ x ## method_call ]}
      *)
      assert (not setter);

      match
        compile_lambda { lambda_cxt with continuation = NeedValue Not_tail } obj
      with
      | { value = None; _ } -> assert false
      | { block; value = Some b; _ } ->
          let blocks, ret =
            if block = [] then ([], E.dot b property)
            else
              match Js_ast_util.named_expression b with
              | None -> (block, E.dot b property)
              | Some (x, b) -> (block @ [ x ], E.dot (E.var b) property)
          in
          Js_output.output_of_block_and_expression lambda_cxt.continuation
            blocks ret)
  | {
   primitive = Pfull_apply;
   args =
     [
       Lprim
         {
           primitive =
             Pjs_unsafe_downgrade { name = property; setter = true; _ };
           args = [ obj ];
           _;
         };
       setter_val;
     ];
   _;
  } -> (
      let need_value_no_return_cxt =
        { lambda_cxt with continuation = NeedValue Not_tail }
      in
      let obj_output = compile_lambda need_value_no_return_cxt obj in
      let arg_output = compile_lambda need_value_no_return_cxt setter_val in
      let cont obj_block arg_block obj_code =
        Js_output.output_of_block_and_expression lambda_cxt.continuation
          (match obj_code with
          | None -> List.append obj_block arg_block
          | Some obj_code -> List.append obj_block (obj_code :: arg_block))
      in
      match (obj_output, arg_output) with
      | { value = None; _ }, _ | _, { value = None; _ } -> assert false
      | ( { block = obj_block; value = Some obj; _ },
          { block = arg_block; value = Some value; _ } ) -> (
          match Js_ast_util.named_expression obj with
          | None ->
              cont obj_block arg_block None
                (E.seq (E.assign (E.dot obj property) value) E.unit)
          | Some (obj_code, obj) ->
              cont obj_block arg_block (Some obj_code)
                (E.seq (E.assign (E.dot (E.var obj) property) value) E.unit)))
  | {
   primitive = Pfull_apply;
   args =
     Lprim { primitive = Pjs_unsafe_downgrade { setter = true; _ }; _ } :: _;
   _;
  } ->
      assert false
  | { primitive = Pfull_apply | Pvoid_run; args; loc } -> (
      (* 1. uncurried call should not do eta-conversion
            since `fn.length` will broken
         2. invariant: `external` declaration will guarantee
         the function application is saturated
         3. we need a location for Pccall in the call site
      *)
      match args with
      | fn :: rest ->
          compile_lambda lambda_cxt
            (Lam.apply fn rest
               {
                 ap_loc = loc;
                 ap_inlined = Default_inline;
                 ap_status = App_uncurry;
               })
          (*FIXME: should pass info down: `f a [@u][@inlined]`*)
      | [] -> assert false)
  | { primitive = Pjs_fn_method; args = args_lambda; _ } -> (
      match args_lambda with
      | [ Lfunction { params; body; attr = { return_unit; _ }; _ } ] ->
          Js_output.output_of_block_and_expression lambda_cxt.continuation []
            (E.method_ params ~return_unit
               (* Invariant:  jmp_table can not across function boundary,
                  here we share env
               *)
               (Js_output.output_as_block
                  (compile_lambda
                     {
                       lambda_cxt with
                       continuation =
                         EffectCall
                           (Maybe_tail_is_return
                              (Tail_with_name
                                 { label = None; in_staticcatch = false }));
                       jmp_table = Lam_compile_context.empty_handler_map;
                     }
                     body)))
      | _ -> assert false)
  | { primitive = Pjs_fn_make arity; args = [ fn ]; loc } ->
      compile_lambda lambda_cxt
        (Lam_eta_conversion.unsafe_adjust_to_arity loc ~to_:arity ?from:None fn)
  | { primitive = Pjs_fn_make _; args = [] | _ :: _ :: _; _ } -> assert false
  | { primitive = Pjs_object_create labels; args; _ } ->
      let args_block, args_expr =
        if args = [] then ([], [])
        else
          let new_cxt = { lambda_cxt with continuation = NeedValue Not_tail } in
          List.split_map args (fun x ->
              match compile_lambda new_cxt x with
              | { block; value = Some b; _ } -> (block, b)
              | { value = None; _ } -> assert false)
      in
      let block, exp =
        Lam_compile_external_obj.assemble_obj_args labels args_expr
      in
      Js_output.output_of_block_and_expression lambda_cxt.continuation
        (List.concat args_block @ block)
        exp
  | { primitive; args; loc } ->
      let args_block, args_expr =
        if args = [] then ([], [])
        else
          let new_cxt = { lambda_cxt with continuation = NeedValue Not_tail } in
          List.split_map args (fun x ->
              match compile_lambda new_cxt x with
              | { block; value = Some b; _ } -> (block, b)
              | { value = None; _ } -> assert false)
      in
      let args_code : J.block = List.concat args_block in
      let exp =
        (* TODO: all can be done in [compile_primitive] *)
        Lam_compile_primitive.translate loc lambda_cxt primitive args_expr
      in
      Js_output.output_of_block_and_expression lambda_cxt.continuation args_code
        exp

and compile_lambda (lambda_cxt : Lam_compile_context.t) (cur_lam : Lam.t) :
    Js_output.t =
  match cur_lam with
  | Lfunction { params; body; attr = { return_unit; _ }; _ } ->
      Js_output.output_of_expression lambda_cxt.continuation
        ~no_effects:no_effects_const
        (E.ocaml_fun params ~return_unit
           (* Invariant:  jmp_table can not across function boundary,
              here we share env
           *)
           (Js_output.output_as_block
              (compile_lambda
                 {
                   lambda_cxt with
                   continuation =
                     EffectCall
                       (Maybe_tail_is_return
                          (Tail_with_name
                             { label = None; in_staticcatch = false }));
                   jmp_table = Lam_compile_context.empty_handler_map;
                 }
                 body)))
  | Lapply appinfo -> compile_apply appinfo lambda_cxt
  | Llet (let_kind, id, arg, body) ->
      (* Order matters..  see comment below in [Lletrec] *)
      let args_code =
        compile_lambda
          {
            lambda_cxt with
            continuation = Declare (Lam_group.of_lam_kind let_kind, id);
          }
          arg
      in
      Js_output.append_output args_code (compile_lambda lambda_cxt body)
  | Lmutlet (id, arg, body) ->
      (* Order matters..  see comment below in [Lletrec] *)
      let args_code =
        compile_lambda
          { lambda_cxt with continuation = Declare (Variable, id) }
          arg
      in
      Js_output.append_output args_code (compile_lambda lambda_cxt body)
  | Lletrec (id_args, body) ->
      (* There is a bug in our current design,
         it requires compile args first (register that some objects are jsidentifiers)
         and compile body wiht such effect.
         So here we should compile [id_args] first, then [body] later.
         Note it has some side effect over cache number as well, mostly the value of
         [Caml_primitive["caml_get_public_method"](x,hash_tab, number)]

         To fix this,
         1. scan the lambda layer first, register js identifier before proceeding
         2. delay the method call into javascript ast
      *)
      let v = compile_recursive_lets lambda_cxt id_args in
      Js_output.append_output v (compile_lambda lambda_cxt body)
  | Lvar id | Lmutvar id ->
      Js_output.output_of_expression lambda_cxt.continuation
        ~no_effects:no_effects_const (E.var id)
  | Lconst c ->
      Js_output.output_of_expression lambda_cxt.continuation
        ~no_effects:no_effects_const
        (Lam_compile_const.translate c)
  | Lglobal_module i ->
      (* introduced by
         1. {[ include Array --> let include  = Array  ]}
         2. inline functor application
      *)
      Js_output.output_of_block_and_expression lambda_cxt.continuation []
        (E.ml_module_as_var i)
  | Lprim prim_info -> compile_prim prim_info lambda_cxt
  | Lsequence (l1, l2) ->
      let output_l1 =
        compile_lambda { lambda_cxt with continuation = EffectCall Not_tail } l1
      in
      let output_l2 = compile_lambda lambda_cxt l2 in
      Js_output.append_output output_l1 output_l2
  | Lifthenelse (predicate, t_branch, f_branch) ->
      compile_ifthenelse predicate t_branch f_branch lambda_cxt
  | Lstringswitch (l, cases, default) ->
      compile_stringswitch l cases default lambda_cxt
  | Lswitch (switch_arg, sw) -> compile_switch switch_arg sw lambda_cxt
  | Lstaticraise (i, largs) -> compile_staticraise i largs lambda_cxt
  | Lstaticcatch _ -> compile_staticcatch cur_lam lambda_cxt
  | Lwhile (p, body) -> compile_while p body lambda_cxt
  | Lfor (id, start, finish, direction, body) -> (
      match (direction, finish) with
      | ( Upto,
          ( Lprim
              {
                primitive = Psubint;
                args = [ new_finish; Lconst (Const_int { i = 1l; _ }) ];
                _;
              }
          | Lprim { primitive = Poffsetint -1; args = [ new_finish ]; _ } ) ) ->
          compile_for id start new_finish Up body lambda_cxt
      | _ ->
          compile_for id start finish
            (if direction = Upto then Upto else Downto)
            body lambda_cxt)
  | Lassign (id, lambda) -> compile_assign id lambda lambda_cxt
  | Ltrywith (lam, id, catch) ->
      (* generate documentation *)
      compile_trywith lam id catch lambda_cxt
  | Lsend (meth_kind, met, obj, args, _loc) ->
      compile_send meth_kind met obj args lambda_cxt
  | Lifused (_, lam) -> compile_lambda lambda_cxt lam
