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
open Ast_helper

let lift_option_type ({ ptyp_loc; _ } as ty) =
  {
    ptyp_desc =
      Ptyp_constr
        ( {
            txt = Lident "option" (* Ast_literal.predef_option *);
            loc = ptyp_loc;
          },
          [ ty ] );
    ptyp_loc;
    ptyp_loc_stack = [ ptyp_loc ];
    ptyp_attributes = [];
  }

(* let replace_result (ty : t) (result : t) : t =
   let rec aux (ty : core_type) =
     match ty with
     | { ptyp_desc =
           Ptyp_arrow (label,t1,t2)
       } -> { ty with ptyp_desc = Ptyp_arrow(label,t1, aux t2)}
     | {ptyp_desc = Ptyp_poly(fs,ty)}
       ->  {ty with ptyp_desc = Ptyp_poly(fs, aux ty)}
     | _ -> result in
   aux ty *)

let is_builtin_rank0_type txt =
  match txt with
  | "int" | "char" | "bytes" | "float" | "bool" | "unit" | "exn" | "int32"
  | "int64" | "string" ->
      true
  | _ -> false

let is_unit ty =
  match ty.ptyp_desc with
  | Ptyp_constr ({ txt = Lident "unit"; _ }, []) -> true
  | _ -> false

(* let is_array (ty : t) =
   match ty.ptyp_desc with
   | Ptyp_constr({txt =Lident "array"}, [_]) -> true
   | _ -> false *)

let is_user_option ty =
  match ty.ptyp_desc with
  | Ptyp_constr
      ({ txt = Lident "option" | Ldot (Lident "*predef*", "option"); _ }, [ _ ])
    ->
      true
  | _ -> false

(* let is_user_bool (ty : t) =
   match ty.ptyp_desc with
   | Ptyp_constr({txt = Lident "bool"},[]) -> true
   | _ -> false *)

(* let is_user_int (ty : t) =
   match ty.ptyp_desc with
   | Ptyp_constr({txt = Lident "int"},[]) -> true
   | _ -> false *)

let make_obj ~loc xs = Ast_comb.to_js_type ~loc (Typ.object_ ~loc xs Closed)

(**

{[ 'a . 'a -> 'b ]}
OCaml does not support such syntax yet
{[ 'a -> ('a. 'a -> 'b) ]}

*)
let rec get_uncurry_arity_aux ty acc =
  match ty.ptyp_desc with
  | Ptyp_arrow (_, _, new_ty) -> get_uncurry_arity_aux new_ty (succ acc)
  | Ptyp_poly (_, ty) -> get_uncurry_arity_aux ty acc
  | _ -> acc

(**
   {[ unit -> 'b ]} return arity 0
   {[ unit -> 'a1 -> a2']} arity 2
   {[ 'a1 -> 'a2 -> ... 'aN -> 'b ]} return arity N
*)
let get_uncurry_arity ty =
  match ty.ptyp_desc with
  | Ptyp_arrow
      ( Nolabel,
        { ptyp_desc = Ptyp_constr ({ txt = Lident "unit"; _ }, []); _ },
        rest ) -> (
      match rest with
      | { ptyp_desc = Ptyp_arrow _; _ } -> Some (get_uncurry_arity_aux rest 1)
      | _ -> Some 0)
  | Ptyp_arrow (_, _, rest) -> Some (get_uncurry_arity_aux rest 1)
  | _ -> None

let get_curry_arity ty = get_uncurry_arity_aux ty 0
let is_arity_one ty = get_curry_arity ty = 1

type param_type = {
  label : Asttypes.arg_label;
  ty : core_type;
  attr : attributes;
  loc : loc;
}

let mk_fn_type (new_arg_types_ty : param_type list) result =
  List.fold_right
    ~f:(fun { label; ty; attr; loc } acc ->
      {
        ptyp_desc = Ptyp_arrow (label, ty, acc);
        ptyp_loc = loc;
        ptyp_loc_stack = [ loc ];
        ptyp_attributes = attr;
      })
    new_arg_types_ty ~init:result

let list_of_arrow ty : core_type * param_type list =
  let rec aux ty acc =
    match ty.ptyp_desc with
    | Ptyp_arrow (label, t1, t2) ->
        aux t2
          (({ label; ty = t1; attr = ty.ptyp_attributes; loc = ty.ptyp_loc }
             : param_type)
          :: acc)
    | Ptyp_poly (_, ty) ->
        (* should not happen? *)
        Error.err ~loc:ty.ptyp_loc Unhandled_poly_type
    | _ -> (ty, List.rev acc)
  in
  aux ty []
