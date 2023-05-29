(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
 * Copyright (C) 2017- Hongbo Zhang, Authors of ReScript
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


(** Warning unused bs attributes
    Note if we warn `deriving` too,
    it may fail third party ppxes
*)
let is_bs_attribute txt =
  let len = String.length txt  in
  len >= 2 &&
  (*TODO: check the stringing padding rule, this preciate may not be needed *)
  String.unsafe_get txt 0 = 'b'&&
  String.unsafe_get txt 1 = 's' &&
  (len = 2 ||
   String.unsafe_get txt 2 = '.'
  )

let used_attributes : string Asttypes.loc Hash_set_poly.t =
  Hash_set_poly.create 16


#if false
  let dump_attribute fmt = (fun ( (sloc : string Asttypes.loc),payload) ->
      Format.fprintf fmt "@[%s %a@]" sloc.txt (Printast.payload 0 ) payload
    )

let dump_used_attributes fmt =
  Format.fprintf fmt "Used attributes Listing Start:@.";
  Hash_set_poly.iter  used_attributes (fun attr -> dump_attribute fmt attr) ;
  Format.fprintf fmt "Used attributes Listing End:@."
#endif

(* only mark non-ghost used bs attribute *)
let mark_used_bs_attribute ({ attr_name = x; _ } : Parsetree.attribute) =
  if not x.loc.loc_ghost then
    Hash_set_poly.add used_attributes x


let warn_unused_attribute
    ({ attr_name = ({txt; loc} as sloc)} : Parsetree.attribute) =
  if is_bs_attribute txt &&
     not loc.loc_ghost &&
     not (Hash_set_poly.mem used_attributes sloc) then
    begin
#if false
(*COMMENT*)
  dump_used_attributes Format.err_formatter;
dump_attribute Format.err_formatter attr ;
#endif
    Location.prerr_warning loc (Bs_unused_attribute txt)
    end

let warn_discarded_unused_attributes (attrs : Parsetree.attributes) =
  if attrs <> [] then
    Ext_list.iter attrs warn_unused_attribute


type iterator = Ast_iterator.iterator
let super = Ast_iterator.default_iterator

let check_constant loc kind (const : Parsetree.constant) =
  match const with
  | Pconst_string
    (_, _, Some s) ->
    begin match kind with
      | `expr ->
          (if Ast_utf8_string_interp.is_unescaped s  then
             Bs_warnings.error_unescaped_delimiter loc s)
      | `pat ->
        if s =  "j" then
        Location.raise_errorf ~loc  "Unicode string is not allowed in pattern match"
    end
  | Pconst_integer(s,None) ->
    (* range check using int32
      It is better to give a warning instead of error to avoid make people unhappy.
      It also has restrictions in which platform bsc is running on since it will
      affect int ranges
    *)
    (
      try
        ignore (Int32.of_string s)
      with _ ->
        Bs_warnings.warn_literal_overflow loc
    )
  | Pconst_integer(_, Some 'n')
    -> Location.raise_errorf ~loc "literal with `n` suffix is not supported"
  | _ -> ()

(* Note we only used Bs_ast_iterator here, we can reuse compiler-libs instead of
   rolling our own *)
let emit_external_warnings : iterator=
  {
    super with
    attribute = (fun _ attr -> warn_unused_attribute attr);
    expr = (fun self a ->
        match a.pexp_desc with
        | Pexp_constant(const) -> check_constant a.pexp_loc `expr const
        | _ -> super.expr self a
      );
    label_declaration = (fun self lbl ->

      Ext_list.iter lbl.pld_attributes
        (fun attr ->
          match attr with
          | { attr_name = {txt = "bs.as" | "as"}; _ } -> mark_used_bs_attribute attr
          | _ -> ()
          );
      super.label_declaration self lbl
    );
    value_description =
      (fun self v ->
         match v with
         | ( {
             pval_loc;
             pval_prim =
               "%identity"::_;
             pval_type
           } : Parsetree.value_description)
           when not
               (Ast_core_type.is_arity_one pval_type)
           ->
           Location.raise_errorf
             ~loc:pval_loc
             "%%identity expect its type to be of form 'a -> 'b (arity 1)"
         | _ ->
           super.value_description self v
      );
    pat = begin fun self (pat : Parsetree.pattern) ->
      match pat.ppat_desc with
      |  Ppat_constant(constant) ->
        check_constant pat.ppat_loc `pat constant
      | Ppat_record ([],_) ->
        Location.raise_errorf ~loc:pat.ppat_loc "Empty record pattern is not supported"
      | _ -> super.pat self pat
    end
  }

let rec iter_warnings_on_stru (stru : Parsetree.structure) =
  match stru with
  | [] -> ()
  | head :: rest ->
    begin match head.pstr_desc with
      | Pstr_attribute attr ->
        Builtin_attributes.warning_attribute attr;
        iter_warnings_on_stru rest
      |  _ -> ()
    end

let rec iter_warnings_on_sigi (stru : Parsetree.signature) =
  match stru with
  | [] -> ()
  | head :: rest ->
    begin match head.psig_desc with
      | Psig_attribute attr ->
        Builtin_attributes.warning_attribute attr;
        iter_warnings_on_sigi rest
      |  _ -> ()
    end


let emit_external_warnings_on_structure  (stru : Parsetree.structure) =
  emit_external_warnings.structure emit_external_warnings stru

let emit_external_warnings_on_signature  (sigi : Parsetree.signature) =
  emit_external_warnings.signature emit_external_warnings sigi
