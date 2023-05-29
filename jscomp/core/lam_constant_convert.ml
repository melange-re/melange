(* Copyright (C) 2018- Hongbo Zhang, Authors of ReScript
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

let rec convert_constant (const : Lambda.structured_constant) : Lam_constant.t =
  match const with
  | Const_base
      (Const_int 0, Pt_constructor { name = "()"; const = 1; non_const = 0 }) ->
      Const_js_undefined
  | Const_base (Const_int i, p) -> (
      match p with
      | Pt_module_alias -> Const_module_alias
      | Pt_builtin_boolean -> if i = 0 then Const_js_false else Const_js_true
      | Pt_shape_none -> Lam_constant.lam_none
      | Pt_assertfalse ->
          Const_int { i = Int32.of_int i; comment = Pt_assertfalse }
      | Pt_constructor { name; const; non_const } ->
          Const_int
            {
              i = Int32.of_int i;
              comment = Pt_constructor { name; const; non_const };
            }
      | Pt_variant { name } -> Const_pointer name
      | Pt_na -> Const_int { i = Int32.of_int i; comment = None })
  | Const_base (Const_char i, _) -> Const_char i
  | Const_base (Const_string (s, _, opt), _) ->
      let unicode =
        match opt with
        | Some opt -> Ast_utf8_string_interp.is_unicode_string opt
        | _ -> false
      in
      Const_string { s; unicode }
  | Const_base (Const_float i, _) -> Const_float i
  | Const_base (Const_int32 i, _) -> Const_int { i; comment = None }
  | Const_base (Const_int64 i, _) -> Const_int64 i
  | Const_base (Const_nativeint _, _) -> assert false
  | Const_float_array s -> Const_float_array s
  | Const_immstring s -> Const_string { s; unicode = false }
  | Const_block (i, t, xs) -> (
      match t with
      | Blk_some_not_nested ->
          Const_some (convert_constant (Ext_list.singleton_exn xs))
      | Blk_some -> Const_some (convert_constant (Ext_list.singleton_exn xs))
      | Blk_constructor { name; num_nonconst } ->
          let t : Lam_tag_info.t = Blk_constructor { name; num_nonconst } in
          Const_block (i, t, Ext_list.map xs convert_constant)
      | Blk_tuple ->
          let t : Lam_tag_info.t = Blk_tuple in
          Const_block (i, t, Ext_list.map xs convert_constant)
      | Blk_class ->
          let t : Lam_tag_info.t = Blk_class in
          Const_block (i, t, Ext_list.map xs convert_constant)
      | Blk_array ->
          let t : Lam_tag_info.t = Blk_array in
          Const_block (i, t, Ext_list.map xs convert_constant)
      | Blk_poly_var s -> (
          match xs with
          | [ _; value ] ->
              let t : Lam_tag_info.t = Blk_poly_var in
              Const_block
                ( i,
                  t,
                  [
                    Const_string { s; unicode = false }; convert_constant value;
                  ] )
          | _ -> assert false)
      | Blk_record s ->
          let t : Lam_tag_info.t = Blk_record s in
          Const_block (i, t, Ext_list.map xs convert_constant)
      | Blk_module s ->
          let t : Lam_tag_info.t = Blk_module s in
          Const_block (i, t, Ext_list.map xs convert_constant)
      | Blk_module_export _ ->
          let t : Lam_tag_info.t = Blk_module_export in
          Const_block (i, t, Ext_list.map xs convert_constant)
      | Blk_extension_slot ->
          assert false
          (* let t : Lam_tag_info.t = Blk_extension_slot in
             Const_block (i,t, Ext_list.map xs convert_constant ) *)
      | Blk_extension ->
          let t : Lam_tag_info.t = Blk_extension in
          Const_block (i, t, Ext_list.map xs convert_constant)
      | Blk_lazy_general -> assert false
      | Blk_na s ->
          let t : Lam_tag_info.t = Blk_na s in
          Const_block (i, t, Ext_list.map xs convert_constant)
      | Blk_record_inlined { name; fields; num_nonconst } ->
          let t : Lam_tag_info.t =
            Blk_record_inlined { name; fields; num_nonconst }
          in
          Const_block (i, t, Ext_list.map xs convert_constant)
      | Blk_record_ext s ->
          let t : Lam_tag_info.t = Blk_record_ext s in
          Const_block (i, t, Ext_list.map xs convert_constant))
