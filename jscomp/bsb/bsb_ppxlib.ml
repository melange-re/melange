(* Copyright (C) 2021- Authors of Melange
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

let generate_rules (ppx_config : Bsb_config_types.ppx_config) =
  let driver = "let () = Ppxlib.Driver.standalone ()" in
  let ppx_ml =
    Format.asprintf "(rule (with-stdout-to ppx.ml (run echo %S)))" driver
  in
  let executable =
    Format.asprintf
      "(executable (name ppx) (modules ppx) (flags -linkall) (libraries %s))"
      (String.concat " " (Ext_list.map ppx_config.ppxlib (fun x -> x.name)))
  in
  Format.asprintf "%s@\n%s" ppx_ml executable

let ppxlib ~(ppx_config : Bsb_config_types.ppx_config) buf =
  if ppx_config.ppxlib <> [] then
    Buffer.add_string buf (generate_rules ppx_config)
