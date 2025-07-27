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

let transitive_closure (initial_idents : Ident.t list)
    (ident_freevars : Ident.Set.t Ident.Hashtbl.t) =
  let visited = Ident.Hashtbl.create 31 in
  let rec dfs (id : Ident.t) : unit =
    if not (Ident.Hashtbl.mem visited id || Ident.is_js_or_global id) then (
      Ident.Hashtbl.replace visited id ();
      match Ident.Hashtbl.find ident_freevars id with
      | exception Not_found ->
          Format.ksprintf
            (fun s -> failwith (__LOC__ ^ s))
            "%s/%d not found" (Ident.name id) (Ident.stamp id)
      | e -> Ident.Set.iter ~f:dfs e)
  in
  List.iter ~f:dfs initial_idents;
  visited

let remove export_idents (rest : Lam_group.t list) : Lam_group.t list =
  let ident_free_vars : _ Ident.Hashtbl.t = Ident.Hashtbl.create 17 in
  (* calculate initial required idents,
     at the same time, populate dependency set [ident_free_vars]
  *)
  let initial_idents =
    List.fold_left
      ~f:(fun acc (x : Lam_group.t) ->
        match x with
        | Single (kind, id, lam) -> (
            Ident.Hashtbl.add ident_free_vars id
              (Lam_free_variables.pass_free_variables lam);
            match kind with
            | Alias | StrictOpt -> acc
            | Strict | Variable -> id :: acc)
        | Recursive bindings ->
            List.fold_left
              ~f:(fun acc (id, lam) ->
                Ident.Hashtbl.add ident_free_vars id
                  (Lam_free_variables.pass_free_variables lam);
                match lam with Lfunction _ -> acc | _ -> id :: acc)
              ~init:acc bindings
        | Nop lam ->
            if Lam_analysis.no_side_effects lam then acc
            else
              (* its free varaibles here will be defined above *)
              Ident.Set.fold (Lam_free_variables.pass_free_variables lam)
                ~init:acc ~f:(fun x acc -> x :: acc))
      ~init:export_idents rest
  in
  let visited = transitive_closure initial_idents ident_free_vars in
  List.fold_left
    ~f:(fun acc (x : Lam_group.t) ->
      match x with
      | Single (_, id, _) ->
          if Ident.Hashtbl.mem visited id then x :: acc else acc
      | Nop _ -> x :: acc
      | Recursive bindings -> (
          let b =
            List.fold_right
              ~f:(fun ((id, _) as v) acc ->
                if Ident.Hashtbl.mem visited id then v :: acc else acc)
              bindings ~init:[]
          in
          match b with [] -> acc | _ -> Recursive b :: acc))
    ~init:[] rest
  |> List.rev
