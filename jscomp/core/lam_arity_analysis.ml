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

let arity_of_var (meta : Lam_stats.t) (v : Ident.t) =
  (* for functional parameter, if it is a high order function,
      if it's not from function parameter, we should warn
  *)
  match Ident.Hashtbl.find_opt meta.ident_tbl v with
  | Some (FunctionId { arity; _ }) -> arity
  | Some _ | None -> Lam_arity.na

let rec field_element (meta : Lam_stats.t) (lam : Lam.t) (i : int) =
  match lam with
  | Lvar v | Lmutvar v -> (
      match Ident.Hashtbl.find_opt meta.ident_tbl v with
      | Some (ImmutableBlock elems) ->
          if i >= 0 && i < Array.length elems then Array.unsafe_get elems i
          else Lam_id_kind.Element.NA
      | Some _ | None -> Lam_id_kind.Element.NA)
  | Lprim { primitive = Pfield (j, _); args = [ owner ]; _ } -> (
      match field_element meta owner j with
      | Lam_id_kind.Element.ImmutableBlock elems ->
          if i >= 0 && i < Array.length elems then Array.unsafe_get elems i
          else Lam_id_kind.Element.NA
      | _ -> Lam_id_kind.Element.NA)
  | _ -> Lam_id_kind.Element.NA

(* we need record all aliases -- since not all aliases are eliminated,
   mostly are toplevel bindings
   We will keep iterating such environment
   If not found, we will return [NA]
*)
let rec get_arity (meta : Lam_stats.t) (lam : Lam.t) : Lam_arity.t =
  match lam with
  | Lvar v | Lmutvar v -> arity_of_var meta v
  | Lconst _ -> Lam_arity.non_function_arity_info
  | Llet (_, _, _, l) | Lmutlet (_, _, l) -> get_arity meta l
  | Lprim
      {
        primitive = Pfield (_, Fld_module { name });
        args = [ Lglobal_module { id; dynamic_import } ];
        _;
      } -> (
      match Lam_compile_env.query_external_id_info ~dynamic_import id name with
      | Some { arity = Single x; _ } -> x
      | Some { arity = Submodule _; _ } | None -> Lam_arity.na)
  | Lprim
      {
        primitive = Pfield (m, _);
        args =
          [
            Lprim
              {
                primitive = Pfield (_, Fld_module { name });
                args = [ Lglobal_module { id; dynamic_import } ];
                _;
              };
          ];
        _;
      } -> (
      match Lam_compile_env.query_external_id_info ~dynamic_import id name with
      | Some { arity = Submodule subs; _ } ->
          if m >= 0 && m < Array.length subs then Array.unsafe_get subs m
          else Lam_arity.na (* TODO: shall we store it as array?*)
      | Some { arity = Single _; _ } | None -> Lam_arity.na)
  | Lprim { primitive = Pfield (m, _); args = [ owner ]; _ } -> (
      match field_element meta owner m with
      | Lam_id_kind.Element.Function arity -> arity
      | SimpleForm lam -> get_arity meta lam
      | NA | ImmutableBlock _ -> Lam_arity.na)
  (* TODO: all information except Pccall is complete, we could
     get more arity information
  *)
  | Lprim
      {
        primitive =
          Praw_js_code { code_info = Exp (Js_function { arity; _ }); _ };
        _;
      } ->
      Lam_arity.info [ arity ] false
  | Lprim { primitive = Praise; _ } -> Lam_arity.raise_arity_info
  | Lglobal_module _ (* TODO: fix me never going to happen *) | Lprim _ ->
      Lam_arity.na (* CHECK*)
  (* shall we handle primitive in a direct way,
      since we know all the information
      Invariant: all primitive application is fully applied,
      since this information  is already available

      -- Check external c functions ?
      -- it's not true for primitives
      like caml_set_oo_id  or  Lprim (Pmakeblock , [])

      it seems true that primitive is always fully applied, however,
      it can return a function
  *)
  | Lletrec (_, body) -> get_arity meta body
  | Lapply { ap_func = app; ap_args = args; _ } -> (
      (* detect functor application *)
      let fn = get_arity meta app in
      match fn with
      | Arity_na -> Lam_arity.na
      | Arity_info (xs, tail) ->
          (* Actually, you can not have truly deministic arities
             for example [fun x -> x ]
          *)
          let rec take (arities : _ list) args =
            match arities with
            | x :: yys ->
                if x = 0 then
                  match args with
                  | [] -> Lam_arity.info yys tail
                  | _ :: _ -> take yys args
                else consume_arity x yys args
            | [] -> if tail then Lam_arity.raise_arity_info else Lam_arity.na
          and consume_arity remaining yys args =
            match args with
            | [] -> Lam_arity.info (remaining :: yys) tail
            | _ :: args ->
                let remaining = remaining - 1 in
                if remaining = 0 then
                  match args with
                  | [] -> Lam_arity.info yys tail
                  | _ :: _ -> take yys args
                else consume_arity remaining yys args
          in
          take xs args)
  | Lfunction { arity; body; _ } -> Lam_arity.merge arity (get_arity meta body)
  | Lswitch
      ( _,
        {
          sw_failaction;
          sw_consts;
          sw_blocks;
          sw_blocks_full = _;
          sw_consts_full = _;
          _;
        } ) ->
      all_switch_lambdas meta sw_failaction sw_consts sw_blocks
  | Lstringswitch (_, sw, d) -> all_case_lambdas meta d sw
  | Lstaticcatch (_, _, handler) -> get_arity meta handler
  | Ltrywith (l1, _, l2) -> merge_lambda_arity meta (get_arity meta l1) l2
  | Lifthenelse (_, l2, l3) -> merge_lambda_arity meta (get_arity meta l2) l3
  | Lsequence (_, l2) -> get_arity meta l2
  | Lstaticraise _ (* since it will not be in tail position *) | Lsend _
  | Lifused _ ->
      Lam_arity.na
  | Lwhile _ | Lfor _ | Lassign _ -> Lam_arity.non_function_arity_info

