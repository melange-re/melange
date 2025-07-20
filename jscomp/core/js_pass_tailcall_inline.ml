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

(* When we inline a function call, if we don't do a beta-reduction immediately, there is
   a chance that it is ignored, (we can not assume that each pass is robust enough)

   After we do inlining, it makes sense to do another constant folding and propogation
*)

(* Check: shall we inline functions with while loop? if it is used only once,
   it makes sense to inline it
*)

module S = Js_stmt_make
(* module E = Js_exp_make *)

let super = Js_record_map.super

let substitute_variables (map : Ident.t Ident.Map.t) =
  { super with ident = (fun _ id -> Ident.Map.find_default id map ~default:id) }

(* 1. recursive value ? let rec x = 1 :: x
    non-terminating
    2. duplicative identifiers ..
    remove it at the same time is a bit unsafe,
    since we have to guarantee that the one use
    case is substituted
    we already have this? in [defined_idents]

    At this time, when tailcall happened, the parameter can be assigned
      for example {[
     function (_x,y){
         _x = u
       }
   ]}
      if it is substituted, the assignment will align the value which is incorrect
*)

let inline_call =
  let rec fold_right3 l r last ~init:acc ~f =
    match (l, r, last) with
    | [], [], [] -> acc
    | [ a0 ], [ b0 ], [ c0 ] -> f a0 b0 c0 acc
    | [ a0; a1 ], [ b0; b1 ], [ c0; c1 ] -> f a0 b0 c0 (f a1 b1 c1 acc)
    | [ a0; a1; a2 ], [ b0; b1; b2 ], [ c0; c1; c2 ] ->
        f a0 b0 c0 (f a1 b1 c1 (f a2 b2 c2 acc))
    | [ a0; a1; a2; a3 ], [ b0; b1; b2; b3 ], [ c0; c1; c2; c3 ] ->
        f a0 b0 c0 (f a1 b1 c1 (f a2 b2 c2 (f a3 b3 c3 acc)))
    | [ a0; a1; a2; a3; a4 ], [ b0; b1; b2; b3; b4 ], [ c0; c1; c2; c3; c4 ] ->
        f a0 b0 c0 (f a1 b1 c1 (f a2 b2 c2 (f a3 b3 c3 (f a4 b4 c4 acc))))
    | ( a0 :: a1 :: a2 :: a3 :: a4 :: arest,
        b0 :: b1 :: b2 :: b3 :: b4 :: brest,
        c0 :: c1 :: c2 :: c3 :: c4 :: crest ) ->
        f a0 b0 c0
          (f a1 b1 c1
             (f a2 b2 c2
                (f a3 b3 c3
                   (f a4 b4 c4 (fold_right3 arest brest crest ~init:acc ~f)))))
    | _, _, _ -> invalid_arg "fold_right3"
  in
  fun (immutable_list : bool list)
    params
    (args : J.expression list)
    processed_blocks
  ->
    let map, block =
      if immutable_list = [] then
        List.fold_right2
          ~f:(fun param (arg : J.expression) (map, acc) ->
            match arg.expression_desc with
            | Var (Id id) -> (Ident.Map.add param id map, acc)
            | _ -> (map, S.define_variable ~kind:Variable param arg :: acc))
          params args
          ~init:(Ident.Map.empty, processed_blocks)
      else
        fold_right3 params args immutable_list
          ~init:(Ident.Map.empty, processed_blocks)
          ~f:(fun param arg mask (map, acc) ->
            match (mask, arg.expression_desc) with
            | true, Var (Id id) -> (Ident.Map.add param id map, acc)
            | _ -> (map, S.define_variable ~kind:Variable param arg :: acc))
    in
    if Ident.Map.is_empty map then block
    else
      let obj = substitute_variables map in
      obj.block obj block

