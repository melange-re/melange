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

type t = Cmi | Cmj | Cmt | Cmti | Unknown

let to_string = function
  | Cmi -> ".cmi"
  | Cmj -> ".cmj"
  | Cmt -> ".cmt"
  | Cmti -> ".cmti"
  | Unknown -> assert false

let of_string = function
  | ".cmi" -> Cmi
  | ".cmj" -> Cmj
  | ".cmt" -> Cmt
  | ".cmti" -> Cmti
  | _ -> Unknown

let append_extension fn e = fn ^ to_string e
let ml = ".ml"

module Valid_input = struct
  type t = Ml | Mli | Cmi | Cmj | Unknown

  let classify ext =
    if ext = ml then Ml
    else if ext = !Config.interface_suffix then Mli
    else
      match of_string ext with
      | Cmi -> Cmi
      | Cmj -> Cmj
      | Cmt | Cmti | Unknown -> Unknown
end
