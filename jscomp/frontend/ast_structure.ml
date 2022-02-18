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

type item = Parsetree.structure_item
type t = item list

open Ast_helper

let fuseAll ?(loc = Location.none) (t : t) : item =
  Str.include_ ~loc (Incl.mk ~loc (Mod.structure ~loc t))

(* let fuse_with_constraint
     ?(loc=Location.none)
     (item : Parsetree.type_declaration list ) (t : t) (coercion) =
   Str.include_ ~loc
     (Incl.mk ~loc
        (Mod.constraint_
          (Mod.structure ~loc
          ({pstr_loc = loc; pstr_desc = Pstr_type item} :: t) )
          (
            Mty.signature ~loc
            ({psig_loc = loc; psig_desc = Psig_type item} :: coercion)
          )
          )
     ) *)
let constraint_ ?(loc = Location.none) (stru : t) (sign : Ast_signature.t) =
  Str.include_ ~loc
    (Incl.mk ~loc
       (Mod.constraint_ ~loc (Mod.structure ~loc stru) (Mty.signature ~loc sign)))

let dummy_item loc : item = Str.eval ~loc (Ast_literal.val_unit ~loc ())
