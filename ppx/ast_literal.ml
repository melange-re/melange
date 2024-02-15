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

open Import

let hidden_field n = Lident ("I" ^ n)
let js = Lident "Js"
let js_fn = Ldot (js, "Fn")
let js_internal = Ldot (js, "Internal")
let js_internal_full_apply = Ldot (js_internal, "opaqueFullApply")
let js_oo = Ldot (Ldot (js, "Private"), "Js_OO")
let js_meth = Ldot (js_oo, "Meth")
let js_meth_callback = Ldot (js_oo, "Callback")
let js_null = Ldot (js, "null")
let js_nullable = Ldot (js, "nullable")
let js_obj = Ldot (js, "t")
let js_re_id = Ldot (Ldot (js, "Re"), "t")
let js_undefined = Ldot (js, "undefined")
let opaque = Ldot (js_internal, "opaque")
let predef_prefix_ident = Lident "*predef*"
let predef_some = Ldot (predef_prefix_ident, "Some")
let predef_none = Ldot (predef_prefix_ident, "None")
let unsafe_downgrade = Ldot (js_oo, "unsafe_downgrade")