and merge_lambda_arity meta (acc : Lam_arity.t) lam =
  match acc with
  | Arity_na -> Lam_arity.na
  | Arity_info (xxxs, tail) -> (
      match get_arity meta lam with
      | Arity_na -> Lam_arity.na
      | Arity_info (yyys, tail2) -> Lam_arity.merge_arities xxxs yyys tail tail2
      )

and merge_case_lambdas :
    'a. Lam_stats.t -> Lam_arity.t -> ('a * Lam.t) list -> Lam_arity.t =
 fun meta acc cases ->
  match (acc, cases) with
  | Arity_na, _ -> Lam_arity.na
  | _, [] -> acc
  | _, (_, lam) :: cases ->
      merge_case_lambdas meta (merge_lambda_arity meta acc lam) cases

and all_case_lambdas :
    'a. Lam_stats.t -> Lam.t option -> ('a * Lam.t) list -> Lam_arity.t =
 fun meta first cases ->
  match first with
  | Some lam -> merge_case_lambdas meta (get_arity meta lam) cases
  | None -> (
      match cases with
      | [] -> Lam_arity.na
      | (_, lam) :: cases -> merge_case_lambdas meta (get_arity meta lam) cases)

and all_switch_lambdas meta failaction consts blocks =
  match failaction with
  | Some lam ->
      merge_case_lambdas meta
        (merge_case_lambdas meta (get_arity meta lam) consts)
        blocks
  | None -> (
      match consts with
      | (_, lam) :: consts ->
          merge_case_lambdas meta
            (merge_case_lambdas meta (get_arity meta lam) consts)
            blocks
      | [] -> (
          match blocks with
          | [] -> Lam_arity.na
          | (_, lam) :: blocks ->
              merge_case_lambdas meta (get_arity meta lam) blocks))
