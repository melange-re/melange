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

open Melange_mini_stdlib

type nested = { depth : int [@mel.as "MEL_PRIVATE_NESTED_SOME_NONE"] }

val nullable_to_opt : 'a Js_internal.nullable -> 'a option
val undefined_to_opt : 'a Js_internal.undefined -> 'a option
val null_to_opt : 'a Js_internal.null -> 'a option
val valFromOption : Obj.t -> Obj.t
val some : Obj.t -> Obj.t
val isNested : Obj.t -> bool
val option_get : Obj.t option -> Obj.t Caml_undefined_extern.t

type poly

val option_unwrap : poly option -> Obj.t
(** When it is None, return none
    When it is (Some (`a 3)) return 3
*)
