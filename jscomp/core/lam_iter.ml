(* Copyright (C) 2018 - Hongbo Zhang, Authors of ReScript
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

type t = Lam.t
type ident = Ident.t

let inner_iter (l : t) (f : t -> unit) : unit =
  match l with
  | Lvar (_ : ident) | Lmutvar _ | Lconst (_ : Lam.Constant.t) -> ()
  | Lapply { ap_func; ap_args; ap_info = _ } ->
      f ap_func;
      List.iter ~f ap_args
  | Lfunction { body; arity = _; params = _; _ } -> f body
  | Llet (_, _id, arg, body) | Lmutlet (_id, arg, body) ->
      f arg;
      f body
  | Lletrec (decl, body) ->
      f body;
      List.iter ~f:(fun (_, x) -> f x) decl
  | Lswitch
      ( arg,
        {
          sw_consts;
          sw_consts_full = _;
          sw_blocks;
          sw_blocks_full = _;
          sw_failaction;
          _;
        } ) ->
      f arg;
      List.iter ~f:(fun (_, x) -> f x) sw_consts;
      List.iter ~f:(fun (_, x) -> f x) sw_blocks;
      Option.iter f sw_failaction
  | Lstringswitch (arg, cases, default) ->
      f arg;
      List.iter ~f:(fun (_, x) -> f x) cases;
      Option.iter f default
  | Lglobal_module _ -> ()
  | Lprim { args; primitive = _; loc = _ } -> List.iter ~f args
  | Lstaticraise (_id, args) -> List.iter ~f args
  | Lstaticcatch (e1, _vars, e2) ->
      f e1;
      f e2
  | Ltrywith (e1, _exn, e2) ->
      f e1;
      f e2
  | Lifthenelse (e1, e2, e3) ->
      f e1;
      f e2;
      f e3
  | Lsequence (e1, e2) ->
      f e1;
      f e2
  | Lwhile (e1, e2) ->
      f e1;
      f e2
  | Lfor (_v, e1, e2, _dir, e3) ->
      f e1;
      f e2;
      f e3
  | Lassign (_id, e) -> f e
  | Lsend (_k, met, obj, args, _loc) ->
      f met;
      f obj;
      List.iter ~f args
  | Lifused (_v, e) -> f e

let option_exists v f = match v with None -> false | Some x -> f x

let inner_exists (l : t) (f : t -> bool) : bool =
  match l with
  | Lvar (_ : ident)
  | Lmutvar _ | Lglobal_module _
  | Lconst (_ : Lam.Constant.t) ->
      false
  | Lapply { ap_func; ap_args; ap_info = _ } ->
      f ap_func || List.exists ~f ap_args
  | Lfunction { body; arity = _; params = _; _ } -> f body
  | Llet (_, _id, arg, body) | Lmutlet (_id, arg, body) -> f arg || f body
  | Lletrec (decl, body) -> f body || List.exists ~f:(fun (_, x) -> f x) decl
  | Lswitch
      ( arg,
        {
          sw_consts;
          sw_consts_full = _;
          sw_blocks;
          sw_blocks_full = _;
          sw_failaction;
          _;
        } ) ->
      f arg
      || List.exists ~f:(fun (_, x) -> f x) sw_consts
      || List.exists ~f:(fun (_, x) -> f x) sw_blocks
      || option_exists sw_failaction f
  | Lstringswitch (arg, cases, default) ->
      f arg
      || List.exists ~f:(fun (_, x) -> f x) cases
      || option_exists default f
  | Lprim { args; primitive = _; loc = _ } -> List.exists ~f args
  | Lstaticraise (_id, args) -> List.exists ~f args
  | Lstaticcatch (e1, _vars, e2) -> f e1 || f e2
  | Ltrywith (e1, _exn, e2) -> f e1 || f e2
  | Lifthenelse (e1, e2, e3) -> f e1 || f e2 || f e3
  | Lsequence (e1, e2) -> f e1 || f e2
  | Lwhile (e1, e2) -> f e1 || f e2
  | Lfor (_v, e1, e2, _dir, e3) -> f e1 || f e2 || f e3
  | Lassign (_id, e) -> f e
  | Lsend (_k, met, obj, args, _loc) -> f met || f obj || List.exists ~f args
  | Lifused (_v, e) -> f e
