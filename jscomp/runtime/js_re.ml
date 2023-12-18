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

(** Provides bindings for JavaScript Regular Expressions

{4 Syntax sugar}
Melange provides a bit of syntax sugar for regex literals: [\[%re "/foo/g"\]]
will evaluate to a {! t} that can be passed around and used like usual.

{b Note:} This is not an immutable API. A RegExp object with the [global] ("g")
flag set will modify the {! lastIndex} property when the RegExp object is used,
and subsequent uses will ocntinue the search from the previous {! lastIndex}.

{[
let maybeMatches = "banana" |> Js.String.match_ [\[%re "/na+/g"\]]
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp> JavaScript API reference on MDN

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions> JavaScript Regular Expressions Guide on MDN
*)

type t
(** the RegExp object *)

type result
(** the result of a executing a RegExp on a string *)

external captures : result -> string Js_internal.nullable array = "%identity"
(** an array of the match and captures, the first is the full match and the remaining are the substring captures *)

external index : result -> int = "index"
[@@mel.get]
(** 0-based index of the match in the input string *)

external input : result -> string = "input"
[@@mel.get]
(** the original input string *)

external fromString : string -> t = "RegExp"
[@@mel.new]
(** Constructs a RegExp object ({! t}) from a string

Regex literals ([\[%re "/.../"\]]) should generally be preferred, but
[fromString] is very useful when you need to insert a string into a regex.

{[
(* A function that extracts the content of the first element with the given tag *)

let contentOf tag xmlString =
  Js.Re.fromString ("<" ^ tag ^ ">(.*?)<\\/" ^ tag ^">")
    |> Js.Re.exec ~str:xmlString
    |> function
      | Some result -> Js.Nullable.toOption (Js.Re.captures result).(1)
      | None -> None
]}
*)

external fromStringWithFlags : string -> flags:string -> t = "RegExp"
[@@mel.new]
(** Constructs a RegExp object ({! t}) from a string with the given [flags]

See {! fromString}

Valid flags:
{%html:
<table>
  <tr> <td>g <td>global
  <tr> <td>i <td>ignore case
  <tr> <td>m <td>multiline
  <tr> <td>u <td>unicode <td>(es2015)
  <tr> <td>y <td>sticky <td>(es2015)
</table>
%}
*)

external flags : t -> string = "flags"
[@@mel.get]
(** returns the enabled flags as a string *)

external global : t -> bool = "global"
[@@mel.get]
(** returns a bool indicating whether the [global] flag is set *)

external ignoreCase : t -> bool = "ignoreCase"
[@@mel.get]
(** returns a bool indicating whether the [ignoreCase] flag is set *)

external lastIndex : t -> int = "lastIndex"
[@@mel.get]
(** returns the index where the next match will start its search

This property will be modified when the RegExp object is used, if the [global] ("g")
flag is set.

{[
(* Finds and prints successive matches *)

let re = [%re "/ab*/g"] in
let str = "abbcdefabh" in

let break = ref false in
while not !break do
  match re |> Js.Re.exec ~str with
  | None -> break := true
  | Some result ->
    Js.Nullable.iter (Js.Re.captures result).(0) ((fun match_ ->
      let next = string_of_int (Js.Re.lastIndex re) in
      Js.log ("Found " ^ match_ ^ ". Next match starts at " ^ next)))
done
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/lastIndex> MDN
*)

external setLastIndex : t -> int -> unit = "lastIndex"
[@@mel.set]
(** sets the index at which the next match will start its search from *)

external multiline : t -> bool = "multiline"
[@@mel.get]
(** returns a bool indicating whether the [multiline] flag is set *)

external source : t -> string = "source"
[@@mel.get]
(** returns the pattern as a string *)

external sticky : t -> bool = "sticky"
[@@mel.get]
(** returns a bool indicating whether the [sticky] flag is set *)

external unicode : t -> bool = "unicode"
[@@mel.get]
(** returns a bool indicating whether the [unicode] flag is set *)

external exec : str:string -> result option = "exec"
[@@mel.send.pipe: t] [@@mel.return null_to_opt]
(** executes a search on a given string using the given RegExp object

{b returns} [Some] {! result} if a match is found, [None] otherwise

{[
(* Match "quick brown" followed by "jumps", ignoring characters in between
 * Remember "brown" and "jumps"
 * Ignore case
 *)

let re = [%re "/quick\s(brown).+?(jumps)/ig"] in
let result = re |. Js.Re.exec ~str:"The Quick Brown Fox Jumps Over The Lazy Dog"
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/exec> MDN
*)

external test : str:string -> bool = "test"
[@@mel.send.pipe: t]
(** tests whether the given RegExp object will match a given string

{b returns} [true] if a match is found, [false] otherwise

{[
(* A simple implementation of Js.String.startsWith *)

let str = "hello world!"

let startsWith target substring =
  Js.Re.fromString ("^" ^ substring)
    |. Js.Re.test ~str:target

let () = Js.log (str |. startsWith "hello") (* prints "true" *)
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/test> MDN
*)
