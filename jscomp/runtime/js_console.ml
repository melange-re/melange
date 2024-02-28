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

external log : 'a -> unit = "log" [@@mel.scope "console"]
external log2 : 'a -> 'b -> unit = "log" [@@mel.scope "console"]
external log3 : 'a -> 'b -> 'c -> unit = "log" [@@mel.scope "console"]
external log4 : 'a -> 'b -> 'c -> 'd -> unit = "log" [@@mel.scope "console"]

external logMany : 'a array -> unit = "log"
[@@mel.scope "console"] [@@mel.variadic]

external info : 'a -> unit = "info" [@@mel.scope "console"]
external info2 : 'a -> 'b -> unit = "info" [@@mel.scope "console"]
external info3 : 'a -> 'b -> 'c -> unit = "info" [@@mel.scope "console"]
external info4 : 'a -> 'b -> 'c -> 'd -> unit = "info" [@@mel.scope "console"]

external infoMany : 'a array -> unit = "info"
[@@mel.scope "console"] [@@mel.variadic]

external warn : 'a -> unit = "warn" [@@mel.scope "console"]
external warn2 : 'a -> 'b -> unit = "warn" [@@mel.scope "console"]
external warn3 : 'a -> 'b -> 'c -> unit = "warn" [@@mel.scope "console"]
external warn4 : 'a -> 'b -> 'c -> 'd -> unit = "warn" [@@mel.scope "console"]

external warnMany : 'a array -> unit = "warn"
[@@mel.scope "console"] [@@mel.variadic]

external error : 'a -> unit = "error" [@@mel.scope "console"]
external error2 : 'a -> 'b -> unit = "error" [@@mel.scope "console"]
external error3 : 'a -> 'b -> 'c -> unit = "error" [@@mel.scope "console"]
external error4 : 'a -> 'b -> 'c -> 'd -> unit = "error" [@@mel.scope "console"]

external errorMany : 'a array -> unit = "error"
[@@mel.scope "console"] [@@mel.variadic]

external trace : unit -> unit = "trace" [@@mel.scope "console"]
external timeStart : string -> unit = "time" [@@mel.scope "console"]
external timeEnd : string -> unit = "timeEnd" [@@mel.scope "console"]
