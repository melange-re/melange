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

let predef_prefix_ident : Longident.t = Lident "*predef*"
let predef_option : Longident.t = Ldot (predef_prefix_ident, "option")
let predef_some : Longident.t = Ldot (predef_prefix_ident, "Some")
let predef_none : Longident.t = Ldot (predef_prefix_ident, "None")

type t = Longident.t

(* TODO should be renamed in to {!Js.fn} *)
(* TODO should be moved into {!Js.t} Later *)
let js_internal : t = Ldot (Lident "Js", "Internal")
let js_internal_full_apply : t = Ldot (js_internal, "opaqueFullApply")
let opaque : t = Ldot (js_internal, "opaque")
let js_fn : t = Ldot (Lident "Js", "Fn")
let js_oo : t = Lident "Js_OO"
let js_meth : t = Ldot (js_oo, "Meth")
let js_meth_callback : t = Ldot (js_oo, "Callback")
let js_obj : t = Ldot (Lident "Js", "t")
let ignore_id : t = Ldot (Lident "Stdlib", "ignore")
let hidden_field n : t = Lident ("I" ^ n)
let js_null : t = Ldot (Lident "Js", "null")
let js_undefined : t = Ldot (Lident "Js", "undefined")
let js_null_undefined : t = Ldot (Lident "Js", "null_undefined")
let js_re_id : t = Ldot (Ldot (Lident "Js", "Re"), "t")