(** There is a side effect when traversing dead code, since
    we assume that substitute a node would mark a node as dead node,

    so if we traverse a dead node, this would get a wrong result.
    it does happen in such scenario
    {[
      let generic_basename is_dir_sep current_dir_name name =
        let rec find_end n =
          if n < 0 then String.sub name 0 1
          else if is_dir_sep name n then find_end (n - 1)
          else find_beg n (n + 1)
        and find_beg n p =
          if n < 0 then String.sub name 0 p
          else if is_dir_sep name n then String.sub name (n + 1) (p - n - 1)
          else find_beg (n - 1) p
        in
        if name = ""
        then current_dir_name
        else find_end (String.length name - 1)
    ]}
    [find_beg] can potentially be expanded in [find_end] and in [find_end]'s expansion,
    if the order is not correct, or even worse, only the wrong one [find_beg] in [find_end] get expanded
    (when we forget to recursive apply), then some code non-dead [find_beg] will be marked as dead,
    while it is still called
*)
let super = Js_record_map.super

let subst (export_set : Ident.Set.t)
    (stats : J.variable_declaration Ident.Hash.t) =
  {
    super with
    statement =
      (fun self st ->
        match st.statement_desc with
        | Variable { value = _; ident_info = { used_stats = Dead_pure }; _ } ->
            S.block []
        | Variable
            { ident_info = { used_stats = Dead_non_pure }; value = Some v; _ }
          ->
            S.exp v
        | _ -> super.statement self st);
    variable_declaration =
      (fun self ({ ident; value = _; property = _; ident_info = _ } as v) ->
        (* TODO: replacement is a bit shaky, the problem is the lambda we stored is
           not consistent after we did some subsititution, and the dead code removal
           does rely on this (otherwise, when you do beta-reduction you have to regenerate names)
        *)
        let v = super.variable_declaration self v in
        Ident.Hash.add stats ident v;
        (* see #278 before changes *)
        v);
    block =
      (fun self bs ->
        match bs with
        | ({
             statement_desc =
               Variable
                 ({ value = Some ({ expression_desc = Fun _; _ } as v); _ } as
                  vd);
             comment = _;
           } as st)
          :: rest -> (
            let is_export = Ident.Set.mem export_set vd.ident in
            if is_export then self.statement self st :: self.block self rest
            else
              match Ident.Hash.find_opt stats vd.ident with
              (* TODO: could be improved as [mem] *)
              | None ->
                  if Js_analyzer.no_side_effect_expression v then
                    S.exp v :: self.block self rest
                  else self.block self rest
              | Some _ -> self.statement self st :: self.block self rest)
        | [
         ({
            statement_desc =
              Return
                {
                  expression_desc =
                    Call
                      { expr = { expression_desc = Var (Id id); _ }; args; _ };
                  _;
                };
            _;
          } as st);
        ] -> (
            match Ident.Hash.find_opt stats id with
            | Some
                ({
                   value =
                     Some
                       {
                         expression_desc =
                           Fun { method_ = false; params; body = block; env; _ };
                         comment = _;
                         _;
                       };
                   (*TODO: don't inline method tail call yet,
                     [this] semantics are weird
                   *)
                   property = Alias | StrictOpt | Strict;
                   ident_info = { used_stats = Once_pure };
                   ident = _;
                 } as v)
              when List.same_length params args ->
                Js_op.update_used_stats v.ident_info Dead_pure;
                let no_tailcall = Js_fun_env.no_tailcall env in
                let processed_blocks =
                  self.block self block
                  (* see #278 before changes*)
                in
                inline_call no_tailcall params args processed_blocks
                (* Ext_list.fold_right2
                   params args  processed_blocks
                   (fun param arg acc ->
                      S.define_variable ~kind:Variable param arg :: acc) *)
                (* Mark a function as dead means it will never be scanned,
                   here we inline the function
                *)
            | None | Some _ -> [ self.statement self st ])
        | [
         {
           statement_desc =
             Return
               {
                 expression_desc =
                   Call
                     {
                       expr =
                         {
                           expression_desc =
                             Fun
                               { method_ = false; params; body = block; env; _ };
                           _;
                         };
                       args;
                       _;
                     };
                 _;
               };
           _;
         };
        ]
          when List.same_length params args ->
            let no_tailcall = Js_fun_env.no_tailcall env in
            let processed_blocks =
              self.block self block
              (* see #278 before changes*)
            in
            inline_call no_tailcall params args processed_blocks
        | x :: xs -> self.statement self x :: self.block self xs
        | [] -> []);
  }

let tailcall_inline (program : J.program) =
  let stats = Js_pass_get_used.get_stats program in
  let export_set = program.export_set in
  let obj = subst export_set stats in
  obj.program obj program
