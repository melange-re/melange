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

(** Provides functionality for dealing with the ['a Js.undefined] type *)

type +'a t = 'a Js.undefined
(** Local alias for ['a Js.undefined] *)

external return : 'a -> 'a t = "%identity"
(** Constructs a value of ['a Js.undefined] containing a value of ['a] *)

val testAny : 'a -> bool
(** Returns [true] if the given value is [empty] ([undefined]) *)

external empty : 'a t = "#undefined"
(** The empty value, [undefined] *)

external getUnsafe : 'a t -> 'a = "%identity"
val getExn : 'a t -> 'a
val map : f:(('a -> 'b)[@u]) -> 'a t -> 'b t

val bind : f:(('a -> 'b t)[@u]) -> 'a t -> 'b t
(** Bind the contained value using the given function

If ['a Js.undefined] contains a value, that value is unwrapped, mapped to a
['b] using the given function [a' -> 'b], then wrapped back up and returned as
['b Js.undefined]

{[
let maybeGreetWorld (maybeGreeting: string Js.undefined) =
  Js.Undefined.bind maybeGreeting ~f:(fun greeting -> greeting ^ " world!")
]}
*)

val iter : f:(('a -> unit)[@u]) -> 'a t -> unit
(** Iterates over the contained value with the given function

If ['a Js.undefined] contains a value, that value is unwrapped and applied to
the given function.

{[
let maybeSay (maybeMessage: string Js.undefined) =
  Js.Undefined.iter maybeMessage ~f:(fun message -> Js.log message)
]}
*)

val fromOption : 'a option -> 'a t
(** Maps ['a option] to ['a Js.undefined]

{%html:
<table>
<tr> <td>Some a <td>-> <td>return a
<tr> <td>None <td>-> <td>empty
</table>
%}
*)

external toOption : 'a t -> 'a option = "#undefined_to_opt"
(** Maps ['a Js.undefined] to ['a option]

{%html:
<table>
<tr> <td>return a <td>-> <td>Some a
<tr> <td>empty <td>-> <td>None
</table>
%}
*)
