(* Copyright (C) 2022- Authors of Melange
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

(* Utilities for compiling "module rec" definitions *)

type binding =
  Translmod.id_or_ignore_loc
  * (Lambda.lambda * Lambda.lambda) option
  * Lambda.lambda

let eval_rec_bindings_aux =
  let mel_init_mod args loc =
    Lambda.Lprim
      ( Pccall (Primitive.simple ~name:"#init_mod" ~arity:2 ~alloc:true),
        args,
        loc )
  and mel_update_mod args loc =
    Lambda.Lprim
      ( Pccall (Primitive.simple ~name:"#update_mod" ~arity:3 ~alloc:true),
        args,
        loc )
  in
  let rec bind_inits args acc =
    match args with
    | [] -> acc
    | (_id, None, _rhs) :: rem -> bind_inits rem acc
    | (Translmod.Ignore_loc _, _, _) :: rem -> bind_inits rem acc
    | (Id id, Some (loc, shape), _rhs) :: rem ->
        Lambda.Llet
          ( Strict,
            Pgenval,
            id,
            mel_init_mod [ loc; shape ] Loc_unknown,
            bind_inits rem acc )
  in
  let rec bind_strict args acc =
    match args with
    | [] -> acc
    | (Translmod.Id id, None, rhs) :: rem ->
        Lambda.Llet (Strict, Pgenval, id, rhs, bind_strict rem acc)
    | (_id, (None | Some _), _rhs) :: rem -> bind_strict rem acc
  in
  let rec patch_forwards args cont =
    match args with
    | [] -> cont
    | (_id, None, _rhs) :: rem -> patch_forwards rem cont
    | (Translmod.Ignore_loc _, _, _rhs) :: rem -> patch_forwards rem cont
    | (Id id, Some (_loc, shape), rhs) :: rem ->
        Lambda.Lsequence
          ( mel_update_mod [ shape; Lvar id; rhs ] Loc_unknown,
            patch_forwards rem cont)
  in
  fun (bindings : binding list) cont ->
    bind_inits bindings (bind_strict bindings (patch_forwards bindings cont))

(* collect all function declarations
   if the module creation is just a set of function declarations and consts,
   it is good *)
let rec is_function_or_const_block =
  let rec aux_bindings bindings acc =
    match bindings with
    | [] -> Some acc
#if OCAML_VERSION >= (5,2,0)
    | { Lambda.id; def = { attr = { smuggled_lambda = false; _ }; _ } } :: rest ->
#else
    | (id, Lambda.Lfunction _) :: rest ->
#endif
      aux_bindings rest (Ident.Set.add id acc)
#if OCAML_VERSION >= (5,2,0)
    | { id = _; def = _ } :: _ -> None
#else
    | (_, _) :: _ -> None
#endif
  in
  fun (lam : Lambda.lambda) acc ->
    match lam with
    | Levent (lam, _) -> is_function_or_const_block lam acc
    | Lprim (Pmakeblock _, args, _) ->
        List.for_all args ~f:(function
            | Lambda.Lvar id -> Ident.Set.mem id acc
            | Lfunction _ | Lconst _ -> true
            | _ -> false)
    | Llet (_, _, id, Lfunction _, cont) | Lmutlet (_, id, Lfunction _, cont) ->
        is_function_or_const_block cont (Ident.Set.add id acc)
    | Lletrec (bindings, cont) -> (
        match aux_bindings bindings acc with
        | None -> false
        | Some acc -> is_function_or_const_block cont acc)
    | Llet (_, _, _, Lconst _, cont) 
    | Lmutlet (_, _, Lconst _, cont) ->
        is_function_or_const_block cont acc
    | (Llet (_, _, id1, Lvar id2, cont)
    |  Lmutlet (_, id1, Lvar id2, cont)) when Ident.Set.mem id2 acc ->
      is_function_or_const_block cont (Ident.Set.add id1 acc)
    | _ -> false

let is_strict_or_all_functions (xs : binding list) =
  List.for_all xs ~f:(fun (_, opt, rhs) ->
    match opt with
    | None -> true
    | _ -> is_function_or_const_block rhs Ident.Set.empty)

(* Without such optimizations:

   {[
     module rec X : sig
       val f : int -> int
     end = struct
       let f x = x + 1
     end
     and Y : sig
       val f : int -> int
     end = struct
       let f x  = x + 2
     end
   ]}
   would generate such rawlambda:

   {[
     (setglobal Debug_tmp!
     (let
       (X/1002 = (#init_mod [0: "debug_tmp.ml" 15 6] [0: [0: [0: 0a "f"]]])
        Y/1003 = (#init_mod [0: "debug_tmp.ml" 20 6] [0: [0: [0: 0a "f"]]]))
       (seq
         (#update_mod [0: [0: [0: 0a "f"]]] X/1002
           (let (f/1010 = (function x/1011 (+ x/1011 1)))
             (makeblock 0/[f] f/1010)))
         (#update_mod [0: [0: [0: 0a "f"]]] Y/1003
           (let (f/1012 = (function x/1013 (+ x/1013 2)))
             (makeblock 0/[f] f/1012)))
         (makeblock 0/module/exports X/1002 Y/1003))))

   ]}
*)

let eval_rec_bindings (bindings : binding list) cont =
  if is_strict_or_all_functions bindings then
    Lambda.Lletrec
      ( List.filter_map bindings ~f:(function
#if OCAML_VERSION >= (5,2,0)
            | Translmod.Id id, _, Lambda.Lfunction def ->
              Some { Lambda.id; def}
            | Id id, _, rhs ->
              let def =
                Lambda.lfunction' ~loc:Loc_unknown ~kind:Curried
                  ~attr:{ Lambda.default_function_attribute with smuggled_lambda = true }
                  ~params:[] ~body:rhs ~return:Pgenval
              in
              Some { Lambda.id; def}
#else
            | Translmod.Id id, _, rhs -> Some (id, rhs)
#endif
            | _, _, _ -> None)
          ,
        cont )
  else eval_rec_bindings_aux bindings cont

