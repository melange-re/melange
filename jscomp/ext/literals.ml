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

let js_type_number = "number"
let js_type_string = "string"
let js_type_object = "object"
let js_type_boolean = "boolean"
let js_undefined = "undefined"
let js_prop_length = "length"
let param = "param"
let partial_arg = "partial_arg"
let tmp = "tmp"
let create = "create" (* {!Caml_exceptions.create}*)
let imul = "imul" (* signed int32 mul *)
let setter_suffix = "#="
let setter_suffix_len = String.length setter_suffix
let unsafe_downgrade = "unsafe_downgrade"

(* nodejs *)
let package_name = "melange"

(* Name of the library file created for each external dependency. *)
let lib = "lib"
let gentype_import = "genType.import"
let exception_id = "MEL_EXN_ID"
let polyvar_hash = "NAME"
let polyvar_value = "VAL"
let cons = "::"
let hd = "hd"
let tl = "tl"
let lazy_done = "LAZY_DONE"
let lazy_val = "VAL"
let pure = "@__PURE__"
