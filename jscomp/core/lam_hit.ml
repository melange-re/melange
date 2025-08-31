(* Copyright (C) 2015 - Hongbo Zhang, Authors of ReScript
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

let hit_variables =
  let rec hit_opt fv (x : Lam.t option) =
    match x with None -> false | Some a -> hit fv a
  and hit_var fv (id : Ident.t) = Ident.Set.mem id fv
  and hit_list_snd : 'a. Ident.Set.t -> ('a * Lam.t) list -> bool =
   fun fv x -> List.exists ~f:(fun (_, x) -> hit fv x) x
  and hit_list fv xs = List.exists ~f:(hit fv) xs
  and hit fv l =
    match l with
    | Lam.Lvar id | Lmutvar id -> hit_var fv id
    | Lassign (id, e) -> hit_var fv id || hit fv e
    | Lstaticcatch (e1, (_, _vars), e2) -> hit fv e1 || hit fv e2
    | Ltrywith (e1, _exn, e2) -> hit fv e1 || hit fv e2
    | Lfunction { body; params = _; _ } -> hit fv body
    | Llet (_, _id, arg, body) | Lmutlet (_id, arg, body) ->
        hit fv arg || hit fv body
    | Lletrec (decl, body) -> hit fv body || hit_list_snd fv decl
    | Lfor (_v, e1, e2, _dir, e3) -> hit fv e1 || hit fv e2 || hit fv e3
    | Lconst _ -> false
    | Lapply { ap_func; ap_args; _ } -> hit fv ap_func || hit_list fv ap_args
    | Lglobal_module _ (* global persistent module, play safe *) -> false
    | Lprim { args; _ } -> hit_list fv args
    | Lswitch (arg, sw) ->
        hit fv arg
        || hit_list_snd fv sw.sw_consts
        || hit_list_snd fv sw.sw_blocks
        || hit_opt fv sw.sw_failaction
    | Lstringswitch (arg, cases, default) ->
        hit fv arg || hit_list_snd fv cases || hit_opt fv default
    | Lstaticraise (_, args) -> hit_list fv args
    | Lifthenelse (e1, e2, e3) -> hit fv e1 || hit fv e2 || hit fv e3
    | Lsequence (e1, e2) -> hit fv e1 || hit fv e2
    | Lwhile (e1, e2) -> hit fv e1 || hit fv e2
    | Lsend (_k, met, obj, args, _) ->
        hit fv met || hit fv obj || hit_list fv args
    | Lifused (_v, e) -> hit fv e
  in
  fun (fv : Ident.Set.t) l -> hit fv l

let hit_variable =
  let rec hit_opt fv (x : Lam.t option) =
    match x with None -> false | Some a -> hit fv a
  and hit_var fv (id : Ident.t) = Ident.same id fv
  and hit_list_snd : 'a. Ident.t -> ('a * Lam.t) list -> bool =
   fun fv x -> List.exists ~f:(fun (_, x) -> hit fv x) x
  and hit_list fv xs = List.exists ~f:(hit fv) xs
  and hit fv (l : Lam.t) =
    match l with
    | Lvar id | Lmutvar id -> hit_var fv id
    | Lassign (id, e) -> hit_var fv id || hit fv e
    | Lstaticcatch (e1, (_, _vars), e2) -> hit fv e1 || hit fv e2
    | Ltrywith (e1, _exn, e2) -> hit fv e1 || hit fv e2
    | Lfunction { body; params = _; _ } -> hit fv body
    | Llet (_, _id, arg, body) | Lmutlet (_id, arg, body) ->
        hit fv arg || hit fv body
    | Lletrec (decl, body) -> hit fv body || hit_list_snd fv decl
    | Lfor (_v, e1, e2, _dir, e3) -> hit fv e1 || hit fv e2 || hit fv e3
    | Lconst _ -> false
    | Lapply { ap_func; ap_args; _ } -> hit fv ap_func || hit_list fv ap_args
    | Lglobal_module _ (* global persistent module, play safe *) -> false
    | Lprim { args; _ } -> hit_list fv args
    | Lswitch (arg, sw) ->
        hit fv arg
        || hit_list_snd fv sw.sw_consts
        || hit_list_snd fv sw.sw_blocks
        || hit_opt fv sw.sw_failaction
    | Lstringswitch (arg, cases, default) ->
        hit fv arg || hit_list_snd fv cases || hit_opt fv default
    | Lstaticraise (_, args) -> hit_list fv args
    | Lifthenelse (e1, e2, e3) -> hit fv e1 || hit fv e2 || hit fv e3
    | Lsequence (e1, e2) -> hit fv e1 || hit fv e2
    | Lwhile (e1, e2) -> hit fv e1 || hit fv e2
    | Lsend (_k, met, obj, args, _) ->
        hit fv met || hit fv obj || hit_list fv args
    | Lifused (_v, e) -> hit fv e
  in
  fun (fv : Ident.t) (l : Lam.t) -> hit fv l
