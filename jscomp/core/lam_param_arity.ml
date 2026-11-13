(* Copyright (C) 2026- Authors of Melange
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

type call_sites = Escaped | Arguments of (Ident.t * Lam.t list) list

let infer =
  let parameter_arguments (meta : Lam_stats.t) (lam : Lam.t) =
    let usages = Ident.Hashtbl.create 17 in
    let bind id (arg : Lam.t) =
      match arg with
      | Lfunction { params = _ :: _ as params; _ } ->
          Ident.Hashtbl.replace usages ~key:id
            ~data:
              (if
                 Ident.Set.mem id meta.export_idents
                 || Ident.Hashtbl.mem usages id
               then Escaped
               else Arguments (List.map params ~f:(fun param -> (param, []))))
      | _ -> ()
    in
    let use id ~f =
      match Ident.Hashtbl.find_opt usages id with
      | Some (Arguments arguments) ->
          Ident.Hashtbl.replace usages ~key:id ~data:(f arguments)
      | Some Escaped | None -> ()
    in
    let rec add_call arguments (args : Lam.t list) =
      match (arguments, args) with
      | [], _ -> Arguments []
      | _ :: _, [] -> Escaped
      | (param, passed) :: arguments, arg :: args -> (
          match add_call arguments args with
          | Arguments rest ->
              let passed =
                match arg with
                | Lvar id when Ident.same id param -> passed
                | _ -> arg :: passed
              in
              Arguments ((param, passed) :: rest)
          | Escaped -> Escaped)
    in
    let rec visit (lam : Lam.t) =
      match lam with
      | Lvar id -> use id ~f:(fun _ -> Escaped)
      | Lapply { ap_func = Lvar id; ap_args; _ } ->
          use id ~f:(fun arguments -> add_call arguments ap_args);
          List.iter ~f:visit ap_args
      | Llet (_, id, arg, _) ->
          bind id arg;
          Lam_iter.iter lam ~f:visit
      | Lletrec (bindings, _) ->
          List.iter ~f:(fun (id, arg) -> bind id arg) bindings;
          Lam_iter.iter lam ~f:visit
      | _ -> Lam_iter.iter lam ~f:visit
    in
    visit lam;
    Ident.Hashtbl.fold usages ~init:[] ~f:(fun ~key:_ ~data acc ->
        match data with
        | Arguments arguments ->
            List.fold_right arguments ~init:acc ~f:(fun (param, args) acc ->
                match args with
                | [] -> acc
                | first :: rest -> (param, first, rest) :: acc)
        | Escaped -> acc)
  in
  let rec resolve (meta : Lam_stats.t) xs =
    let rest =
      List.fold_left xs ~init:[] ~f:(fun rest ((param, first, args) as entry) ->
          match
            List.fold_left args
              ~init:(Lam_arity_analysis.get_arity meta first)
              ~f:(Lam_arity_analysis.merge_lambda_arity meta)
          with
          | Arity_na -> entry :: rest
          | Arity_info ([], _) -> rest
          | Arity_info (_ :: _, _) as arity ->
              Ident.Hashtbl.replace meta.ident_tbl ~key:param
                ~data:(Parameter arity);
              rest)
    in
    if not (List.same_length rest xs) then resolve meta rest
  in
  fun (meta : Lam_stats.t) (lam : Lam.t) ->
    resolve meta (parameter_arguments meta lam)
