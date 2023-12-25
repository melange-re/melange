(* Copyright (C) 2017 Hongbo Zhang, Authors of ReScript
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

let packages_info = ref Js_packages_info.empty
let output_info = ref None

let set_package_name name =
  packages_info := Js_packages_info.from_name ~t:!packages_info name

let update_npm_package_path ?module_name path =
  packages_info :=
    Js_packages_info.add_npm_package_path ?module_name !packages_info path

let set_output_info ~suffix module_system =
  output_info := Some { Js_packages_info.suffix; module_system }

let get_packages_info () = !packages_info

let get_output_info () =
  match !output_info with
  | Some info -> [ info ]
  | None -> Js_packages_info.assemble_output_info !packages_info

let get_packages_info_for_cmj () = !packages_info
