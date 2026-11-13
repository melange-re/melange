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

open Import

type t = Ident.t

let ident t = t
let make = Ident.create_persistent
let exceptions = make "Caml_exceptions"
let io = make "Caml_io"
let sys = make "Caml_sys"
let lexer = make "Caml_lexer"
let parser = make "Caml_parser"
let obj_runtime = make "Caml_obj"
let array = make "Caml_array"
let format = make "Caml_format"
let string = make "Caml_string"
let bytes = make "Caml_bytes"
let float = make "Caml_float"
let hash_primitive = make "Caml_hash_primitive"
let hash = make "Caml_hash"
let oo = make "Caml_oo"
let curry = make "Curry"

(* [Curry.__n] and [Curry._n] exist up to this [n], see [number] in
   [runtime/gen/gen_curry.ml] *)
let curry_max_arity = 8
let caml_oo_curry = make "Caml_oo_curry"
let caml_primitive = make "Caml"
let int64 = make "Caml_int64"
let md5 = make "Caml_md5"
let int32 = make "Caml_int32"
let option = make "Caml_option"
let module_ = make "Caml_module"
let external_polyfill = make "Caml_external_polyfill"
let caml_js_exceptions = make "Caml_js_exceptions"
let caml_splice_call = make "Caml_splice_call"
