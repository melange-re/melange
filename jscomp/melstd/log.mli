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

(** A Poor man's logging utility

    Example:
    {[
    err __LOC__ "xx"
    ]}
 *)

module Style : sig
  type t =
    | Loc
    | Error
    | Warning
    | Kwd
    | Prompt
    | Hint
    | Details
    | Ok
    | Debug
    | Success
    | Ansi_styles of Ansi_color.Style.t list

  val to_styles : t -> Ansi_color.Style.t list
  val of_string : string -> t option
end

type t

module Level : sig
  type t = Quiet | Verbose
end

val set_level : Level.t -> unit
val print : ?config:(Style.t -> Ansi_color.Style.t list) -> t -> unit
val prerr : ?config:(Style.t -> Ansi_color.Style.t list) -> t -> unit
val info : ?loc:Location.t -> Style.t Pp.t -> unit
val warn : ?loc:Location.t -> Style.t Pp.t -> unit
