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

let ps = Format.pp_print_string

let print_ident ppf s =
  ps ppf
    (match s with
    | "Js_null" -> "Js.Null"
    | "Js_undefined" -> "Js.Undefined"
    | "Js_null_undefined" -> "Js.Nullable"
    | "Js_exn" -> "Js.Exn"
    | "Js_array" -> "Js.Array"
    | "Js_string" -> "Js.String"
    | "Js_re" -> "Js.Re"
    | "Js_promise" -> "Js.Promise"
    | "Js_date" -> "Js.Date"
    | "Js_dict" -> "Js.Dict"
    | "Js_global" -> "Js.Global"
    | "Js_json" -> "Js.Json"
    | "Js_math" -> "Js.Math"
    | "Js_obj" -> "Js.Obj"
    | "Js_typed_array" -> "Js.Typed_array"
    | "Js_types" -> "Js.Types"
    | "Js_float" -> "Js.Float"
    | "Js_int" -> "Js.Int"
    | "Js_option" -> "Js.Option"
    | "Js_result" -> "Js.Result"
    | "Js_list" -> "Js.List"
    | "Js_vector" -> "Js.Vector"
    (* Belt_libs  *)
    | "Belt_Id" -> "Belt.Id"
    | "Belt_Array" -> "Belt.Array"
    | "Belt_SortArray" -> "Belt.SortArray"
    | "Belt_SortArrayInt" -> "Belt.SortArray.Int"
    | "Belt_SortArrayString" -> "Belt.SortArray.String"
    | "Belt_MutableQueue" -> "Belt.MutableQueue"
    | "Belt_MutableStack" -> "Belt.MutableStack"
    | "Belt_List" -> "Belt.List"
    | "Belt_Range" -> "Belt.Range"
    | "Belt_Set" -> "Belt.Set"
    | "Belt_SetInt" -> "Belt.Set.Int"
    | "Belt_SetString" -> "Belt.Set.String"
    | "Belt_Map" -> "Belt.Map"
    | "Belt_MapInt" -> "Belt.Map.Int"
    | "Belt_MapString" -> "Belt.Map.String"
    | "Belt_Option" -> "Belt.Option"
    | "Belt_MutableSet" -> "Belt.MutableSet"
    | "Belt_MutableSetInt" -> "Belt.MutableSet.Int"
    | "Belt_MutableSetString" -> "Belt.MutableSet.String"
    | "Belt_MutableMap" -> "Belt.MutableMap"
    | "Belt_MutableMapInt" -> "Belt.MutableMap.Int"
    | "Belt_MutableMapString" -> "Belt.MutableMap.String"
    | "Belt_HashSet" -> "Belt.HashSet"
    | "Belt_HashSetInt" -> "Belt.HashSet.Int"
    | "Belt_HashSetString" -> "Belt.HashSet.String"
    | "Belt_HashMap" -> "Belt.HashMap"
    | "Belt_HashMapString" -> "Belt.HashMap.String"
    | "Belt_HashMapInt" -> "Belt.HashMap.Int"
    | "Belt_Debug" -> "Belt.Debug"
    | s -> s)

open Format

let rec out_ident ppf = function
  | Outcometree.Oide_ident s -> print_ident ppf s.printed_name
  | Oide_dot (id, s) ->
      out_ident ppf id;
      pp_print_char ppf '.';
      print_ident ppf s
  | Oide_apply (id1, id2) -> fprintf ppf "%a(%a)" out_ident id1 out_ident id2
