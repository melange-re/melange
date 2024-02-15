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
   Given an [map], rewrite all let bound variables into new variables,
   note that the [map] is changed
   example
   {[
     let a/112 = 3 in a/112
   ]}
   would be converted into
   {[
     let a/113 = 3 in a/113
   ]}

   ATTENTION: [let] bound idents have to be renamed,
   Note we rely on an invariant that parameter could not be rebound
 *)

(*
   Small function inline heuristics:
   Even if a function is small, it does not mean it is good for inlining,
   for example, in list.ml
    {[
      let rec length_aux len = function
          [] -> len
        | a::l -> length_aux (len + 1) l

      let length l = length_aux 0 l
    ]}
    if we inline [length], it will expose [length_aux] to the user, first, it make
    the code not very friendly, also since [length_aux] is used everywhere now, it
    may affect that we will not do the inlining of [length_aux] in [length]

    Criteior for sure to inline
    1. small size, does not introduce extra symbols, non-exported and non-recursive
       non-recursive is required if we re-apply the strategy

    Other Factors:
    2. number of invoked times
    3. arguments are const or not
*)
let rewrite (map : _ Ident.Hash.t) (lam : Lam.t) : Lam.t =
  let rebind i =
    let i' = Ident.rename i in
    Ident.Hash.add map i (Lam.var i');
    i'
  in
  (* order matters, especially for let bindings *)
  let rec option_map op = match op with None -> None | Some x -> Some (aux x)
  and aux (lam : Lam.t) : Lam.t =
    match lam with
    | Lvar v | Lmutvar v -> Ident.Hash.find_default map v lam
    | Llet (str, v, l1, l2) ->
        let v = rebind v in
        let l1 = aux l1 in
        let l2 = aux l2 in
        Lam.let_ str v l1 l2
    | Lmutlet (v, l1, l2) ->
        let v = rebind v in
        let l1 = aux l1 in
        let l2 = aux l2 in
        Lam.mutlet v l1 l2
    | Lletrec (bindings, body) ->
        (*order matters see GPR #405*)
        let vars = List.map ~f:(fun (k, _) -> rebind k) bindings in
        let bindings =
          List.map2 ~f:(fun var (_, l) -> (var, aux l)) vars bindings
        in
        let body = aux body in
        Lam.letrec bindings body
    | Lfunction { arity; params; body; attr } ->
        let params = List.map ~f:rebind params in
        let body = aux body in
        Lam.function_ ~arity ~params ~body ~attr
    | Lstaticcatch (l1, (i, xs), l2) ->
        let l1 = aux l1 in
        let xs = List.map ~f:rebind xs in
        let l2 = aux l2 in
        Lam.staticcatch l1 (i, xs) l2
    | Lfor (ident, l1, l2, dir, l3) ->
        let ident = rebind ident in
        let l1 = aux l1 in
        let l2 = aux l2 in
        let l3 = aux l3 in
        Lam.for_ ident (aux l1) l2 dir l3
    | Lconst _ -> lam
    | Lprim { primitive; args; loc } ->
        (* here it makes sure that global vars are not rebound *)
        Lam.prim ~primitive ~args:(List.map ~f:aux args) loc
    | Lglobal_module _ -> lam
    | Lapply { ap_func; ap_args; ap_info } ->
        let fn = aux ap_func in
        let args = List.map ~f:aux ap_args in
        Lam.apply fn args ap_info
    | Lswitch
        ( l,
          {
            sw_failaction;
            sw_consts;
            sw_blocks;
            sw_blocks_full;
            sw_consts_full;
            sw_names;
          } ) ->
        let l = aux l in
        Lam.switch l
          {
            sw_consts = List.map_snd sw_consts aux;
            sw_blocks = List.map_snd sw_blocks aux;
            sw_consts_full;
            sw_blocks_full;
            sw_failaction = option_map sw_failaction;
            sw_names;
          }
    | Lstringswitch (l, sw, d) ->
        let l = aux l in
        Lam.stringswitch l (List.map_snd sw aux) (option_map d)
    | Lstaticraise (i, ls) -> Lam.staticraise i (List.map ~f:aux ls)
    | Ltrywith (l1, v, l2) ->
        let l1 = aux l1 in
        let v = rebind v in
        let l2 = aux l2 in
        Lam.try_ l1 v l2
    | Lifthenelse (l1, l2, l3) ->
        let l1 = aux l1 in
        let l2 = aux l2 in
        let l3 = aux l3 in
        Lam.if_ l1 l2 l3
    | Lsequence (l1, l2) ->
        let l1 = aux l1 in
        let l2 = aux l2 in
        Lam.seq l1 l2
    | Lwhile (l1, l2) ->
        let l1 = aux l1 in
        let l2 = aux l2 in
        Lam.while_ l1 l2
    | Lassign (v, l) -> Lam.assign v (aux l)
    | Lsend (u, m, o, ll, v) ->
        let m = aux m in
        let o = aux o in
        let ll = List.map ~f:aux ll in
        Lam.send u m o ll v
    | Lifused (v, l) ->
        let l = aux l in
        Lam.ifused v l
  in
  aux lam
