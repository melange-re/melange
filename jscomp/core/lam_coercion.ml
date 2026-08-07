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

(*
  Invariant: The last one is always [exports]
  Compile definitions
  Compile exports
  Assume Pmakeblock(_,_),
  lambda_exports are pure
  compile each binding with a return value

  Such invariant  might be wrong in toplevel (since it is all bindings)

  We should add this check as early as possible
*)

(*
- {[ Ident.same id eid]} is more  correct,
        however, it will introduce a coercion, which is not necessary,
        as long as its name is the same, we want to avoid
        another coercion
        In most common cases, it will be
   {[
     let export/100 =a fun ..
         export/100
   ]}
        This comes from we have lambda as below
   {[
     (* let export/100 =a export/99  *)
     (* above is probably the cause but does not have to be  *)
     (export/99)
   ]}
        [export/100] was not eliminated due to that it is export id,
        if we rename export/99 to be export id, then we don't need
        the  coercion any more, and export/100 will be dced later
   - avoid rebound
   check [map.ml] here coercion, we introduced
                    rebound which is not corrrect
   {[
     let Make/identifier = function (funarg){
         var $$let = Make/identifier(funarg);
                 return [0, ..... ]
       }
   ]}
                    Possible fix ?
                    change export identifier, we should do this in the very
                    beginning since lots of optimizations depend on this
                    however
*)

type t = {
  export_list : Runtime_fields.t list;
  export_set : Ident.Set.t;
  groups : Lam_group.t list;
      (* all code to be compiled later = original code + rebound coercions *)
}

let export_map t =
  List.fold_left t.groups ~init:Ident.Map.empty ~f:(fun export_map -> function
    | Lam_group.Single (_, id, lam) when Ident.Set.mem id t.export_set ->
        Ident.Map.add ~key:id ~data:lam export_map
    | _ -> export_map)

let groups t = t.groups
let ids_of_exports fields = List.map fields ~f:Runtime_fields.id

let handle_exports (meta : Lam_stats.t) (lambda_exports : Lam.t list)
    (reverse_input : Lam_group.t list) =
  let (original_exports : Runtime_fields.t list) = meta.exports in
  let len = List.length original_exports in
  let tbl = String.Hashtbl.create len in
  let result =
    List.fold_right2
      ~f:(fun (original_export : Runtime_fields.t) (lam : Lam.t) (acc : t) ->
        let original_export_id = Runtime_fields.id original_export in
        let original_name = Ident.name original_export_id in
        let runtime_name = Runtime_fields.name original_export in
        let already_present =
          let already_present = String.Hashtbl.mem tbl runtime_name in
          String.Hashtbl.replace tbl ~key:runtime_name ~data:();
          already_present
        in
        if already_present then
          Mel_exception.error (Mel_duplicate_exports runtime_name);
        let export_field id = Runtime_fields.with_id original_export id in
        match lam with
        | Lvar id | Lmutvar id ->
            if Ident.name id = original_name then
              { acc with export_list = export_field id :: acc.export_list }
            else
              let newid = Ident.rename original_export_id in
              let kind : Lam_compat.let_kind = Alias in
              Lam_util.alias_ident_or_global meta newid id NA;
              {
                acc with
                export_list = export_field newid :: acc.export_list;
                groups =
                  Single
                    ( (match lam with
                      | Lmutvar _ -> Variable
                      | _ -> Lam_group.of_lam_kind kind),
                      newid,
                      lam )
                  :: acc.groups;
              }
        | _ ->
            (*
              Example:
              {[
              let N = [a0,a1,a2,a3]
              in [[ N[0], N[2]]]

              ]}
              After optimization
              {[
                [ [ a0, a2] ]
              ]}
              Here [N] is elminated while N is still exported identifier
              Invariant: [eid] can not be bound before
              FIX: this invariant is not guaranteed.
              Bug manifested: when querying arity info about N, it returns an array
              of size 4 instead of 2
              *)
            let newid = Ident.rename original_export_id in
            (let arity = Lam_arity_analysis.get_arity meta lam in
             if not (Lam_arity.first_arity_na arity) then
               Ident.Hashtbl.add meta.ident_tbl ~key:newid
                 ~data:
                   (FunctionId
                      {
                        arity;
                        lambda =
                          (match lam with
                          | Lfunction _ -> Some (lam, Lam_non_rec)
                          | _ -> None);
                        call_summary = Lam_call_summary.Unknown;
                      }));
            {
              acc with
              export_list = export_field newid :: acc.export_list;
              groups = Single (Strict, newid, lam) :: acc.groups;
            })
      original_exports lambda_exports
      ~init:{ export_list = []; export_set = Ident.Set.empty; groups = [] }
  in
  let export_ids = ids_of_exports result.export_list in
  let export_set = Ident.Set.of_list export_ids in
  let coerced_input = List.rev_append reverse_input result.groups in
  { result with export_set; groups = Lam_dce.remove export_ids coerced_input }

(* TODO: more flattening,
    - also for function compilation, flattening should be done first
    - [compile_group] and [compile] become mutually recursive function
*)

let rec flatten (acc : Lam_group.t list) (lam : Lam.t) :
    Lam.t * Lam_group.t list =
  match lam with
  | Llet (kind, id, arg, body) ->
      let res, l = flatten acc arg in
      flatten (Single (Lam_group.of_lam_kind kind, id, res) :: l) body
  | Lmutlet (id, arg, body) ->
      let res, l = flatten acc arg in
      flatten (Single (Variable, id, res) :: l) body
  | Lletrec (bind_args, body) -> flatten (Recursive bind_args :: acc) body
  | Lsequence (l, r) ->
      let res, l = flatten acc l in
      flatten (Lam_group.nop_cons res l) r
  | x -> (x, acc)

(* Export identifiers can be rebound above, so update both representations in
   [Lam_stats.t] from the completed export list. *)
let coerce_and_group_big_lambda (meta : Lam_stats.t) lam : t * Lam_stats.t =
  match flatten [] lam with
  | Lprim { primitive = Pmakeblock _; args = lambda_exports; _ }, reverse_input
    ->
      let coerced_input = handle_exports meta lambda_exports reverse_input in
      ( coerced_input,
        {
          meta with
          export_idents = coerced_input.export_set;
          exports = coerced_input.export_list;
        } )
  | _ ->
      (* This could happen see #2474*)
      (* #3595
         TODO: FIXME later
      *)
      assert false
