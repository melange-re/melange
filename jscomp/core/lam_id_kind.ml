(* Copyright (C) Hongbo Zhang, Authors of ReScript
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

(** Keep track of which identifiers are aliased
  *)

type rec_flag = Lam_rec | Lam_non_rec | Lam_self_rec
(* only a
   single mutual
   recursive function
*)

module Element = struct
  type t = NA | SimpleForm of Lam.t

  let of_lambda = function
    | ( Lam.Lvar _ | Lconst _
      | Lprim
          {
            primitive = Pfield (_, Fld_module _);
            args = [ (Lglobal_module _ | Lvar _) ];
            _;
          } ) as lam ->
        SimpleForm lam
    (* | Lfunction _  *)
    | _ -> NA
end

type boxed_nullable = Undefined | Null | Null_undefined

type t =
  | Normal_optional of Lam.t (* Some [x] *)
  | OptionalBlock of Lam.t * boxed_nullable
  | ImmutableBlock of Element.t array
  | MutableBlock of Element.t array
  | Constant of Lam.Constant.t
  | Module of Ident.t  (** TODO: static module vs first class module *)
  | FunctionId of {
      mutable arity : Lam_arity.t;
      (* TODO: This may contain some closure environment,
         check how it will interact with dead code elimination
      *)
      lambda : (Lam.t * rec_flag) option;
    }
  | Exception
  | Parameter
      (** For this case, it can help us determine whether it should be inlined or not *)
  | NA
      (** Not such information is associated with an identifier, it is immutable,
           if you only associate a property to an identifier
           we should consider [Lassign] *)

(* How we destruct the immutable block
   depend on the block name itself,
   good hints to do aggressive destructing
   1. the variable is not exported
      like [matched] -- these are blocks constructed temporary
   2. how the variable is used
      if it is guarateed to be
   - non export
   - and non escaped (there is no place it is used as a whole)
      then we can always destruct it
      if some fields are used in multiple places, we can create
      a temporary field

   3. It would be nice that when the block is mutable, its
       mutable fields are explicit, since wen can not inline an mutable block access
*)

let of_lambda_block (xs : Lam.t list) =
  ImmutableBlock (Array.of_list_map xs ~f:Element.of_lambda)

let print =
  let pp = Format.fprintf in
  fun fmt kind ->
    match kind with
    | ImmutableBlock arr -> pp fmt "Imm(%d)" (Array.length arr)
    | Normal_optional _ -> pp fmt "Some"
    | OptionalBlock (_, Null) -> pp fmt "?Null"
    | OptionalBlock (_, Undefined) -> pp fmt "?Undefined"
    | OptionalBlock (_, Null_undefined) -> pp fmt "?Nullable"
    | MutableBlock arr -> pp fmt "Mutable(%d)" (Array.length arr)
    | Constant _ -> pp fmt "Constant"
    | Module id -> pp fmt "%s/%d" (Ident.name id) (Ident.stamp id)
    | FunctionId _ -> pp fmt "FunctionID"
    | Exception -> pp fmt "Exception"
    | Parameter -> pp fmt "Parameter"
    | NA -> pp fmt "NA"
