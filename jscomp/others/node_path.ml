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

(** Node Path API *)

external basename : string -> string = "basename" [@@mel.module "path"]

external basename_ext : string -> string -> string = "basename"
[@@mel.module "path"]

external delimiter : string = "delimiter" [@@mel.module "path"]
external dirname : string -> string = "dirname" [@@mel.module "path"]

external dirname_ext : string -> string -> string = "dirname"
[@@mel.module "path"]

type pathObject =
  < dir : string
  ; root : string
  ; base : string
  ; name : string
  ; ext : string >
  Js.t

external format : pathObject -> string = "format" [@@mel.module "path"]
external isAbsolute : string -> bool = "isAbsolute" [@@mel.module "path"]

(* TODO: improve after we support [@mel.rest] calling convention  *)
external join2 : string -> string -> string = "join" [@@mel.module "path"]

external join : string array -> string = "join"
[@@mel.module "path"] [@@mel.variadic]

external normalize : string -> string = "normalize" [@@mel.module "path"]

(* TODO: check if there is an exception raised *)
external parse : string -> pathObject = "parse" [@@mel.module "path"]

(* TODO: provide bindings to [path.posix]*)

external relative : from:string -> to_:string -> unit -> string = "relative"
[@@mel.module "path"]

(* TODO: improve after rest calling convention *)
external resolve : string -> string -> string = "resolve" [@@mel.module "path"]
external sep : string = "sep" [@@mel.module "path"]

(* TODO: provides [path.win32] *)
