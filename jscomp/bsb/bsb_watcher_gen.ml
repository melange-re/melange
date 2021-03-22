(* Copyright (C) 2017- Hongbo Zhang, Authors of ReScript
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



let kvs = Ext_json_noloc.kvs
let arr = Ext_json_noloc.arr
let str = Ext_json_noloc.str

let generate_sourcedirs_meta
  ~name (file_groups : (string * Bsb_file_groups.t) list) =
  let pkgs = Hashtbl.create 10 in
  let (dirs, generated) =
    Ext_list.fold_left file_groups ([], []) (fun (dirs, generated) (proj_dir, { files }) ->
      let dirs = Ext_list.append dirs (Ext_list.map files (fun x -> Ext_path.combine proj_dir x.dir)) in
      let generated =
        Ext_list.fold_left files [] (fun acc x ->
          Ext_list.flat_map_append x.generators acc (fun x ->
            Ext_list.map (x.input @ x.output) (fun x ->
              Ext_path.combine proj_dir x)))
      in
      let _ : unit list = Bsb_pkg.to_list (fun pkg path ->
        let pkg = (Bsb_pkg_types.to_string pkg) in
        if not (Hashtbl.mem pkgs pkg) then
          Hashtbl.add pkgs pkg path)
      in
      dirs, generated)
  in
  let v =
    kvs [
      "dirs" ,
      arr (Ext_array.of_list_map dirs str) ;
      "generated" ,
      arr (Ext_array.of_list_map generated str);
      "pkgs", arr
        (Array.of_list
          (Hashtbl.fold (fun pkg path acc ->
            (arr [|
              str pkg;
              str path
        |]) :: acc
          ) pkgs [] )
        )
    ]
  in
  Ext_json_noloc.to_file
  name v

