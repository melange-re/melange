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

(** Store a file called [.bsbuild] that can be communicated
    between [bsb.exe] and [bsb_helper.exe].
    [bsb.exe] stores such data which would be retrieved by
    [bsb_helper.exe]. It is currently used to combine with
    ocamldep to figure out which module->file it depends on
*)

type case = bool

type info =
  | Intf
  (* intemediate state *)
  | Impl
  | Impl_intf

type syntax_kind = Ml | Reason | Res
type 'a diff = Same of 'a | Different of { impl : 'a; intf : 'a }

type module_info = {
  mutable info : info;
  dir : string diff;
  syntax_kind : syntax_kind diff;
  (* This is actually not stored in bsbuild meta info
     since creating .d file only emit .cmj/.cmi dependencies, so it does not
     need know which syntax it is written
  *)
  case : bool;
  name_sans_extension : string;
}

type map = module_info Map_string.t
type 'a cat = { mutable lib : 'a; mutable dev : 'a }
type t = map cat

(** store  the meta data indexed by {!Bsb_dir_index}
  {[
    0 --> lib group
    1 --> dev 1 group
    .

  ]}
*)
