(* Copyright (C) 2018 Hongbo Zhang, Authors of ReScript
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

let pass_free_variables (l : Lam.t) : Ident.Set.t =
  let fv = ref Ident.Set.empty in
  let rec free_list xs = List.iter ~f:free xs
  and free_list_snd : 'a. ('a * Lam.t) list -> unit =
   fun xs -> List.iter ~f:(fun (_, x) -> free x) xs
  and free (l : Lam.t) =
    match l with
    | Lvar id | Lmutvar id -> fv := Ident.Set.add id !fv
    | Lassign (id, e) ->
        free e;
        fv := Ident.Set.add id !fv
    | Lstaticcatch (e1, (_, vars), e2) ->
        free e1;
        free e2;
        List.iter ~f:(fun id -> fv := Ident.Set.remove id !fv) vars
    | Ltrywith (e1, exn, e2) ->
        free e1;
        free e2;
        fv := Ident.Set.remove exn !fv
    | Lfunction { body; params; _ } ->
        free body;
        List.iter ~f:(fun param -> fv := Ident.Set.remove param !fv) params
    | Llet (_, id, arg, body) | Lmutlet (id, arg, body) ->
        free arg;
        free body;
        fv := Ident.Set.remove id !fv
    | Lletrec (decl, body) ->
        free body;
        free_list_snd decl;
        List.iter ~f:(fun (id, _exp) -> fv := Ident.Set.remove id !fv) decl
    | Lfor (v, e1, e2, _dir, e3) ->
        free e1;
        free e2;
        free e3;
        fv := Ident.Set.remove v !fv
    | Lconst _ -> ()
    | Lapply { ap_func; ap_args; _ } ->
        free ap_func;
        free_list ap_args
    | Lglobal_module _ -> ()
    (* according to the existing semantics:
       [primitive] is not counted
    *)
    | Lprim { args; _ } -> free_list args
    | Lswitch (arg, sw) ->
        free arg;
        free_list_snd sw.sw_consts;
        free_list_snd sw.sw_blocks;
        Option.iter free sw.sw_failaction
    | Lstringswitch (arg, cases, default) ->
        free arg;
        free_list_snd cases;
        Option.iter free default
    | Lstaticraise (_, args) -> free_list args
    | Lifthenelse (e1, e2, e3) ->
        free e1;
        free e2;
        free e3
    | Lsequence (e1, e2) ->
        free e1;
        free e2
    | Lwhile (e1, e2) ->
        free e1;
        free e2
    | Lsend (_k, met, obj, args, _) ->
        free met;
        free obj;
        free_list args
    | Lifused (_v, e) -> free e
  in
  free l;
  !fv

(**
        [hit_any_variables fv l]
        check the lambda expression [l] if has some free
        variables captured by [fv].
        Note it does not do any checking like below
        [Llet(str,id,arg,body)]
        it only check [arg] or [body] is hit or not, there
        is a case that [id] is hit in [arg] but also exists
        in [fv], this is ignored.
*)
